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
	import modules.videoPlayer.controls.SubtitleTextBox;
	import modules.videoPlayer.controls.LocaleComboBox;
	import modules.videoPlayer.controls.SubtitleButton;
	import modules.videoPlayer.controls.ArrowPanel;
	import modules.videoPlayer.events.PlayPauseEvent;
	import modules.videoPlayer.events.ScrubberBarEvent;
	import modules.videoPlayer.events.StopEvent;
	import modules.videoPlayer.events.VideoPlayerEvent;
	import modules.videoPlayer.events.VolumeEvent;
	import modules.videoPlayer.events.SubtitleButtonEvent;
	import modules.videoPlayer.events.SubtitleComboEvent;
	
	import model.DataModel;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.Timer;
	
	import mx.controls.Alert;
	import mx.containers.Panel;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.utils.ArrayUtil;
	import mx.collections.ArrayCollection;
	import mx.controls.Button;
	import mx.effects.AnimateProperty;

	public class VideoPlayer extends UIComponent
	{
		
		/**
		 * Variables
		 * 
		 */
		
		private var _video:Video;
		private var _videoWrapper:MovieClip;
		private var _ns:NetStream;
		private var _nc:NetConnection;
		
		private var _videoSource:String = null;
		private var _streamSource:String = null;
		private var _state:String = null;
		private var _autoPlay:Boolean = false;
		private var _smooth:Boolean = true;
		private var _currentTime:Number = 0;
		private var _duration:Number = 0;
		private var _autoScale:Boolean = true;
		private var _defaultMargin:Number = 5;
		
		private var _bg:Sprite;
		private var _bgVideo:Sprite;
		private var _videoBarPanel:UIComponent;
		private var _ppBtn:PlayButton;
		private var _stopBtn:StopButton;
		private var _sBar:ScrubberBar;
		private var _eTime:ElapsedTime;
		private var _audioSlider:AudioSlider;
		private var _subtitleButton:SubtitleButton;
		private var _subtitlePanel:UIComponent;
		private var _subtitleBox:SubtitleTextBox;
		private var _localeComboBox:LocaleComboBox;
		private var _arrowContainer:UIComponent;
		private var _arrowPanel:ArrowPanel;
		private var _bgArrow:Sprite;
		private const _videoHeight:Number = 300;
		
		private var _timer:Timer;
		
		
		public function VideoPlayer()
		{
			super();
			
			_bg = new Sprite();
			addChild(_bg);
			
			_bgVideo = new Sprite();
			addChild(_bgVideo);
			
			_video = new Video();
			_video.width = width - _defaultMargin*2;
			_video.height = height - _defaultMargin*2;
			_video.smoothing = _smooth;
			
			_videoWrapper = new MovieClip();
			_videoWrapper.addChild(_video);
			_videoWrapper.height = _videoHeight;
			
			addChild( _videoWrapper );
			
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
			
			_subtitleButton = new SubtitleButton(true);
			
			_videoBarPanel.addChild( _subtitleButton );
			
			_subtitlePanel = new UIComponent();
			_subtitlePanel.visible = false;
			_subtitleBox = new SubtitleTextBox();
			_subtitleBox.setText("PRUEBA DE SUBTITULOS");
			_subtitlePanel.addChild( _subtitleBox );
			_localeComboBox = new LocaleComboBox();
			_localeComboBox.setDataProvider(new ArrayCollection(
									ArrayUtil.toArray(DataModel.getInstance().locales)));
			_subtitlePanel.addChild( _localeComboBox );
			
			_arrowContainer = new UIComponent();
			
			_bgArrow = new Sprite();
			
			_arrowContainer.addChild(_bgArrow);
			_arrowPanel = new ArrowPanel();
			_arrowContainer.visible = false;
			_arrowContainer.addChild(_arrowPanel);
			
			addChild(_subtitlePanel);
			addChild(_arrowContainer);
			addChild(_videoBarPanel);
			
			//Event Listeners
			addEventListener( VideoPlayerEvent.VIDEO_SOURCE_CHANGED, onSourceChange );
			addEventListener( FlexEvent.CREATION_COMPLETE, onComplete );
			addEventListener( VideoPlayerEvent.VIDEO_FINISHED_PLAYING, onVideoFinishedPlaying );
			_ppBtn.addEventListener( PlayPauseEvent.STATE_CHANGED, onPPBtnChanged );
			_stopBtn.addEventListener( StopEvent.STOP_CLICK, onStopBtnClick );
			_audioSlider.addEventListener( VolumeEvent.VOLUME_CHANGED, onVolumeChange );
			_subtitleButton.addEventListener( SubtitleButtonEvent.STATE_CHANGED, onSubtitleButtonClicked);
			_localeComboBox.addEventListener( SubtitleComboEvent.SELECTED_CHANGED, onLocaleChanged);
		}
		
		
		/**
		 * Setters and Getters
		 * 
		 */
		[Bindable]
		public function set VideoSource( location:String ):void
		{
			_videoSource = location;	
			dispatchEvent( new VideoPlayerEvent( VideoPlayerEvent.VIDEO_SOURCE_CHANGED ) );	
		}
		
		public function get VideoSource( ):String
		{
			return _videoSource;
		}
		
		public function set StreamSource( location:String ):void
		{
			_streamSource = location;
		}
		
		public function get StreamSource( ):String
		{
			return _streamSource;
		}
		
		public function set AutoPlay( tf:Boolean ):void
		{
			_autoPlay = tf;
		}
		
		public function get AutoPlay( ):Boolean
		{
			return _autoPlay;
		}
		
		public function set VideoSmooting( tf:Boolean ):void
		{
			_autoPlay = _smooth;
		}
		
		public function get VideoSmooting( ):Boolean
		{
			return _smooth;
		}
		
		public function setSubtitle(text:String) : void
		{
			_subtitleBox.setText(text);
		}
		
		public function set Subtitles(flag:Boolean) : void
		{
			_subtitlePanel.visible = flag;
			_subtitleButton.setEnabled(flag);
		}
		
		public function setArrows(arrows:Array, role:String) : void
		{
			_arrowPanel.setArrows(arrows, _duration, role);
		}
		
		public function removeArrows() : void
		{
			_arrowPanel.removeArrows();
		}
		
		
		public function set Arrows(flag:Boolean) : void
		{
			_arrowContainer.visible = flag;
		}
		
		public function set AutoScale(flag:Boolean) : void
		{
			_autoScale = flag;
		}

		public function set Seek(flag:Boolean) : void
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
		
		public function setLocales(locales:ArrayCollection) : void
		{
			_localeComboBox.setDataProvider(locales);
		}
		
		
		
		/**
		 * Methods
		 * 
		 */
		
		/** Overriden */
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList( unscaledWidth, unscaledHeight );
			
			this.graphics.clear();

			_bgVideo.graphics.beginFill( 0x000000 );
			_bgVideo.graphics.drawRoundRect( _defaultMargin, _defaultMargin, 
												width - _defaultMargin*2, 
												_videoHeight,
												5, 5 );
			_bgVideo.graphics.endFill();
			
			_videoBarPanel.width = width - _defaultMargin*2;
			_videoBarPanel.height = 20;
			_videoBarPanel.y = height - _videoBarPanel.height - _defaultMargin;
			_videoBarPanel.x = _defaultMargin;
			
			_arrowContainer.width = _videoBarPanel.width;
			_arrowContainer.height = 50;
			_arrowContainer.y = _videoBarPanel.y - 50;
			_arrowContainer.x = _defaultMargin;
			_bgArrow.graphics.beginFill( 0x000000 );
			_bgArrow.graphics.drawRect( 0, 0, _arrowContainer.width, _arrowContainer.height );
			_bgArrow.graphics.endFill();
			_bgArrow.graphics.beginFill( 0x454545 );
			_bgArrow.graphics.drawRect( 1, 1, _arrowContainer.width-2, _arrowContainer.height-2 );
			_bgArrow.graphics.endFill();

			_stopBtn.x = _ppBtn.x + _ppBtn.width;
			
			_sBar.x = _stopBtn.x + _stopBtn.width;;
			_sBar.width = 312;
			
			_eTime.x = _sBar.x + _sBar.width;

			_audioSlider.x = _eTime.x + _eTime.width;
			
			_subtitleButton.x = _audioSlider.x + _audioSlider.width;
			_subtitleButton.resize(this.width - _audioSlider.x - _audioSlider.width - 2*_defaultMargin, 20);
			
			// Put subtitle box at top
			var y2:Number = _arrowContainer.visible? _arrowContainer.height : 0;
			_subtitlePanel.y = _videoBarPanel.y - 20 - y2;
			_subtitlePanel.width = _videoBarPanel.width;
			_subtitlePanel.height = 20;
			_subtitlePanel.x = _defaultMargin;

			_subtitleBox.resize(this.width - 100, 20);
			
			// Resize arrowPanel
			_arrowPanel.resize(_sBar.width, _arrowContainer.height - 8);
			_arrowPanel.x = _sBar.x;
			_arrowPanel.y = 4;
			
			_localeComboBox.x = _subtitleBox.x + _subtitleBox.width;
			_localeComboBox.resize(this.width - _subtitleBox.width - 2*_defaultMargin, _subtitleBox.height);
			
			
			drawBG();
		}
		
		private function drawBG() : void
		{
			/**
			 * Recalculate height
			 */
			var h1:Number = _subtitlePanel.visible? _subtitlePanel.height : 0;
			var h2:Number = _arrowContainer.visible? _arrowContainer.height : 0;
			height = _defaultMargin*2 + _videoWrapper.height + h1 + h2;

			_bg.graphics.clear();

			_bg.graphics.beginFill( 0x000000 );
			_bg.graphics.drawRoundRect( 0, 0, width, height, 15, 15 );
			_bg.graphics.endFill();
			_bg.graphics.beginFill( 0x343434 );
			_bg.graphics.drawRoundRect( 3, 3, width-6, height-6, 12, 12 );
			_bg.graphics.endFill();
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
					_ppBtn.State = "pause";
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
					_ppBtn.State = "pause";
				} 
				
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
				_ppBtn.State = "play";
				Alert.show( "Please wait for connection from server.", "ERROR" );
				return;
			}
									
			trace( "Video Started" );
			
			if( _ns != null ) _ns.close();
			
			_ns = new NetStream( _nc );
			_ns.addEventListener( NetStatusEvent.NET_STATUS, netStatus );
			
			_ns.client = this;
			_ns.soundTransform = new SoundTransform( _audioSlider.getCurrentVolume() ); 
			
			_video.attachNetStream( _ns );
			
			_ns.play( _videoSource );
			
			if( _timer ) _timer.stop();
			_timer = new Timer(500);
			_timer.addEventListener( TimerEvent.TIMER, updateProgress );
			_timer.start();
		}
		
		
		public function stopVideo():void
		{
			if( _ns )
			{ 
				_ns.pause();
				_ns.seek( 0 );
				_ppBtn.State = "play";
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
			
			_videoWrapper.width = width - _defaultMargin*2;
			_videoWrapper.height = _videoHeight;
			// Dont remove this lines
			var w:Number = _videoWrapper.width;
			var h:Number = _videoWrapper.height;
			_videoWrapper.x = _defaultMargin;
			_videoWrapper.y = _defaultMargin;
			drawBG();

			if ( !_autoScale )
			{
				_videoWrapper.scaleX > _videoWrapper.scaleY ? _videoWrapper.scaleX = _videoWrapper.scaleY : _videoWrapper.scaleY = _videoWrapper.scaleX;
				_video.x = w/2 - (_video.width * _videoWrapper.scaleX)/2;
				_video.y = h/2 - (_video.height * _videoWrapper.scaleY)/2;
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
			if( _ppBtn.getState() == "pause" )
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
		 */
		private function onScrubberDropped( e:Event ):void
		{
			if( !_ns ) return;
			
			_timer.stop();
			_ns.seek( _sBar.seekPosition( _duration ) );
			
			if ( _state == "pause" ) // before seek was playing, so resume video
			{
				_ppBtn.State = "play";
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
			
			if ( _ppBtn.getState() == "pause" ) // do pause
			{
				_ppBtn.State = "play";
				_ns.pause();
				_timer.stop();
			}
		}
		
		/**
		 * Catch event and do show/hide subtitle panel
		 */
		private function onSubtitleButtonClicked( e:SubtitleButtonEvent ) : void
		{
			if ( e.state == "enabled" )
				doShowSubtitlePanel();
			else
				doHideSubtitlePanel();
		}
		
		/**
		 * Subtitle Panel's show animation
		 */
		private function doShowSubtitlePanel() : void
		{
			_subtitlePanel.visible = true;
			var a1:AnimateProperty = new AnimateProperty();
			a1.target = _videoBarPanel;
			a1.property = "y";
			a1.toValue = _videoBarPanel.y + _subtitlePanel.height;
			a1.duration = 250;
			a1.play();
			
			var a2:AnimateProperty = new AnimateProperty();
			a2.target = _arrowContainer;
			a2.property = "y";
			a2.toValue = _arrowContainer.y + _subtitlePanel.height;
			a2.duration = 250;
			a2.play();
			
			drawBG(); // Repaint bg
		}
		
		/**
		 * Subtitle Panel's hide animation
		 */
		private function doHideSubtitlePanel() : void
		{
			_subtitlePanel.visible = false;
			var a1:AnimateProperty = new AnimateProperty();
			a1.target = _videoBarPanel;
			a1.property = "y";
			a1.toValue = _videoBarPanel.y - _subtitlePanel.height;
			a1.duration = 250;
			a1.play();
			
			var a2:AnimateProperty = new AnimateProperty();
			a2.target = _arrowContainer;
			a2.property = "y";
			a2.toValue = _arrowContainer.y - _subtitlePanel.height;
			a2.duration = 250;
			a2.play();
			
			drawBG(); // Repaint bg
		}
		
		// This gives the event to parent component
		private function onLocaleChanged(e:SubtitleComboEvent) : void
		{
			this.dispatchEvent(e);
		}
		
		
		private function onVideoFinishedPlaying( e:Event ):void
		{
			
			stopVideo();
			
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
		
	}
}