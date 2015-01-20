/**
 * NOTES
 *
 * Player needs a way to tell if a video exsists when streaming video.
 */

package components.videoPlayer
{
	
	import components.videoPlayer.controls.AudioSlider;
	import components.videoPlayer.controls.BitmapSprite;
	import components.videoPlayer.controls.ElapsedTime;
	import components.videoPlayer.controls.ErrorSprite;
	import components.videoPlayer.controls.PlayButton;
	import components.videoPlayer.controls.ScrubberBar;
	import components.videoPlayer.controls.SkinableComponent;
	import components.videoPlayer.controls.StopButton;
	import components.videoPlayer.controls.XMLSkinableComponent;
	import components.videoPlayer.events.MediaStatusEvent;
	import components.videoPlayer.events.PlayPauseEvent;
	import components.videoPlayer.events.ScrubberBarEvent;
	import components.videoPlayer.events.StopEvent;
	import components.videoPlayer.events.VideoPlayerEvent;
	import components.videoPlayer.events.VolumeEvent;
	import components.videoPlayer.media.AMediaManager;
	import components.videoPlayer.media.ARTMPManager;
	import components.videoPlayer.media.AVideoManager;
	
	import events.FullStreamingEvent;
	
	import flash.display.Sprite;
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.getQualifiedClassName;
	
	import model.DataModel;
	
	import mx.binding.utils.BindingUtils;
	import mx.controls.Alert;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;
	
	import view.BusyIndicator;

	public class VideoPlayer extends XMLSkinableComponent
	{
		protected static const logger:ILogger = getLogger(VideoPlayer);
		
		public static const BG_COLOR:String="bgColor";
		public static const BORDER_COLOR:String="borderColor";
		public static const VIDEOBG_COLOR:String="videoBgColor";

		protected const DEFAULT_VOLUME:Number=70;
		
		protected var _video:Video;

		private var _state:String=null;
		
		protected var _smooth:Boolean=true;
		protected var _autoScale:Boolean=true;
		protected var _currentTime:Number=0;
		protected var _autoPlay:Boolean=false;
		protected var _lastAutoplay:Boolean;
		protected var _duration:Number=0;
		protected var _started:Boolean=false;
		protected var _defaultMargin:Number=0;

		private var _bgVideo:Sprite;
		public var _ppBtn:PlayButton;
		public var _stopBtn:StopButton;
		
		protected var _eTime:ElapsedTime;
		protected var _bg:Sprite;
		protected var _playerControls:UIComponent;
		protected var _sBar:ScrubberBar;
		protected var _audioSlider:AudioSlider;
		protected var _videoHeight:Number=200;
		protected var _videoWidth:Number=320;
		
		protected var _videoDisplayWidth:Number;
		protected var _videoDisplayHeight:Number;
		
		protected var _mediaPosterUrl:String;
		protected var _topLayer:Sprite;
		protected var _posterSprite:BitmapSprite;
		protected var _errorSprite:ErrorSprite;
		protected var _media:AMediaManager;
		protected var _mediaUrl:String;
		protected var _mediaNetConnectionUrl:String;
		protected var _mediaReady:Boolean;
		protected var _currentVolume:Number;
		protected var _lastVolume:Number;
		protected var _muted:Boolean=false;
		protected var _forcePlay:Boolean;
		protected var _videoPlaying:Boolean;
		protected var _lastWidth:int;
		protected var _lastHeight:int;
		
		
		protected var _busyIndicator:BusyIndicator;
		

		/**
		 * CONSTRUCTOR
		 **/
		public function VideoPlayer(name:String="VideoPlayer")
		{
			super(name);
			
			_currentVolume=DEFAULT_VOLUME;
			_lastVolume=DEFAULT_VOLUME;

			_bg=new Sprite();
			_bgVideo=new Sprite();
			_topLayer=new Sprite();
			_video=new Video();
			_video.smoothing=_smooth;
			
			_busyIndicator=new BusyIndicator();
			_busyIndicator.width=48;
			_busyIndicator.height=48;
			_busyIndicator.visible=false;

			_playerControls=new UIComponent();

			_ppBtn=new PlayButton();
			_stopBtn=new StopButton();
			_sBar=new ScrubberBar();
			_eTime=new ElapsedTime();
			_audioSlider=new AudioSlider(_currentVolume);
			
			_playerControls.addChild(_ppBtn);
			_playerControls.addChild(_stopBtn);
			_playerControls.addChild(_sBar);
			_playerControls.addChild(_eTime);
			_playerControls.addChild(_audioSlider);
			
			_errorSprite=new ErrorSprite(null, width, height);

			//Event Listeners
			addEventListener(VideoPlayerEvent.VIDEO_SOURCE_CHANGED, onSourceChange, false, 0, true);
			addEventListener(FlexEvent.CREATION_COMPLETE, onComplete, false, 0, true);
			addEventListener(VideoPlayerEvent.VIDEO_FINISHED_PLAYING, onVideoFinishedPlaying, false, 0, true);
			_ppBtn.addEventListener(MouseEvent.CLICK, onPPBtnChanged, false, 0, true);
			_stopBtn.addEventListener(StopEvent.STOP_CLICK, onStopBtnClick, false, 0 , true);
			_audioSlider.addEventListener(VolumeEvent.VOLUME_CHANGED, onVolumeChange, false, 0, true);

			addChild(_bg);
			addChild(_bgVideo);
			addChild(_video);
			addChild(_playerControls);
			addChild(_topLayer);
			addChild(_busyIndicator);

			/**
			 * Adds skinable components to dictionary
			 */
			putSkinableComponent(COMPONENT_NAME, this);
			putSkinableComponent(_audioSlider.COMPONENT_NAME, _audioSlider);
			putSkinableComponent(_eTime.COMPONENT_NAME, _eTime);
			putSkinableComponent(_ppBtn.COMPONENT_NAME, _ppBtn);
			putSkinableComponent(_sBar.COMPONENT_NAME, _sBar);
			putSkinableComponent(_stopBtn.COMPONENT_NAME, _stopBtn);
		}
		
		public function loadVideoByUrl(param:Object):void{
			var parsedMedia:Object = parseMediaObject(param);
			if(parsedMedia){
				_mediaNetConnectionUrl=parsedMedia.netConnectionUrl;
				_mediaUrl=parsedMedia.mediaUrl;
				_mediaPosterUrl=parsedMedia.mediaPosterUrl;
				loadVideo();
			}
		}
		
		protected function parseMediaObject(param:Object):Object{
			var mediaObj:Object = new Object();
			var netConnectionUrl:String;
			var mediaUrl:String;
			var mediaPosterUrl:String;
			if(getQualifiedClassName(param) == 'Object')
			{
				if(!param.mediaUrl){
					return null;
				}
				mediaUrl=param.mediaUrl;
				mediaPosterUrl= param.mediaPosterUrl || null;
				netConnectionUrl = param.netConnectionUrl || null;
			}
			else if (param is String)
			{
				mediaUrl=String(param) || null;
			} else {
				return null;
			}
			
			mediaObj.netConnectionUrl=netConnectionUrl;
			mediaObj.mediaUrl=mediaUrl;
			mediaObj.mediaPosterUrl=mediaPosterUrl;
			
			return mediaObj;
		}
		
		protected function loadVideo():void{
			_mediaReady=false;
			logger.info("Load video: {0}",[_mediaNetConnectionUrl+'/'+_mediaUrl]); 
			if (_mediaUrl != '')
			{
				
				_busyIndicator.visible=true;
				resetAppearance();
		
				if(!_autoPlay){
					if(_mediaPosterUrl){
						_posterSprite = new BitmapSprite(_mediaPosterUrl, _lastWidth, _lastHeight);
						_topLayer.addChild(_posterSprite);
					}
				}
				
				if (streamReady(_media))
				{
					_media.netStream.dispose();
				}
				
				_media=null;
				if(_mediaNetConnectionUrl){
					_media=new ARTMPManager("playbackStream");
					_media.addEventListener(MediaStatusEvent.STREAM_SUCCESS, onStreamSuccess, false, 0, true);
					_media.addEventListener(MediaStatusEvent.STREAM_FAILURE, onStreamFailure, false, 0, true);
					_media.setup(_mediaNetConnectionUrl, _mediaUrl);
				} else {
					_media=new AVideoManager("playbackStream");
					_media.addEventListener(MediaStatusEvent.STREAM_SUCCESS, onStreamSuccess, false, 0, true);
					_media.addEventListener(MediaStatusEvent.STREAM_FAILURE, onStreamFailure, false, 0, true);
					_media.setup(_mediaUrl);
				}		
			}
		}
		
		protected function streamReady(stream:AMediaManager):Boolean{
			return stream && stream.netStream;
		}
		
		protected function onStreamSuccess(event:Event):void{
			var evt:Object=Object(event);
				
			_video.attachNetStream(_media.netStream);
			_video.visible=true;
			_media.volume=_currentVolume;
			_media.addEventListener(MediaStatusEvent.METADATA_RETRIEVED, onMetaData, false, 0, true);
			_media.addEventListener(MediaStatusEvent.STATE_CHANGED, onStreamStateChange, false, 0, true);
			if (_mediaUrl != '')
			{
				_mediaReady=true;
				if (_autoPlay || _forcePlay)
				{
					startVideo();
					_forcePlay=false;
				}
			}
		}
		
		protected function onStreamFailure(event:Event):void{
			var evt:Object=Object(event);
			_errorSprite.setLocaleAwareErrorMessage(evt.message);
			_topLayer.removeChildren();
			_topLayer.addChild(_errorSprite);		
			_busyIndicator.visible=false;
			invalidateDisplayList();
		}
		
		protected function onStreamStateChange(event:MediaStatusEvent):void{
			_busyIndicator.visible=false;
			if (event.state == AMediaManager.STREAM_FINISHED)
			{
				_video.clear();
				_videoPlaying=false;
				_sBar.updateProgress(0,_duration);
				_ppBtn.state=PlayButton.PLAY_STATE;
				trace("["+event.streamid+"] Stream Finished");
			}
			if (event.state == AMediaManager.STREAM_STARTED)
			{
				_videoPlaying=true;
				_ppBtn.state=PlayButton.PAUSE_STATE;
			}
			
			if(event.state == AMediaManager.STREAM_PAUSED){
				
				_ppBtn.state=PlayButton.PLAY_STATE;
			}
			
			if(event.state == AMediaManager.STREAM_BUFFERING){
				_busyIndicator.visible=true;
			}
			
			if(event.state == AMediaManager.STREAM_SEEKING_START){
				//
			}
			
			//dispatchEvent(new VideoPlayerEvent(VideoPlayerEvent.STREAM_STATE_CHANGED, event.state));
		}
		
		protected function startVideo():void{
			if (!_mediaReady)
				return;
			try
			{
				_media.play();
			}
			catch (e:Error)
			{
				_mediaReady=false;
				//logger.error("Error while loading video. [{0}] {1}", [e.errorID, e.message]);
			}
		}
		

		public function set autoPlay(value:Boolean):void
		{
			_autoPlay=value;
		}

		public function get autoPlay():Boolean
		{
			return _autoPlay;
		}

		public function set videoSmooting(value:Boolean):void
		{
			_smooth=value;
		}

		public function get videoSmooting():Boolean
		{
			return _smooth;
		}

		public function set autoScale(value:Boolean):void
		{
			_autoScale=value;
		}

		public function get autoScale():Boolean
		{
			return _autoScale;
		}

		/**
		 * Seek
		 */
		public function set seek(flag:Boolean):void
		{
			if (flag)
			{
				_sBar.addEventListener(ScrubberBarEvent.SCRUBBER_DROPPED, onScrubberDropped, false, 0, true);
				_sBar.addEventListener(ScrubberBarEvent.SCRUBBER_DRAGGING, onScrubberDragging, false, 0, true);
			}
			else
			{
				_sBar.removeEventListener(ScrubberBarEvent.SCRUBBER_DROPPED, onScrubberDropped);
				_sBar.removeEventListener(ScrubberBarEvent.SCRUBBER_DRAGGING, onScrubberDragging);
			}

			_sBar.enableSeek(flag);
		}

		public function seekTo(seconds:Number):void
		{
			this.onScrubberDragging(null);
			_sBar.updateProgress(seconds, _duration);
			this.onScrubberDropped(null);
		}

		/**
		 * Enable/disable controls
		 **/
		public function set controlsEnabled(flag:Boolean):void
		{
			flag ? enableControls() : disableControls();

		}

		public function toggleControls():void
		{
			(_ppBtn.enabled) ? disableControls() : enableControls();
		}

		public function enableControls():void
		{
			_ppBtn.enabled=true;
			_stopBtn.enabled=true;
		}

		public function disableControls():void
		{
			_ppBtn.enabled=false;
			_stopBtn.enabled=false;
		}

		/**
		 * Duration
		 */
		public function get duration():Number
		{
			return _duration;
		}
		
		public function get mute():Boolean
		{
			return _muted;
		}
		
		public function set mute(value:Boolean):void
		{
			_muted=value;
			var newVolume:Number;
			if (value)
			{
				//Store the volume that we had before muting to restore to that volume when unmuting
				_lastVolume=_currentVolume;
				newVolume=0;
			}
			else
			{
				newVolume=_lastVolume;
			}
			//Make sure we have a working NetStream object before setting its sound transform
			if (_media) _media.volume=newVolume;
		}
		
		public function getVolume():Number
		{
			return _currentVolume;
		}
		
		public function setVolume(value:Number):void
		{
			if (!isNaN(value) && value >= 0 && value <= 100)
			{
				_currentVolume=value;
				if(_media) _media.volume = value;
			}
		}

		/** Overriden */

		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);

			this.graphics.clear();

			_bgVideo.graphics.clear();
			_bgVideo.graphics.beginFill(getSkinColor(VIDEOBG_COLOR));
			_bgVideo.graphics.drawRect(_defaultMargin, _defaultMargin, _videoWidth, _videoHeight);
			_bgVideo.graphics.endFill();

			_playerControls.width=_videoWidth;
			_playerControls.height=20;
			_playerControls.y=_defaultMargin + _videoHeight;
			_playerControls.x=_defaultMargin;
			
			_ppBtn.x=0;
			_ppBtn.refresh();

			_stopBtn.x=_ppBtn.x + _ppBtn.width;
			_stopBtn.refresh();

			_sBar.x=_stopBtn.x + _stopBtn.width;
			_sBar.refresh();

			_eTime.refresh();

			_audioSlider.refresh();

			_sBar.width=_videoWidth - _ppBtn.width - _stopBtn.width - _eTime.width - _audioSlider.width;

			_eTime.x=_sBar.x + _sBar.width;
			_audioSlider.x=_eTime.x + _eTime.width;
			
			_busyIndicator.x=(_videoWidth-_busyIndicator.width)/2;
			_busyIndicator.y=(_videoHeight-_busyIndicator.height)/2;
			_busyIndicator.setStyle('symbolColor',0xFFFFFF);

			drawBG();
		}
		
		public function set videoDisplayWidth(value:Number):void{
			if(_videoDisplayWidth != value){
				var nominalWidth:Number = _videoDisplayWidth;
				width = nominalWidth;
			}
		}
		
		public function get videoDisplayWidth():Number{
			return _videoDisplayWidth;
		}
		
		public function set videoDisplayHeight(value:Number):void{
			if(_videoDisplayHeight != value){
				var nominalHeight:Number = _videoDisplayHeight + _playerControls.height;
				height = nominalHeight;
			}
		}
		
		public function get videoDisplayHeight():Number{
			return _videoDisplayHeight;
		}

		/**
		 * Set width/height of video widget
		 */
		override public function set width(w:Number):void
		{
			totalWidth=w;
			_videoWidth=w - 2 * _defaultMargin;
			this.updateDisplayList(0, 0); // repaint
		}

		override public function set height(h:Number):void
		{
			totalHeight=h;
			_videoHeight=h - 2 * _defaultMargin;
			this.updateDisplayList(0, 0); // repaint
		}

		/**
		 * Set total width/height of videoplayer
		 */
		protected function set totalWidth(w:Number):void
		{
			super.width=w;
		}

		protected function set totalHeight(h:Number):void
		{
			super.height=h;
		}

		/**
		 * Draws a background for videoplayer
		 */
		protected function drawBG():void
		{
			totalHeight=_defaultMargin * 2 + _videoHeight + _playerControls.height;

			_bg.graphics.clear();

			_bg.graphics.beginFill(getSkinColor(BORDER_COLOR));
			_bg.graphics.drawRect(0, 0, width, height);
			_bg.graphics.endFill();
			_bg.graphics.beginFill(getSkinColor(BG_COLOR));
			_bg.graphics.drawRect(3, 3, width - 6, height - 6);
			_bg.graphics.endFill();
			
			_errorSprite.updateDisplayList(width,height);
		}

		/**
		 * On creation complete
		 */
		private function onComplete(e:FlexEvent):void
		{
			dispatchEvent(new VideoPlayerEvent(VideoPlayerEvent.CREATION_COMPLETE));
		}
		
		public function playVideo():void
		{
			if (!streamReady(_media)){
				//logger.debug("Stream is not ready");
				return;
			}
			
			if (_media.streamState == AMediaManager.STREAM_SEEKING_START){
				//logger.debug("Cannot start playing while previous seek is not complete");
				return;
			}				
			if (_media.streamState == AMediaManager.STREAM_PAUSED)
			{
				resumeVideo();
			}
			if (_media.streamState == AMediaManager.STREAM_UNREADY){
				//logger.debug("[PlayVideo] stream not ready");
				_forcePlay=true;
				loadVideoByUrl(_mediaUrl);
			}
			if (_media.streamState == AMediaManager.STREAM_READY || _media.streamState == AMediaManager.STREAM_FINISHED){
				//logger.debug("[PlayVideo] stream ready or finished");
				startVideo();
			}
			
		}

		public function pauseVideo():void
		{
			if (_media.streamState == AMediaManager.STREAM_SEEKING_START)
				return;
			if (streamReady(_media) && (_media.streamState == AMediaManager.STREAM_STARTED || _media.streamState == AMediaManager.STREAM_BUFFERING))
				_media.netStream.togglePause();
		}
		
		public function resumeVideo():void
		{
			if (_media.streamState == AMediaManager.STREAM_SEEKING_START)
				return;
			if (streamReady(_media) && _media.streamState == AMediaManager.STREAM_PAUSED){
				_media.netStream.togglePause();
			}
		}
		
		public function stopVideo():void
		{
			if (streamReady(_media))
			{
				//_nsc.play(false);
				_media.stop();
				_video.clear();
				//_videoReady=false;
			}
		}
		
		public function endVideo():void
		{
			stopVideo();
			if (streamReady(_media)){
				_media.netStream.close(); //Cleans the cache of the video
				_media = null;
				_mediaReady=false;
			}
		}
		
		public function onMetaData(event:MediaStatusEvent):void
		{
			_duration=_media.duration;
			_video.width=_media.videoWidth;
			_video.height=_media.videoHeight;
			
			this.dispatchEvent(new VideoPlayerEvent(VideoPlayerEvent.METADATA_RETRIEVED));
			
			scaleVideo();
			this.addEventListener(Event.ENTER_FRAME, updateProgress, false, 0, true);
		}

		/**
		 * On video source changed
		 */
		public function onSourceChange(e:VideoPlayerEvent):void
		{
			playVideo();
			_ppBtn.state=PlayButton.PAUSE_STATE;

			if (!autoPlay)
				pauseVideo();
		}

		/**
		 * On play button clicked
		 */
		protected function onPPBtnChanged(e:Event):void
		{
			if(_mediaReady){
				if(_media.streamState==AMediaManager.STREAM_PAUSED || !_videoPlaying){
					playVideo();
				}else{	
					pauseVideo();
				}
			}
		}

		/**
		 * On stop button clicked
		 */
		protected function onStopBtnClick(e:StopEvent):void
		{
			stopVideo();
		}

		/**
		 * Updatting video progress
		 */
		private function updateProgress(e:Event):void
		{
			if (!_media)
				return;
			
			_currentTime=_media.currentTime;
			_sBar.updateProgress(_currentTime, _duration);

			// if not streaming show loading progress
			if (!_mediaNetConnectionUrl)
				_sBar.updateLoaded(_media.bytesLoaded / _media.bytesTotal);

			_eTime.updateElapsedTime(_currentTime, _duration);
		}

		protected function onScrubberDropped(e:Event):void
		{
			if (!_media)
				return;

			_media.seek(_sBar.seekPosition(_duration));
		}

		private function onScrubberDragging(e:Event):void
		{
			if (!_media)
				return;
		}

		/**
		 * On video finished playing
		 */
		protected function onVideoFinishedPlaying(e:VideoPlayerEvent):void
		{
			trace("[INFO] Exercise stream: Finished playing video "+_mediaUrl);
			stopVideo();
		}


		/**
		 * On volume change
		 */
		private function onVolumeChange(e:VolumeEvent):void
		{
			this.setVolume(e.volumeAmount);
		}

		/**
		 * Scaling video image
		 */
		protected function scaleVideo():void
		{
			if (!autoScale)
			{
				//trace("Scaling info");
				
				//If the scalation is different in height and width take the smaller one
				var scaleY:Number=_videoHeight / _video.height;
				var scaleX:Number=_videoWidth / _video.width;
				var scaleC:Number=scaleX < scaleY ? scaleX : scaleY;

				//Center the video in the stage
				_video.y=Math.floor(_videoHeight / 2 - (_video.height * scaleC) / 2);
				_video.x=Math.floor(_videoWidth / 2 - (_video.width * scaleC) / 2);

				//Leave space for the margins
				_video.y+=_defaultMargin;
				_video.x+=_defaultMargin;

				//Scale the video
				_video.width=Math.ceil(_video.width*scaleC);
				_video.height=Math.ceil(_video.height*scaleC);
				
				//trace("Scaling info");

				// 1 black pixel, being smarter
				//_video.y+=1;
				//_video.height-=2;
				//_video.x+=1;
				//_video.width-=2;
			}
			else
			{
				_video.width=_videoWidth;
				_video.height=_videoHeight;
				_video.y=_defaultMargin + 2;
				_video.height-=4;
				_video.x=_defaultMargin + 2;
				_video.width-=4;
			}
		}

		/**
		 * Resets videoplayer appearance
		 **/
		protected function resetAppearance():void
		{
			_sBar.updateProgress(0, 10);
			_video.attachNetStream(null);
			_video.visible=false;
			_eTime.updateElapsedTime(0, 0);
		}
		
		public function resetComponent():void{
			
		}
	}
}