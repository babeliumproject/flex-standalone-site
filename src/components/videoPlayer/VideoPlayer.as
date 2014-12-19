/**
 * NOTES
 *
 * Player needs a way to tell if a video exsists when streaming video.
 */

package components.videoPlayer
{
	
	import components.videoPlayer.controls.AudioSlider;
	import components.videoPlayer.controls.ElapsedTime;
	import components.videoPlayer.controls.PlayButton;
	import components.videoPlayer.controls.ScrubberBar;
	import components.videoPlayer.controls.SkinableComponent;
	import components.videoPlayer.controls.StopButton;
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
	
	//import org.as3commons.logging.api.ILogger;
	//import org.as3commons.logging.api.getLogger;

	public class VideoPlayer extends SkinableComponent
	{
		//protected static const logger:ILogger = getLogger(VideoPlayer);
		
		/**
		 * Skin related variables
		 */
		private const SKIN_PATH:String=DataModel.getInstance().uploadDomain+"resources/videoPlayer/skin/";
		private var _skinableComponents:Dictionary;
		private var _skinLoader:URLLoader;
		private var _loadingSkin:Boolean=false;
		public static const BG_COLOR:String="bgColor";
		public static const BORDER_COLOR:String="borderColor";
		public static const VIDEOBG_COLOR:String="videoBgColor";

		/**
		 * Variables
		 *
		 */
		protected var _video:Video;

		private var _state:String=null;
		private var _autoPlay:Boolean=false;
		private var _smooth:Boolean=true;
		private var _currentTime:Number=0;
		private var _autoScale:Boolean=true;
		protected var _duration:Number=0;
		protected var _started:Boolean=false;
		protected var _defaultMargin:Number=0;

		private var _bgVideo:Sprite;
		public var _ppBtn:PlayButton;
		public var _stopBtn:StopButton;
		protected var _eTime:ElapsedTime;
		protected var _bg:Sprite;
		protected var _videoBarPanel:UIComponent;
		protected var _sBar:ScrubberBar;
		protected var _audioSlider:AudioSlider;
		protected var _videoHeight:Number=200;
		protected var _videoWidth:Number=320;

		private var _timer:Timer;

		[Bindable]
		public var playbackState:int;
		
		
		protected var _media:AMediaManager;
		private var _mediaUrl:String;
		private var _netConnectionUrl:String;
		private var _mediaReady:Boolean;
		private var _currentVolume:Number;
		private var _forcePlay:Boolean;
		private var _videoPlaying:Boolean;
		

		/**
		 * CONSTRUCTOR
		 **/
		public function VideoPlayer(name:String="VideoPlayer")
		{
			super(name);

			_skinableComponents=new Dictionary();

			_bg=new Sprite();

			_bgVideo=new Sprite();

			_video=new Video();
			_video.smoothing=_smooth;

			_videoBarPanel=new UIComponent();

			_ppBtn=new PlayButton();
			_stopBtn=new StopButton();

			_videoBarPanel.addChild(_ppBtn);
			_videoBarPanel.addChild(_stopBtn);

			_sBar=new ScrubberBar();

			_videoBarPanel.addChild(_sBar);

			_eTime=new ElapsedTime();

			_videoBarPanel.addChild(_eTime);

			_audioSlider=new AudioSlider();

			_videoBarPanel.addChild(_audioSlider);

			//Event Listeners
			addEventListener(VideoPlayerEvent.VIDEO_SOURCE_CHANGED, onSourceChange);
			addEventListener(FlexEvent.CREATION_COMPLETE, onComplete);
			addEventListener(VideoPlayerEvent.VIDEO_FINISHED_PLAYING, onVideoFinishedPlaying);
			_ppBtn.addEventListener(PlayPauseEvent.STATE_CHANGED, onPPBtnChanged);
			_stopBtn.addEventListener(StopEvent.STOP_CLICK, onStopBtnClick);
			_audioSlider.addEventListener(VolumeEvent.VOLUME_CHANGED, onVolumeChange);

			/**
			 * Adds components to player
			 */
			addChild(_bg);
			addChild(_bgVideo);
			addChild(_video);
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
			skin="default";
		}
		
		public function loadVideoByUrl(param:Object):void{
			var netConnectionUrl:String;
			var mediaUrl:String;
			if(getQualifiedClassName(param) == 'Object')
			{
				if(!param.mediaUrl){
					return;
				}
				mediaUrl=param.mediaUrl;
				netConnectionUrl = param.netConnectionUrl || null;
			}
			else if (param is String)
			{
				mediaUrl=String(param) || null;
			} else {
				return;
			}
			
			_mediaUrl=mediaUrl;
			_netConnectionUrl=netConnectionUrl;
			
			loadVideo();
		}
		
		protected function loadVideo():void{
			_mediaReady=false;
			if (_mediaUrl != '')
			{
				resetAppearance();
				
				
				if(!_autoPlay){
					//_posterSprite = new BitmapSprite(_videoPosterUrl, _lastWidth, _lastHeight);
					//_topLayer.addChild(_posterSprite);
				}
				
				if (streamReady(_media))
				{
					_media.netStream.dispose();
				}
				
				_media=null;
				if(_netConnectionUrl){
					_media=new ARTMPManager("playbackStream");
					_media.addEventListener(MediaStatusEvent.STREAM_SUCCESS, onStreamSuccess, false, 0, true);
					_media.addEventListener(MediaStatusEvent.STREAM_FAILURE, onStreamFailure, false, 0, true);
					_media.setup(_netConnectionUrl, _mediaUrl);
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
			//logger.debug("NetStreamClient {0} is ready", [evt.streamId]);
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
			//_errorSprite=new ErrorSprite(evt.message, _lastWidth, _lastHeight);
			//_topLayer.removeChildren();
			//_topLayer.addChild(_errorSprite);
		}
		
		protected function onStreamStateChange(event:MediaStatusEvent):void{
			if (event.state == AMediaManager.STREAM_FINISHED)
			{
				//logger.debug("StreamFinished Event received");
				//stopVideo();
				_video.clear();
				_videoPlaying=false;
			}
			if (event.state == AMediaManager.STREAM_STARTED)
			{
				_videoPlaying=true;
			}
			
			//dispatchEvent(new VideoPlayerEvent(VideoPlayerEvent.STREAM_STATE_CHANGED, event.state));
		}
		
		protected function startVideo():void{
			if (!_mediaReady)
				return;
			try
			{
				//_nsc.play("exercises/"+_videoUrl);
				//_topLayer.removeChildren();
				_media.play();
			}
			catch (e:Error)
			{
				_mediaReady=false;
				//logger.error("Error while loading video. [{0}] {1}", [e.errorID, e.message]);
			}
		}
		

		/**
		 * Autoplay
		 */
		public function set autoPlay(tf:Boolean):void
		{
			_autoPlay=tf;
		}

		public function get autoPlay():Boolean
		{
			return _autoPlay;
		}

		/**
		 * Smooting
		 */
		public function set videoSmooting(tf:Boolean):void
		{
			_autoPlay=_smooth;
		}

		public function get videoSmooting():Boolean
		{
			return _smooth;
		}

		/**
		 * Autoscale
		 */
		public function set autoScale(flag:Boolean):void
		{
			_autoScale=flag;
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
				_sBar.addEventListener(ScrubberBarEvent.SCRUBBER_DROPPED, onScrubberDropped);
				_sBar.addEventListener(ScrubberBarEvent.SCRUBBER_DRAGGING, onScrubberDragging);
			}
			else
			{
				_sBar.removeEventListener(ScrubberBarEvent.SCRUBBER_DROPPED, onScrubberDropped);
				_sBar.removeEventListener(ScrubberBarEvent.SCRUBBER_DRAGGING, onScrubberDragging);
			}

			_sBar.enableSeek(flag);
		}

		public function seekTo(time:Number):void
		{
			this.onScrubberDragging(null);
			_sBar.updateProgress(time, _duration);
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
		 * Skin HashMap related commands
		 */
		protected function putSkinableComponent(name:String, cmp:SkinableComponent):void
		{
			_skinableComponents[name]=cmp;
		}

		protected function getSkinableComponent(name:String):SkinableComponent
		{
			return _skinableComponents[name];
		}

		public function setSkin(fileName:String):void
		{
			skin=fileName;
		}

		/**
		 * Duration
		 */
		public function get duration():Number
		{
			return _duration;
		}

		/**
		 * Skin loader
		 */
		public function set skin(name:String):void
		{

			var fileName:String=SKIN_PATH + name + ".xml";

			if (_loadingSkin)
			{ // Maybe some skins will try to load at same time
				flash.utils.setTimeout(setSkin, 20, name);
				return;
			}

			var xmlURL:URLRequest=new URLRequest(fileName);
			_skinLoader=new URLLoader(xmlURL);
			_skinLoader.addEventListener(Event.COMPLETE, onSkinFileRead);
			_skinLoader.addEventListener(IOErrorEvent.IO_ERROR, onSkinFileReadingError);
			_loadingSkin=true;
		}

		/**
		 * Parses Skin file
		 */
		public function onSkinFileRead(e:Event):void
		{
			var xml:XML=new XML(_skinLoader.data);

			for each (var xChild:XML in xml.child("Component"))
			{
				var componentName:String=xChild.attribute("name").toString();
				var cmp:SkinableComponent=getSkinableComponent(componentName);

				if (cmp == null)
					continue;
				for each (var xElement:XML in xChild.child("Property"))
				{
					var propertyName:String=xElement.attribute("name").toString();
					var propertyValue:String=xElement.toString();
					cmp.setSkinProperty(propertyName, propertyValue);
				}
			}

			updateDisplayList(0, 0); // repaint();
			_loadingSkin=false;
		}

		public function onSkinFileReadingError(e:Event):void
		{
			_loadingSkin=false;
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

			_videoBarPanel.width=_videoWidth;
			_videoBarPanel.height=20;
			_videoBarPanel.y=_defaultMargin + _videoHeight;
			_videoBarPanel.x=_defaultMargin;

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

			drawBG();
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
			totalHeight=_defaultMargin * 2 + _videoHeight + _videoBarPanel.height;

			_bg.graphics.clear();

			_bg.graphics.beginFill(getSkinColor(BORDER_COLOR));
			_bg.graphics.drawRect(0, 0, width, height);
			_bg.graphics.endFill();
			_bg.graphics.beginFill(getSkinColor(BG_COLOR));
			_bg.graphics.drawRect(3, 3, width - 6, height - 6);
			_bg.graphics.endFill();
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
			if (streamReady(_media) && _media.streamState == AMediaManager.STREAM_PAUSED)
				_media.netStream.togglePause();
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
		}

		/**
		 * On video source changed
		 */
		public function onSourceChange(e:VideoPlayerEvent):void
		{
			playVideo();
			_ppBtn.State=PlayButton.PAUSE_STATE;

			if (!autoPlay)
				pauseVideo();
		}

		/**
		 * On play button clicked
		 */
		protected function onPPBtnChanged(e:PlayPauseEvent):void
		{
			playVideo();
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
		private function updateProgress(e:TimerEvent):void
		{
			if (!_media)
				return; //Fail safe in case someone drags the scrubber.

			_currentTime=_media.currentTime;
			_sBar.updateProgress(_currentTime, _duration);

			// if not streaming show loading progress
			if (!_netConnectionUrl)
				_sBar.updateLoaded(_media.bytesLoaded / _media.bytesTotal);

			_eTime.updateElapsedTime(_currentTime, _duration);
		}

		/**
		 * Seek & Resume video when scrubber stops dragging
		 * or when progress bar has been clicked
		 */
		protected function onScrubberDropped(e:Event):void
		{
			if (!_media)
				return;

			_timer.stop();

			_media.seek(_sBar.seekPosition(_duration));

			if (_state == PlayButton.PAUSE_STATE) // before seek was playing, so resume video
			{
				_ppBtn.State=PlayButton.PAUSE_STATE;
				_media.resume();
			}

			_timer.start();
		}

		/**
		 * Pauses video when scrubber starts dragging
		 **/
		private function onScrubberDragging(e:Event):void
		{
			if (!_media)
				return;

			_state=_ppBtn.getState();

			if (_ppBtn.getState() == PlayButton.PAUSE_STATE) // do pause
			{
				_ppBtn.State=PlayButton.PLAY_STATE;
				_media.pause();
				_timer.stop();
			}
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
			if (!_media)
				return;

			_media.volume=e.volumeAmount;
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
