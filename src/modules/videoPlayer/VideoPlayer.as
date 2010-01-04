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
	import modules.videoPlayer.events.PlayPauseEvent;
	import modules.videoPlayer.events.ScrubberBarEvent;
	import modules.videoPlayer.events.StopEvent;
	import modules.videoPlayer.events.VideoPlayerEvent;
	import modules.videoPlayer.events.VolumeEvent;
	
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
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.utils.ArrayUtil;
	import mx.collections.ArrayCollection;

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
		private var _autoPlay:Boolean = false;
		private var _smooth:Boolean = true;
		private var _currentTime:Number = 0;
		private var _duration:Number = 0;
		
		private var _ppBtn:PlayButton;
		private var _stopBtn:StopButton;
		private var _sBar:ScrubberBar;
		private var _eTime:ElapsedTime;
		private var _audioSlider:AudioSlider;
		private var _subtitleBox:SubtitleTextBox;
		private var _localeComboBox:LocaleComboBox;
		
		private var _timer:Timer;
		
		
		public function VideoPlayer()
		{
			super();		
			
			this.height += 40;				
			
			_video = new Video();
			_video.width = width;
			_video.height = height;
			_video.smoothing = _smooth;
			
			_videoWrapper = new MovieClip();
			_videoWrapper.addChild( _video );
			
			addChild( _videoWrapper );
			
			_ppBtn = new PlayButton();
			_stopBtn = new StopButton();
			
			addChild( _ppBtn );
			addChild( _stopBtn );
			
			_sBar = new ScrubberBar();
			
			addChild( _sBar );
			
			_eTime = new ElapsedTime();
			
			addChild( _eTime );
			
			
			_audioSlider = new AudioSlider();
			
			addChild( _audioSlider );
			
			_subtitleBox = new SubtitleTextBox();
			_subtitleBox.setText("PRUEBA DE SUBTITULOS");

			addChild( _subtitleBox );
			
			_localeComboBox = new LocaleComboBox();
			_localeComboBox.setDataProvider(new ArrayCollection(
									ArrayUtil.toArray(DataModel.getInstance().locales)));
			addChild( _localeComboBox );
			
			
			//Event Listeners
			addEventListener( VideoPlayerEvent.VIDEO_SOURCE_CHANGED, onSourceChange );
			addEventListener( FlexEvent.CREATION_COMPLETE, onComplete );
			addEventListener( VideoPlayerEvent.VIDEO_FINISHED_PLAYING, onVideoFinishedPlaying );
			_ppBtn.addEventListener( PlayPauseEvent.STATE_CHANGED, onPPBtnChanged );
			_stopBtn.addEventListener( StopEvent.STOP_CLICK, onStopBtnClick );
			_sBar.addEventListener( ScrubberBarEvent.SCRUBBER_DROPPED, onScrubberDropped );
			_sBar.addEventListener( ScrubberBarEvent.SCRUBBER_DRAGGING, onScrubberDragging );
			_audioSlider.addEventListener( VolumeEvent.VOLUME_CHANGED, onVolumeChange );
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
		
		
		
		
		/**
		 * Methods
		 * 
		 */
		
		/** Overriden */
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList( unscaledWidth, unscaledHeight );
			
			this.graphics.clear();
			
			var bg:Sprite = new Sprite();
			bg.graphics.beginFill( 0x000000 );
			bg.graphics.drawRect( 0, 0, this.width, this.height-20 );
			bg.graphics.endFill();
			
			this.addChildAt( bg, 0 );
			
			
			_ppBtn.y = this.height - _ppBtn.height;
			_stopBtn.x = _ppBtn.x + _ppBtn.width;
			_stopBtn.y = _ppBtn.y;
			
			_sBar.x = _stopBtn.x + _stopBtn.width;
			_sBar.y = _stopBtn.y;
			_sBar.width = 355;
			
			_eTime.x = _sBar.x + _sBar.width;
			_eTime.y = _sBar.y;
			
			
			_audioSlider.x = _eTime.x + _eTime.width;
			_audioSlider.y = _eTime.y;
			
			// Put subtitle box at top
			_subtitleBox.x = 0;
			_subtitleBox.y = _ppBtn.y - 20;
			_subtitleBox.resize(this.width - 100, 20);
			
			_localeComboBox.x = _subtitleBox.x + _subtitleBox.width;
			_localeComboBox.y = _subtitleBox.y;
			_localeComboBox.resize(this.width - _subtitleBox.width, _subtitleBox.height);
			
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
			_ns.soundTransform = new SoundTransform( _audioSlider.CurrentVolume ); 
			
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
			
			_videoWrapper.width = this.width;
			_videoWrapper.height = this.height - 40;
			
			/* AUTOSCALE
			 *_videoWrapper.scaleX > _videoWrapper.scaleY ? _videoWrapper.scaleX = _videoWrapper.scaleY : _videoWrapper.scaleY = _videoWrapper.scaleX;
			 *_video.x = this.width/2 - (_video.width * _videoWrapper.scaleX)/2;
			 *_video.y = this.height/2 - (_video.height * _videoWrapper.scaleY)/2 - 10;
			 */
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
			if( _ppBtn.State == "pause" )
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
			if( !_streamSource ) _sBar.updateLoaded( Math.ceil( _ns.bytesLoaded / _ns.bytesTotal ) );
			
			_eTime.updateElapsedTime( _currentTime, _duration );
		}
		
		
		private function onScrubberDropped( e:Event ):void
		{
			if( !_ns ) return;
			
			_timer.stop();
			_ns.seek( _sBar.SeekPosition( _duration ) );
			_ns.resume();
			_timer.start();
		}
		
		private function onScrubberDragging( e:Event ) : void
		{
			if( !_ns ) return;
			
			_ns.pause();
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