/**
 * NOTES
 * 
 * Player needs a way to tell if a video exsists when streaming video.
 */

package modules.videoPlayer
{
	import modules.videoPlayer.controls.AudioSlider;
	import modules.videoPlayer.controls.ElapsedTime;
	import modules.videoPlayer.controls.PlayButton;
	import modules.videoPlayer.controls.ScrubberBar;
	import modules.videoPlayer.controls.StopButton;
	import modules.videoPlayer.controls.SkinableComponent;
	import modules.videoPlayer.events.PlayPauseEvent;
	import modules.videoPlayer.events.ScrubberBarEvent;
	import modules.videoPlayer.events.StopEvent;
	import modules.videoPlayer.events.VideoPlayerEvent;
	import modules.videoPlayer.events.VolumeEvent;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.events.IOErrorEvent;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.Timer;
	import flash.utils.Dictionary;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.containers.Panel;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.effects.Pause;

	public class VideoPlayer extends SkinableComponent
	{
		/**
		 * Skin related variables
		 */
		private const SKIN_PATH:String = "resources/videoPlayer/skin/";
		private var _skinableComponents:Dictionary;
		private var _skinLoader:URLLoader;
		private var _loadingSkin:Boolean = false;
		public static const BG_COLOR:String = "bgColor";
		public static const BORDER_COLOR:String = "borderColor";
		public static const VIDEOBG_COLOR:String = "videoBgColor";
		
		/**
		 * Variables
		 * 
		 */
		protected var _video:Video;
		protected var _videoWrapper:MovieClip;
		protected var _ns:NetStream;
		protected var _nc:NetConnection;
		
		private var _videoSource:String = null;
		private var _streamSource:String = null;
		private var _state:String = null;
		private var _autoPlay:Boolean = false;
		private var _smooth:Boolean = true;
		private var _currentTime:Number = 0;
		private var _autoScale:Boolean = true;
		protected var _duration:Number = 0;
		protected var _started:Boolean = false;
		protected var _defaultMargin:Number = 5;
		
		private var _bgVideo:Sprite;
		protected var _ppBtn:PlayButton;
		private var _stopBtn:StopButton;
		private var _eTime:ElapsedTime;
		protected var _bg:Sprite;
		protected var _videoBarPanel:UIComponent;
		protected var _sBar:ScrubberBar;
		protected var _audioSlider:AudioSlider;
		protected var _videoHeight:Number = 300;
		protected var _videoWidth:Number = 500;
		
		private var _timer:Timer;
		
		
		public function VideoPlayer(name:String = "VideoPlayer")
		{
			super(name);

			_skinableComponents = new Dictionary();
			
			_bg = new Sprite();
			
			_bgVideo = new Sprite();
			
			_video = new Video();
			_video.smoothing = _smooth;
			
			_videoWrapper = new MovieClip();
			_videoWrapper.addChild(_video);
			_videoWrapper.height = _videoHeight;
			
			_videoBarPanel = new UIComponent();
			
			_ppBtn = new PlayButton();
			_stopBtn = new StopButton();
			
			_videoBarPanel.addChild( _ppBtn );
			_videoBarPanel.addChild( _stopBtn );
			
			_sBar = new ScrubberBar();
			
			_videoBarPanel.addChild( _sBar );
			
			_eTime = new ElapsedTime();
			
			_videoBarPanel.addChild( _eTime );
			
			_audioSlider = new AudioSlider();
			
			_videoBarPanel.addChild( _audioSlider );
			
			//Event Listeners
			addEventListener( VideoPlayerEvent.VIDEO_SOURCE_CHANGED, onSourceChange );
			addEventListener( FlexEvent.CREATION_COMPLETE, onComplete );
			addEventListener( VideoPlayerEvent.VIDEO_FINISHED_PLAYING, onVideoFinishedPlaying );
			_ppBtn.addEventListener( PlayPauseEvent.STATE_CHANGED, onPPBtnChanged );
			_stopBtn.addEventListener( StopEvent.STOP_CLICK, onStopBtnClick );
			_audioSlider.addEventListener( VolumeEvent.VOLUME_CHANGED, onVolumeChange );
			
			/**
			 * Adds components to player
			 */
			addChild(_bg);
			addChild(_bgVideo);
			addChild( _videoWrapper );
			addChild(_videoBarPanel);
			
			/**
			 * Adds skinable components to dictionary
			 */
			putSkinableComponent(COMPONENT_NAME, this);
			putSkinableComponent(_audioSlider.COMPONENT_NAME, _audioSlider);
			putSkinableComponent(_eTime.COMPONENT_NAME, _eTime);
			putSkinableComponent(_ppBtn.COMPONENT_NAME, _ppBtn);
			putSkinableComponent(_sBar.COMPONENT_NAME, _sBar);
			putSkinableComponent(_stopBtn.COMPONENT_NAME, _stopBtn);
			
			// Loads default skin
			skin = "default";
		}
		
		
		/**
		 * Setters and Getters
		 * 
		 */
		[Bindable]
		public function set videoSource( location:String ):void
		{
			_videoSource = location;	
			dispatchEvent( new VideoPlayerEvent( VideoPlayerEvent.VIDEO_SOURCE_CHANGED ) );	
		}
		
		public function get videoSource( ):String
		{
			return _videoSource;
		}
		
		public function set streamSource( location:String ):void
		{
			_streamSource = location;
		}
		
		public function get streamSource( ):String
		{
			return _streamSource;
		}
		
		public function set autoPlay( tf:Boolean ):void
		{
			_autoPlay = tf;
		}
		
		public function get autoPlay( ):Boolean
		{
			return _autoPlay;
		}
		
		public function set videoSmooting( tf:Boolean ):void
		{
			_autoPlay = _smooth;
		}
		
		public function get videoSmooting( ):Boolean
		{
			return _smooth;
		}		
		
		public function set autoScale(flag:Boolean) : void
		{
			_autoScale = flag;
		}
		
		public function get autoScale() : Boolean
		{
			return _autoScale;
		}

		public function set seek(flag:Boolean) : void
		{
			if ( flag )
			{
				_sBar.addEventListener( ScrubberBarEvent.SCRUBBER_DROPPED, onScrubberDropped );
				_sBar.addEventListener( ScrubberBarEvent.SCRUBBER_DRAGGING, onScrubberDragging );
			}
			else
			{
				_sBar.removeEventListener( ScrubberBarEvent.SCRUBBER_DROPPED, onScrubberDropped );
				_sBar.removeEventListener( ScrubberBarEvent.SCRUBBER_DRAGGING, onScrubberDragging );
			}
			
			_sBar.enableSeek(flag);
		}
		
		/**
		 * Skin HashMap related commands
		 */
		protected function putSkinableComponent(name:String, cmp:SkinableComponent) : void
		{
			_skinableComponents[name] = cmp;
		}
		
		protected function getSkinableComponent(name:String) : SkinableComponent
		{
			return _skinableComponents[name];
		}
		
		public function setSkin(fileName:String) : void
		{
			skin = fileName;
		}
		
		/**
		 * Skin loader
		 */
		public function set skin(name:String) : void
		{
			
			var fileName:String = SKIN_PATH + name + ".xml";
			
			if ( _loadingSkin )
			{ // Maybe some skins will try to load at same time
			  // TODO: maybe this can be improved
				flash.utils.setTimeout(setSkin, 200, name);
				return;
			}
			
			var xmlURL:URLRequest = new URLRequest(fileName);
			_skinLoader = new URLLoader(xmlURL);
			_skinLoader.addEventListener(Event.COMPLETE, onSkinFileReaded);
			_skinLoader.addEventListener(IOErrorEvent.IO_ERROR, onSkinFileReadingError);
			_loadingSkin = true;
		}
		
		/**
		 * Parses Skin file
		 */
		public function onSkinFileReaded(e:Event) : void
		{
			var xml:XML = new XML(_skinLoader.data);
			
			for each ( var xChild:XML in xml.child("Component") )
			{
				var componentName:String = xChild.attribute("name").toString();
				var cmp:SkinableComponent = getSkinableComponent(componentName);
				
				if ( cmp == null )
					continue;
				
				for each ( var xElement:XML in xChild.child("Property") )
				{
					var propertyName:String = xElement.attribute("name").toString();
					var propertyColor:String = xElement.toString();
					
					cmp.setSkinColor(propertyName, new uint(propertyColor));
				}
			}
			
			updateDisplayList(0,0);
			_loadingSkin = false;
		}
		
		public function onSkinFileReadingError(e:Event) : void
		{
			_loadingSkin = false;
		}
		
		/** Overriden */
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList( unscaledWidth, unscaledHeight );
			
			this.graphics.clear();
			
			_bgVideo.graphics.clear();
			_bgVideo.graphics.beginFill( getSkinColor(VIDEOBG_COLOR) );
			_bgVideo.graphics.drawRoundRect( _defaultMargin, _defaultMargin, 
												_videoWidth, 
												_videoHeight,
												5, 5 );
			_bgVideo.graphics.endFill();
			
			_videoBarPanel.width = _videoWidth;
			_videoBarPanel.height = 20;
			_videoBarPanel.y = _defaultMargin + _videoHeight;
			_videoBarPanel.x = _defaultMargin;

			_ppBtn.refresh();

			_stopBtn.x = _ppBtn.x + _ppBtn.width;
			_stopBtn.refresh();
			
			_sBar.x = _stopBtn.x + _stopBtn.width;
			_sBar.refresh();
			
			_eTime.x = _sBar.x + _sBar.width;
			_eTime.refresh();

			_audioSlider.x = _eTime.x + _eTime.width;
			_audioSlider.refresh();
			
			_sBar.width = _videoBarPanel.width - _ppBtn.width - _stopBtn.width
							- _eTime.width - _audioSlider.width;
							
			drawBG();
		}
		
		override public function set width(w:Number) : void
		{
			totalWidth = w;
			_videoWidth = w - 2*_defaultMargin;
		}
		
		override public function set height(h:Number) : void
		{
			totalHeight = h;
			_videoHeight = h - 2*_defaultMargin;
		}
		
		protected function drawBG() : void
		{
			totalHeight =  _defaultMargin*2 + _videoHeight + _videoBarPanel.height;

			_bg.graphics.clear();

			_bg.graphics.beginFill( getSkinColor(BORDER_COLOR) );
			_bg.graphics.drawRoundRect( 0, 0, width, height, 15, 15 );
			_bg.graphics.endFill();
			_bg.graphics.beginFill( getSkinColor(BG_COLOR) );
			_bg.graphics.drawRoundRect( 3, 3, width-6, height-6, 12, 12 );
			_bg.graphics.endFill();
		}
		
		protected function set totalWidth(w:Number) : void
		{
			super.width = w;
		}
		
		protected function set totalHeight(h:Number) : void
		{
			super.height = h;
		}
		
		
		private function onComplete( e:FlexEvent ):void
		{
			_nc = new NetConnection();
			
			trace( _streamSource );
			
			if( _streamSource )
			{
				_nc.connect( _streamSource );
				_nc.addEventListener( NetStatusEvent.NET_STATUS, onStreamNetConnect );
				_nc.client = this;
			} else
			{
				_nc.connect( null );
				_nc.client = this;
				
				if( _autoPlay )
				{
					playVideo();
					_ppBtn.State = PlayButton.PAUSE_STATE;
				} 
			}
			
		}
		
		
		private function onStreamNetConnect( e:NetStatusEvent ):void
		{
			trace( "onStreamNetConnect" );
			
			if( e.info.code == "NetConnection.Connect.Success" )
			{
				trace( "successful connection" );			
				
				if( _autoPlay )
				{		
					playVideo();
					_ppBtn.State = PlayButton.PAUSE_STATE;
				}
				
				this.dispatchEvent(new VideoPlayerEvent(VideoPlayerEvent.CONNECTED));
				
			} else
			{
				Alert.show("Unsuccessful Connection", "Information");
				trace( "Connection Fail Code: " + e.info.code );
			}
		}
		
		
		private function netStatus( e:NetStatusEvent ):void
		{
			trace( "netStatus" );
			
			if( e.info.code == "NetStream.Play.StreamNotFound" )
			{
				Alert.show( "Stream Not Found", "Information" );
				trace( "Stream not found code: " + e.info.code + " for video " + _videoSource );
			} else if( e.info.code == "NetStream.Play.Stop" )
			{
				dispatchEvent( new VideoPlayerEvent( VideoPlayerEvent.VIDEO_FINISHED_PLAYING ) );
			}
			
			trace( "code: " + e.info.code, "level: " + e.info.level );
			
		}
		
		
		public function playVideo():void
		{
			if( !_nc.connected ) 
			{
				_ppBtn.State = PlayButton.PLAY_STATE;
				Alert.show( "Please wait for connection from server.", "ERROR" );
				return;
			}
									
			trace( "Video Started" );
			
			if ( _ns != null ) _ns.close();
			
			_ns = new NetStream( _nc );
			_ns.addEventListener( NetStatusEvent.NET_STATUS, netStatus );
			_ns.client = this;
			_ns.soundTransform = new SoundTransform( _audioSlider.getCurrentVolume() );	
			
			_video.attachNetStream( _ns );
			
			_ns.play( _videoSource );

			_started = true;
			
			if( _timer ) _timer.stop();
			_timer = new Timer(100);
			_timer.addEventListener( TimerEvent.TIMER, updateProgress );
			_timer.start();
		}
		
		
		public function stopVideo():void
		{
			if( _ns )
			{ 
				_ns.pause();
				_ns.seek( 0 );
				_ppBtn.State = PlayButton.PLAY_STATE;
			}
		}
		
		
		public function pauseVideo():void
		{
			if( _ns )
			{
				_ns.pause();
			}
		}
		
		public function resumeVideo():void
		{
			if( _ns )
			{ 
				_ns.seek( _currentTime );
				_ns.resume();
				trace( _currentTime, _ns.time );
			}
		}
		
		
		public function onPlayStatus( e:Object ):void
		{
			trace( e );
		}
		
		
		public function onMetaData( msg:Object ):void
		{
			trace( "metadata: " );
				
			for ( var a:* in msg ) trace( a + " : " + msg[a] );

			_duration = msg.duration;
			_video.width = msg["width"];
			_video.height = msg["height"];
			
			this.dispatchEvent(new VideoPlayerEvent(
									VideoPlayerEvent.METADATA_RETRIEVED));
			
			_videoWrapper.width = _videoWidth;
			_videoWrapper.height = _videoHeight;
			_videoWrapper.x = _defaultMargin;
			_videoWrapper.y = _defaultMargin;
			drawBG();

			if ( !autoScale )
			{
				scaleVideo();
			}
		}
		
		
		public function onSourceChange( e:VideoPlayerEvent ):void
		{
			trace( "source has changed" );
			trace( e.currentTarget );
			
			if( _ns ) 
			{
				playVideo();
			}
		}
		
		
		public function onPPBtnChanged( e:PlayPauseEvent ):void
		{
			if( _ppBtn.getState() == PlayButton.PAUSE_STATE )
			{
				if( _ns )
				{
					resumeVideo();
				} else
				{
					playVideo();
				}
				
			} else
			{
				pauseVideo();
			}
		}
		
		
		private function onStopBtnClick( e:StopEvent ):void
		{
			stopVideo();
		}
		
		
		private function updateProgress( e:TimerEvent ):void
		{
			if( !_ns ) return; //Fail safe in case someone drags the scrubber.
			
			_currentTime = _ns.time;
			_sBar.updateProgress( _currentTime, _duration );
			
			// if not streaming show loading progress
			if( !_streamSource ) _sBar.updateLoaded(  _ns.bytesLoaded / _ns.bytesTotal );
			
			_eTime.updateElapsedTime( _currentTime, _duration );
		}
		
		/**
		 * Seek & Resume video when scrubber stops dragging
		 * or when progress bar has been clicked
		 */
		private function onScrubberDropped( e:Event ):void
		{
			if( !_ns ) return;
			
			_timer.stop();
			_ns.seek( _sBar.seekPosition( _duration ) );
			
			if ( _state == PlayButton.PAUSE_STATE ) // before seek was playing, so resume video
			{
				_ppBtn.State = PlayButton.PAUSE_STATE;
				_ns.resume();
			}
			
			_timer.start();
		}
		
		/**
		 * Pauses video when scrubber starts dragging
		 **/
		private function onScrubberDragging( e:Event ) : void
		{
			if( !_ns ) return;
			
			_state = _ppBtn.getState();
			
			if ( _ppBtn.getState() == PlayButton.PAUSE_STATE ) // do pause
			{
				_ppBtn.State = PlayButton.PLAY_STATE;
				_ns.pause();
				_timer.stop();
			}
		}
		
		
		protected function onVideoFinishedPlaying( e:VideoPlayerEvent ):void
		{
			
			stopVideo();
			
			dispatchEvent(e);
			
			// This code unloads the video - Not Used but kept in for future
			// in case we want to unload the video
			/* _ppBtn.State = "play";
			_ns.close();
			_timer.stop();
			_ns = null; */
		}
		
		
		
		private function onVolumeChange( e:VolumeEvent ):void
		{
			if( !_ns ) return;
			
			_ns.soundTransform = new SoundTransform( e.volumeAmount );
			
			trace( _ns.soundTransform.volume, e.volumeAmount );
		}
		
		
		protected function scaleVideo() : void
		{
			_videoWrapper.scaleX > _videoWrapper.scaleY ? _videoWrapper.scaleX = _videoWrapper.scaleY : _videoWrapper.scaleY = _videoWrapper.scaleX;
			_video.x = _videoWidth/2 - (_video.width * _videoWrapper.scaleX)/2;
			_video.y = _videoHeight/2 - (_video.height * _videoWrapper.scaleY)/2;
		}
	}
}