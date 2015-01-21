/**
 * NOTES
 *
 */

package components.videoPlayer
{
	import avmplus.getQualifiedClassName;
	
	import components.videoPlayer.controls.*;
	import components.videoPlayer.controls.babelia.*;
	import components.videoPlayer.events.*;
	import components.videoPlayer.events.babelia.*;
	import components.videoPlayer.media.*;
	import components.videoPlayer.timedevent.CaptionManager;
	import components.videoPlayer.timedevent.TimeMarkerManager;
	
	import events.FullStreamingEvent;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Matrix;
	import flash.media.*;
	import flash.net.*;
	import flash.utils.*;
	
	import model.DataModel;
	
	import modules.create.view.AddMedia;
	import modules.exercise.event.ResponseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Image;
	import mx.controls.Text;
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.effects.AnimateProperty;
	import mx.events.CloseEvent;
	import mx.events.EffectEvent;
	import mx.managers.PopUpManager;
	import mx.resources.ResourceManager;
	import mx.utils.ObjectUtil;
	
	import skins.OverlayPlayButtonSkin;
	
	import spark.components.Button;
	import spark.primitives.BitmapImage;
	
	import view.common.PrivacyRights;
	
	import vo.ResponseVO;

	public class VideoRecorder extends VideoPlayer
	{
		/**
		 * Skin related constants
		 */
		public static const COUNTDOWN_COLOR:String="countdownColor";
		public static const ROLEBG_COLOR:String="roleBgColor";
		public static const ROLEBORDER_COLOR:String="roleBorderColor";

		/**
		 * Interface components
		 */
		private var _subtitleButton:SubtitleButton;
		private var _subtitlePanel:UIComponent;
		private var _subtitleBox:SubtitleTextBox;
		private var _arrowContainer:UIComponent;
		private var _arrowPanel:ArrowPanel;
		private var _roleTalkingPanel:RoleTalkingPanel;
		private var _micActivityBar:MicActivityBar;
		private var _subtitlingControls:UIComponent;
		private var _subtitlingText:Text;
		private var _subtitleStartEnd:SubtitleStartEndButton;
		private var _bgArrow:Sprite;

		/**
		 * Recording related variables
		 */

		/**
		 * States
		 * NOTE:
		 * XXXX XXX1: split video panel into 2 views
		 * XXXX XX1X: recording modes
		 */
		public static const PLAY_STATE:int=0;        // 0000 0000
		public static const PLAY_BOTH_STATE:int=1;   // 0000 0001
		public static const RECORD_MIC_STATE:int=2;  // 0000 0010
		public static const RECORD_MICANDCAM_STATE:int=3; // 0000 0011
		public static const UPLOAD_MODE_STATE:int=4; // 0000 0100

		private const SPLIT_FLAG:int=1; // XXXX XXX1
		private const RECORD_MODE_MASK:int=2; // XXXX XX1X
		private const UPLOAD_FLAG:int=4; // XXXX X1XX

		private var _state:int;

		protected const COUNTDOWN_TIMER_SECS:int=5;
		protected const TIMELINE_TIMER_DELAY:int=50; // Delay in ms.
		 
		//The meaning of the gain is as follows:
		//0 silences the input audio. 50 is normal input (1x boost). 100 is boosted input (2x boost)
		protected const DEFAULT_MIC_GAIN:int=70;

		protected var _recordMedia:AMediaManager;
		protected var _recordMediaUrl:String;
		protected var _recordMediaNetConnectionUrl:String;
		protected var _recordMediaReady:Boolean;
		protected var _recordUseWebcam:Boolean;
		
		protected var _parallelMedia:AMediaManager;
		protected var _parallelMediaUrl:String;
		protected var _parallelMediaNetConnectionUrl:String;
		protected var _parallelMediaReady:Boolean;
		protected var _parallelMediaPlaying:Boolean;

		private var _camVideo:Video;
		private var _blackPixelsBetweenVideos:uint = 0;
		private var _lastVideoHeight:Number=0;

		private var _mic:Microphone;
		private var _camera:Camera;
		private var _micCamEnabled:Boolean=false;

		private var _userdevmgr:UserDeviceManager;
		private var _privUnlock:PrivacyRights;

		private var _captionmgr:CaptionManager;
		private var _captionText:String;
		private var _captionColor:int;
		private var _captionsLoaded:Boolean=false;
		
		private var _markermgr:TimeMarkerManager;
		
		private var _timeMarkers:Object;
		private var _pollTimeline:Boolean=false;
		
		private var _countdown:Timer;
		private var _countdownTxt:Text;

		private var _fileName:String;
		private var _recordingMuted:Boolean=false;
		
		protected var _parallelMuted:Boolean=false;
		protected var _parallelLastVolume:Number;
		protected var _parallelCurrentVolume:Number;
		protected var _micSilenced:Boolean;
		protected var _micCurrentGain:Number;
		protected var _micLastGain:Number;
	
		private var _displayCaptions:Boolean=false;

		[Bindable]
		public var secondStreamState:int;

		private var _ttimer:Timer;

		public static const SUBTILE_INSERT_DELAY:Number=0.5;

		private var _micImage:Image;
		private var _overlayButton:Button;


		/**
		 * CONSTRUCTOR
		 */
		public function VideoRecorder()
		{
			super("VideoRecorder"); // Required for setup skinable component

			_captionmgr=new CaptionManager();
			
			_subtitleButton=new SubtitleButton();
			_playerControls.addChild(_subtitleButton);

			_subtitlePanel=new UIComponent();

			_subtitleBox=new SubtitleTextBox();

			_subtitlePanel.visible=false;
			_subtitlePanel.addChild(_subtitleBox);

			_arrowContainer=new UIComponent();

			_bgArrow=new Sprite();

			_arrowContainer.addChild(_bgArrow);
			_arrowPanel=new ArrowPanel();
			_roleTalkingPanel=new RoleTalkingPanel();

			_arrowContainer.visible=false;
			_arrowContainer.addChild(_arrowPanel);
			_arrowContainer.addChild(_roleTalkingPanel);

			_countdownTxt=new Text();
			_countdownTxt.text="5";
			_countdownTxt.setStyle("fontWeight", "bold");
			_countdownTxt.setStyle("fontSize", 30);
			_countdownTxt.selectable=false;
			_countdownTxt.visible=false;

			_camVideo=new Video();
			_camVideo.visible=false;

			_micImage=new Image();

			_micImage.source = "/resources/images/player_mic_watermark.png";
			_micImage.height = 128;
			_micImage.width = 128;
			_micImage.alpha = 0.7;
			_micImage.autoLoad = true;
			_micImage.visible = false;
	
			_subtitleStartEnd=new SubtitleStartEndButton();
			_subtitleStartEnd.visible=false;
			
			_playerControls.addChild(_subtitleStartEnd);

			_micActivityBar=new MicActivityBar();
			_micActivityBar.visible=false;
			
			_overlayButton=new Button();
			_overlayButton.setStyle("skinClass", OverlayPlayButtonSkin);
			_overlayButton.width=128;
			_overlayButton.height=128;
			_overlayButton.buttonMode=true;
			_overlayButton.visible=false;
			_overlayButton.addEventListener(MouseEvent.CLICK, overlayClicked);

			/**
			 * Events listeners
			 **/
			_subtitleButton.addEventListener(SubtitleButtonEvent.STATE_CHANGED, onSubtitleButtonClicked);
			_subtitleStartEnd.addEventListener(SubtitlingEvent.START, onSubtitlingEvent);
			_subtitleStartEnd.addEventListener(SubtitlingEvent.END, onSubtitlingEvent);
			//_recStopBtn.addEventListener(RecStopButtonEvent.CLICK, onRecStopEvent);
			
			/**
			 * Adds components to player
			 */
			removeChild(_playerControls); // order
			addChild(_micActivityBar);
			addChild(_arrowContainer);
			
			addChild(_micImage);
			addChild(_camVideo);

			addChild(_subtitlePanel);
			addChild(_playerControls);
			addChild(_countdownTxt);

			addChild(_overlayButton);

			/**
			 * Adds skinable components to dictionary
			 */
			putSkinableComponent(COMPONENT_NAME, this);
			putSkinableComponent(_subtitleButton.COMPONENT_NAME, _subtitleButton);
			putSkinableComponent(_subtitleBox.COMPONENT_NAME, _subtitleBox);
			putSkinableComponent(_arrowPanel.COMPONENT_NAME, _arrowPanel);
			putSkinableComponent(_roleTalkingPanel.COMPONENT_NAME, _roleTalkingPanel);
			putSkinableComponent(_subtitleStartEnd.COMPONENT_NAME, _subtitleStartEnd);
			putSkinableComponent(_micActivityBar.COMPONENT_NAME, _micActivityBar);
		}

		public function setCaptions(captions:Object, cinstance:Object=null):void
		{
			if(!captions) return;
			
			if(!_captionmgr) 
				_captionmgr = new CaptionManager();
			
			_captionsLoaded = _captionmgr.parseCaptions(captions, this, cinstance);
			
			if(_captionsLoaded) 
				_subtitleButton.enabled=true;
			
			if(_displayCaptions){
				addEventListener(PollingEvent.ENTER_FRAME, _captionmgr.onIntervalTimer, false, 0, true);
				pollTimeline=true;
			}
		}
		
		public function setTimeMarkers(markers:Object):void{
			if(!markers) return;
			
			if(!_markermgr)
				_markermgr = new TimeMarkerManager();
			
			_markermgr.parseTimeMarkers(markers, this);
		}
		
		public function showCaption(args:Object):void{
			if(args){
				_captionText=String(args.text);
				_captionColor=int(args.color);
				_subtitleBox.setText(_captionText, _captionColor);
			}
		}
		
		public function hideCaption(args:Object=null):void{
			_subtitleBox.setText(null);
		}

		public function set displayCaptions(value:Boolean):void
		{
			if(_displayCaptions == value) return;
			
			_displayCaptions=value;
			_subtitlePanel.visible=_displayCaptions;
			_subtitleButton.selected=_displayCaptions;
			
			if(_displayCaptions){
				addEventListener(PollingEvent.ENTER_FRAME, _captionmgr.onIntervalTimer, false, 0, true);
				pollTimeline=true;
			} else {
				removeEventListener(PollingEvent.ENTER_FRAME, _captionmgr.onIntervalTimer);
				pollTimeline=false;
			}
			
			invalidateDisplayList();
		}

		public function get displayCaptions():Boolean
		{
			return _displayCaptions;
		}
		
		public function set pollTimeline(value:Boolean):void{
			if(_pollTimeline == value) return;
			
			_pollTimeline = value;
			
			if(_pollTimeline){
				if(!_ttimer){
					_ttimer=new Timer(TIMELINE_TIMER_DELAY, 0);
				}
				_ttimer.addEventListener(TimerEvent.TIMER, onTimerTick, false, 0, true);
				_ttimer.start();
			} else {
				if(_ttimer){
					_ttimer.removeEventListener(TimerEvent.TIMER, onTimerTick);
					_ttimer.reset();
				}
			}
		}
		
		public function get pollTimeline():Boolean{
			return _pollTimeline;
		}
		
		private function onTimerTick(e:TimerEvent):void
		{
			if (streamReady(_media)){
				this.dispatchEvent(new PollingEvent(PollingEvent.ENTER_FRAME, _media.currentTime));
			}
			//if (streamReady(_recNsc)){
			//	//If the user didn't stop recording after _maxRecTime elapsed, force a stop
			//	if ((_maxRecTime - _recNsc.netStream.time) <=0){
			//		abortRecording();
			//	}
			//}
		}

		/**
		 * @param arrows: ArrayCollection[{time:Number,role:String}]
		 * @param selectedRole: selected role by the user.
		 * 						This makes the arrows be red or black.
		 */
		public function setArrows(arrows:ArrayCollection, selectedRole:String):void
		{
			_arrowPanel.setArrows(arrows, _duration, selectedRole);

			// Extract only selected roles
			var tmp:ArrayCollection=new ArrayCollection();
			for (var i:Number=0; i < arrows.length; i++)
				if (arrows.getItemAt(i).role == selectedRole)
					tmp.addItem(arrows.getItemAt(i));

			_sBar.setMarks(tmp, _duration);
		}

		// remove arrows from panel
		public function removeArrows():void
		{
			_arrowPanel.removeArrows();
			_sBar.removeMarks();
		}

		// show/hide arrow panel
		public function set arrows(flag:Boolean):void
		{
			if (_state != PLAY_STATE)
			{
				_arrowContainer.visible=flag;
				this.updateDisplayList(0, 0);
			} else {
				_arrowContainer.visible=false;
				this.updateDisplayList(0, 0);
			}
		}

		/**
		 * Set role to talk in role talking panel
		 * @param duration in seconds
		 **/
		public function startTalking(role:String, duration:Number):void
		{
			if (!_roleTalkingPanel.talking)
				_roleTalkingPanel.setTalking(role, duration);
		}

		/**
		 * Enable/disable subtitling controls			_recordGain=value;
		 */
		public function set subtitlingControls(flag:Boolean):void
		{
			_subtitleStartEnd.visible=flag;
			this.updateDisplayList(0,0); //repaint component
		}

		public function get subtitlingControls():Boolean
		{
			return _subtitlingControls.visible;
		}
		
		/**
		 * Autoplay
		 */
		override public function set autoPlay(tf:Boolean):void
		{
			super.autoPlay=tf;
			tf ? _overlayButton.visible=false : _overlayButton.visible=true;
		}
		
		protected function getInternalState():int{
			return _state;
		}
		
		protected function setInternalState(state:int):void{
			if(_state == state) return;
			
			_state=state;
			
			//Pause and hide the current media
			//switchPerspective();
			//dispatchEvent(new VideoRecorderEvent(VideoRecorderEvent.RECORDER_STATE_CHANGED,_state));
		}

		/**
		 * Video player's state
		 */
		public function get state():int
		{
			return _state;
		}

		public function set state(state:int):void
		{
			stopVideo();

			if (state == PLAY_BOTH_STATE || state == PLAY_STATE)
				enableControls();

			_state=state;
			switchPerspective();
		}

		public function overlayClicked(event:MouseEvent):void
		{
			_ppBtn.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		}

		override protected function onPPBtnChanged(e:Event):void
		{
			super.onPPBtnChanged(e);
			if(_overlayButton.visible)
				_overlayButton.visible=false;
		}
		
		public function getMicGain():void{
			_micCurrentGain;
		}
		
		public function setMicGain():void{
			
		}
		
		public function muteRecording(value:Boolean):void
		{
			_parallelMuted=value;
			
			if(_state & RECORD_MODE_MASK){
				var newGain:Number;
				if(value){
					_micLastGain=_micCurrentGain;
					newGain=0;
				} else{
					newGain=_micLastGain;
				}
				
				if(_mic) _mic.gain = newGain;
			} 
			else if (_state == PLAY_BOTH_STATE){
				var newVolume:Number;
				if (value)
				{
					//Store the volume that we had before muting to restore to that volume when unmuting
					_parallelLastVolume=_parallelCurrentVolume;
					newVolume=0;
				}
				else
				{
					newVolume=_parallelLastVolume;
				}
				if (_parallelMedia) _recordMedia.volume=newVolume;
			}
		}

		/**
		 *  Highlight components
		 **/
		public function set highlight(flag:Boolean):void
		{
			_arrowPanel.highlight=flag;
			_roleTalkingPanel.highlight=flag;
		}


		/**
		 * Get video time
		 **/
		public function get streamTime():Number
		{
			return _media.currentTime;
		}

		/**
		 * Methods
		 *
		 */

		/** Overriden repaint */

		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{

			super.updateDisplayList(unscaledWidth, unscaledHeight);

			_micActivityBar.width=_videoWidth;
			_micActivityBar.height=22;
			_micActivityBar.x=_defaultMargin;
			_micActivityBar.refresh();

			_arrowContainer.width=_playerControls.width;
			_arrowContainer.height=50;
			_arrowContainer.x=_defaultMargin;

			var matr:Matrix=new Matrix();
			matr.createGradientBox(_arrowContainer.height, _arrowContainer.height, 270*Math.PI/180, 0, 0);

			var colors:Array=[0xffffff, 0xd8d8d8];
			var alphas:Array=[1, 1];
			var ratios:Array=[0, 255];

			_bgArrow.graphics.clear();
			_bgArrow.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matr);
			_bgArrow.graphics.lineStyle(1, 0xa7a7a7);
			_bgArrow.graphics.drawRect(0, 0, _arrowContainer.width, _arrowContainer.height);
			_bgArrow.graphics.endFill();

			_subtitleButton.resize(45, 20);
			_sBar.width=_videoWidth - _ppBtn.width - _stopBtn.width - _eTime.width - _audioSlider.width - 45;
			//_sBar.width=_videoWidth - _ppBtn.width - _recStopBtn.width - _eTime.width - _audioSlider.width - 45;
			_eTime.x=_sBar.x + _sBar.width;
			_audioSlider.x=_eTime.x + _eTime.width;
			_sBar.refresh();
			_eTime.refresh();
			_audioSlider.refresh();
			_subtitleButton.x=_audioSlider.x + _audioSlider.width;
			_subtitleButton.refresh();

			// Put subtitle box at top
			_subtitlePanel.width=_playerControls.width;
			_subtitlePanel.height=_videoHeight*0.75;
			_subtitlePanel.x=_defaultMargin;
			/*
			 * Subtitle panel
			 */
			var y2:Number=_arrowContainer.visible ? _arrowContainer.height : 0;
			var y3:Number=_micActivityBar.visible ? _micActivityBar.height: 0;

			_playerControls.y+=y3 + y2;

			_arrowContainer.y=_playerControls.y - _arrowContainer.height;
			_subtitlePanel.y=_videoHeight - _subtitlePanel.height;

			_micActivityBar.y=_playerControls.y - y2 - _micActivityBar.height;


			_subtitleBox.y=0;
			_subtitleBox.resize(_videoWidth, _videoHeight*0.75);

			// Resize arrowPanel
			_arrowPanel.resize(_sBar.width, _arrowContainer.height - 8);
			_arrowPanel.x=_sBar.x;
			_arrowPanel.y=4;

			// Resize RolePanel
			_roleTalkingPanel.resize(_videoWidth - _defaultMargin * 6 - _arrowPanel.width - _arrowPanel.x, _arrowPanel.height);
			_roleTalkingPanel.x=_arrowPanel.x + _arrowPanel.width + _defaultMargin * 3;
			_roleTalkingPanel.y=4;

			// Countdown
			_countdownTxt.x=_videoWidth / 2 - 10;
			_countdownTxt.y=_videoHeight / 2 - 10;
			_countdownTxt.width=_videoWidth;
			_countdownTxt.height=_videoHeight;
			_countdownTxt.setStyle("color", getSkinColor(COUNTDOWN_COLOR));

			//Play overlay
			_overlayButton.width=_videoWidth;
			_overlayButton.height=_videoHeight;


			if(_subtitleStartEnd.visible)
			{
				_ppBtn.x=0;
				_ppBtn.refresh();

				//_recStopBtn.x=_ppBtn.x + _ppBtn.width;
				//_recStopBtn.refresh();
				
				//_subtitleStartEnd.x = _recStopBtn.x + _recStopBtn.width;
				_stopBtn.x=_ppBtn.x + _ppBtn.width;
				_stopBtn.refresh();

				_subtitleStartEnd.x=_stopBtn.x + _stopBtn.width;
				_subtitleStartEnd.refresh();

				_sBar.x=_subtitleStartEnd.x + _subtitleStartEnd.width;
				_sBar.refresh();

				_eTime.refresh();

				_audioSlider.refresh();

				_subtitleButton.includeInLayout=false;
				_subtitleButton.visible=false;

				_sBar.width=_videoWidth - _ppBtn.width - _stopBtn.width - _subtitleStartEnd.width - _eTime.width - _audioSlider.width;
				//_sBar.width=_videoWidth - _ppBtn.width - _recStopBtn.width - _subtitleStartEnd.width - _eTime.width - _audioSlider.width;
				
				_eTime.x=_sBar.x + _sBar.width;
				_audioSlider.x=_eTime.x + _eTime.width;

			}
			else
			{
				_ppBtn.x=0;
				_ppBtn.refresh();

				_stopBtn.x=_ppBtn.x + _ppBtn.width;
				_stopBtn.refresh();

				_sBar.x=_stopBtn.x + _stopBtn.width;
				//_recStopBtn.x=_ppBtn.x + _ppBtn.width;
				//_recStopBtn.refresh();
				
				//_sBar.x=_recStopBtn.x + _recStopBtn.width;
				_sBar.refresh();

				_eTime.refresh();

				_audioSlider.refresh();

				_subtitleButton.includeInLayout=true;
				_subtitleButton.visible=true;

				_sBar.width=_videoWidth - _ppBtn.width - _stopBtn.width - _eTime.width - _audioSlider.width - _subtitleButton.width;
				//_sBar.width=_videoWidth - _ppBtn.width - _recStopBtn.width - _eTime.width - _audioSlider.width - _subtitleButton.width;
				
				_eTime.x=_sBar.x + _sBar.width;
				_audioSlider.x=_eTime.x + _eTime.width;

			}

			drawBG();
		}

		override protected function drawBG():void
		{

			/**
			 * Recalculate total height
			 */

			_micActivityBar.height=22;

			var h2:Number=_arrowContainer.visible ? _arrowContainer.height : 0;
			var h4:Number=_micActivityBar.visible ? _micActivityBar.height : 0;

			totalHeight=_videoHeight + h2 + h4 + _playerControls.height;

			_bg.graphics.clear();

			_bg.graphics.beginFill(getSkinColor(BG_COLOR));
			_bg.graphics.drawRect(0, 0, width, height);
			_bg.graphics.endFill();
			
			_errorSprite.updateDisplayList(width,height);
		}

		/**
		 * Overriden play video:
		 * - Adds a listener to video widget
		 */
		override public function playVideo():void
		{
			super.playVideo();
			if(state == PLAY_BOTH_STATE)
				playSecondStream();

			if (!_ttimer)
			{
				_ttimer=new Timer(20, 0); //Try to tick every 20ms
				_ttimer.addEventListener(TimerEvent.TIMER, onTimerTick);
				_ttimer.start();
			}
		}

		/**
		 * Overriden pause video:
		 * - Pauses talk if any role is talking
		 * - Pauses second stream if any
		 */
		override public function pauseVideo():void
		{
			//This won't work, exit right away
			if (state & RECORD_MODE_MASK && _micCamEnabled){
				return;
				
				//if (_recordMedia.streamState == AMediaManager.STREAM_SEEKING_START)
				//	return;
				//if (streamReady(_recordMedia) && (_recordMedia.streamState == AMediaManager.STREAM_STARTED || _recordMedia.streamState == AMediaManager.STREAM_BUFFERING))
				//	_recordMedia.netStream.togglePause();
			}
			
			if (state == PLAY_BOTH_STATE){
				if (_parallelMedia.streamState == AMediaManager.STREAM_SEEKING_START)
					return;
				if (streamReady(_parallelMedia) && (_parallelMedia.streamState == AMediaManager.STREAM_STARTED || _parallelMedia.streamState == AMediaManager.STREAM_BUFFERING))
					_parallelMedia.netStream.togglePause();
			}
			
			super.pauseVideo();

			if (_roleTalkingPanel.talking)
				_roleTalkingPanel.pauseTalk();			
		}

		/**
		 * Overriden resume video:
		 * - Resumes talk if any role is talking
		 * - Resumes secon stream if any
		 */
		override public function resumeVideo():void
		{
			//This won't work, exit right away
			if (state & RECORD_MODE_MASK && _micCamEnabled){
				return;
				
				//if (_recordMedia.streamState == AMediaManager.STREAM_SEEKING_START)
				//	return;
				//if (streamReady(_recordMedia) && _recordMedia.streamState == AMediaManager.STREAM_PAUSED){
				//	_recordMedia.netStream.togglePause();
				//}
			}

			if (state == PLAY_BOTH_STATE){
				if (_parallelMedia.streamState == AMediaManager.STREAM_SEEKING_START)
					return;
				if (streamReady(_parallelMedia) && _parallelMedia.streamState == AMediaManager.STREAM_PAUSED){
					_parallelMedia.netStream.togglePause();
				}
			}
			
			super.resumeVideo();
			
			if (_roleTalkingPanel.talking)
				_roleTalkingPanel.resumeTalk();
			
		}

		/**
		 * Overriden stop video:
		 * - Stops talk if any role is talking
		 * - Stops second stream if any
		 */
		override public function stopVideo():void
		{
			super.stopVideo();

			if (state & RECORD_MODE_MASK && _micCamEnabled){
				if (streamReady(_recordMedia))
				{
					_recordMedia.stop();
					_camVideo.clear();
				}
			}

			if (state == PLAY_BOTH_STATE)
			{
				if (streamReady(_parallelMedia))
				{
					_parallelMedia.stop();
					_camVideo.clear();
				}
			}
			
			if (_roleTalkingPanel.talking)
				_roleTalkingPanel.stopTalk();

			hideCaption();
		}

		override public function endVideo():void
		{
			super.endVideo();

			if (state & RECORD_MODE_MASK && _micCamEnabled){
				if (streamReady(_recordMedia))
				{
					_recordMedia.netStream.close(); //Cleans the cache of the video
					_recordMedia = null;
					_recordMediaReady=false;
				}
			}
			
			if (state == PLAY_BOTH_STATE)
			{
				if (streamReady(_parallelMedia)){
					_parallelMedia.netStream.close(); //Cleans the cache of the video
					_parallelMedia = null;
					_parallelMediaReady=false;
				}
			}
		}

		/**
		 * Overriden on seek end:
		 * - clear subtitles from panel
		 **/
		override protected function onScrubberDropped(e:Event):void
		{
			super.onScrubberDropped(e);

			hideCaption();
		}

		/**
		 * On subtitle button clicked:
		 * - Do show/hide subtitle panel
		 */
		private function onSubtitleButtonClicked(e:SubtitleButtonEvent):void
		{
			if (e.state)
				doShowSubtitlePanel();
			else
				doHideSubtitlePanel();
		}

		/**
		 * Subtitle Panel's show animation
		 */
		private function doShowSubtitlePanel():void
		{
			_subtitlePanel.visible=true;
			var a1:AnimateProperty=new AnimateProperty();
			a1.target=_subtitlePanel;
			a1.property="alpha";
			a1.toValue=1;
			a1.duration=250;
			a1.play();

			this.drawBG(); // Repaint bg
		}

		/**
		 * Subtitle Panel's hide animation
		 */
		private function doHideSubtitlePanel():void
		{
			var a1:AnimateProperty=new AnimateProperty();
			a1.target=_subtitlePanel;
			a1.property="alpha";
			a1.toValue=0;
			a1.duration=250;
			a1.play();
			a1.addEventListener(EffectEvent.EFFECT_END, onHideSubtitleBar);
		}

		private function onHideSubtitleBar(e:Event):void
		{
			_subtitlePanel.visible=false;
			this.drawBG(); // Repaint bg
		}

		/**
		 * On subtitling controls clicked: start or end subtitling button
		 * This method adds ns.time to event and gives it to parent component
		 *
		 * NOTE: Made public because the subtitling module has it's own subtitling
		 * controls that need access to the current video time.
		 */
		public function onSubtitlingEvent(e:SubtitlingEvent):void
		{
			var time:Number=_media.currentTime;
			this.dispatchEvent(new SubtitlingEvent(e.type, time - SUBTILE_INSERT_DELAY));
		}


		/**
		 * Switch video's perspective based on video player's
		 * actual state
		 */
		private function switchPerspective():void
		{
			switch (_state)
			{
				case RECORD_MICANDCAM_STATE:
				{
					splitVideoPanel();
					break;
				}
				case RECORD_MIC_STATE:
				{
					recoverVideoPanel();
					break;
				}
				case UPLOAD_MODE_STATE:
				{
					recoverVideoPanel();
					scaleCamVideo(_videoWidth,_videoHeight,false);
					break;
				}
				case PLAY_BOTH_STATE:
				{
					splitVideoPanel();
					break;
				}
				default:
				{
					recoverVideoPanel();
					break;
				}
			}
			invalidateDisplayList();
		}

		/**
		 * Countdown before recording
		 */

		// Prepare countdown timer
		private function startCountdown():void
		{
			_countdown=new Timer(1000, COUNTDOWN_TIMER_SECS);
			_countdown.addEventListener(TimerEvent.TIMER, onCountdownTick, false, 0, true);
			_countdown.start();
		}

		// On Countdown tick
		private function onCountdownTick(tick:TimerEvent):void
		{
			if (_countdown.currentCount == _countdown.repeatCount)
			{
				_countdownTxt.visible=false;
				_video.visible=true;

				if (state == RECORD_MICANDCAM_STATE || state == UPLOAD_MODE_STATE)
				{
					_camVideo.visible=true;
					_micImage.visible=true;
				}

				// Reset countdown timer
				_countdownTxt.text="5";
				_countdown.stop();
				_countdown.reset();

				startRecording();
			}
			else if (state != PLAY_STATE)
				_countdownTxt.text=new String(5 - _countdown.currentCount);
		}


		private function prepareDevices():void
		{
			_userdevmgr = new UserDeviceManager();
			_userdevmgr.useMicAndCamera= _recordUseWebcam;
			_userdevmgr.addEventListener(UserDeviceEvent.DEVICE_STATE_CHANGE, deviceStateHandler, false, 0, true);
			_userdevmgr.initDevices();
		}

		private function configureDevices():void
		{	
			_micCamEnabled=_userdevmgr.deviceAccessGranted;
			if (_recordUseWebcam)
			{
				_camera=_userdevmgr.camera;
				_camera.setMode(DataModel.getInstance().cameraWidth, DataModel.getInstance().cameraHeight, 15, false);
			}
			_mic=_userdevmgr.microphone;
			_mic.setUseEchoSuppression(true);
			_mic.setSilenceLevel(0, 60000000);
			_micActivityBar.mic=_mic;
			
			_camVideo.width=_userdevmgr.defaultCameraWidth;
			_camVideo.height=_userdevmgr.defaultCameraHeight;
			_camVideo.attachCamera(_camera);
			_camVideo.smoothing=true;
			
			_video.visible=false;
			_camVideo.visible=false;
			_micImage.visible=false;
			_countdownTxt.visible=true;

			prepareRecording();
			startCountdown();
		}

		private function deviceStateHandler(event:UserDeviceEvent):void{
			var devstate:int = event.state;
			if(!_privUnlock){
				if (devstate == UserDeviceEvent.DEVICE_ACCESS_GRANTED){
					configureDevices();
				} else {
					var appwindow:DisplayObjectContainer = FlexGlobals.topLevelApplication.parent;
					var modal:Boolean=true;
					_privUnlock=new PrivacyRights();
					_privUnlock.addEventListener(UserDeviceEvent.ACCEPT, privacyAcceptHandler, false, 0 ,true);
					_privUnlock.addEventListener(UserDeviceEvent.RETRY, privacyRetryHandler, false, 0, true);
					_privUnlock.addEventListener(UserDeviceEvent.CANCEL, privacyCancelHandler, false, 0, true);
					_privUnlock.displayState(devstate);
					PopUpManager.addPopUp(_privUnlock, appwindow, modal);
					PopUpManager.centerPopUp(_privUnlock);
					if(devstate==UserDeviceEvent.DEVICE_ACCESS_NOT_GRANTED){
						_userdevmgr.showPrivacySettings();
					}
				}
			} else {
				_privUnlock.displayState(devstate);
				if(devstate==UserDeviceEvent.DEVICE_ACCESS_NOT_GRANTED){
					_userdevmgr.showPrivacySettings();
				}
			}
		}
		
		private function privacyAcceptHandler(event:Event):void{
			PopUpManager.removePopUp(_privUnlock);
			_privUnlock.removeEventListener(UserDeviceEvent.ACCEPT, privacyAcceptHandler);
			_privUnlock.removeEventListener(UserDeviceEvent.RETRY, privacyRetryHandler);
			_privUnlock.removeEventListener(UserDeviceEvent.CANCEL, privacyCancelHandler);
			_privUnlock=null;
			_userdevmgr.removeEventListener(UserDeviceEvent.DEVICE_STATE_CHANGE, deviceStateHandler);
			configureDevices();
		}
		
		private function privacyRetryHandler(event:Event):void{
			_userdevmgr.initDevices();
		}
		
		private function privacyCancelHandler(event:Event):void{
			PopUpManager.removePopUp(_privUnlock);
			_privUnlock.removeEventListener(UserDeviceEvent.ACCEPT, privacyAcceptHandler);
			_privUnlock.removeEventListener(UserDeviceEvent.RETRY, privacyRetryHandler);
			_privUnlock.removeEventListener(UserDeviceEvent.CANCEL, privacyCancelHandler);
			_privUnlock=null;
			_userdevmgr.removeEventListener(UserDeviceEvent.DEVICE_STATE_CHANGE, deviceStateHandler);
			dispatchEvent(new RecordingEvent(RecordingEvent.ABORTED));
		}


		private function prepareRecording():void
		{
			// Disable seek
			seek=false;

			disableControls();
			
			_micActivityBar.visible=true;
			_micActivityBar.mic=_mic;
			
			switchPerspective();
		}

		/**
		 * Start recording
		 */
		private function startRecording():void
		{
			if (!(state & RECORD_MODE_MASK))
				return; // security check

			//if (_started)
			//	resumeVideo();
			//else
			playVideo();

			if (state & RECORD_MODE_MASK)
			{
				_recordMedia.netStream.attachAudio(_mic);
				muteRecording(true); // mic starts muted
			}

			if (state == RECORD_MICANDCAM_STATE)
				_recordMedia.netStream.attachCamera(_camera);

			_ppBtn.state=PlayButton.PAUSE_STATE;

			_recordMedia.publish();

			trace("[INFO] Response stream: Started recording " + _fileName);

			//TODO: new feature - enableControls();
		}


		/**
		 * Split video panel into 2 views
		 */
		private function splitVideoPanel():void
		{
			//The stage should be splitted only when the right state is set
			if (!(state & SPLIT_FLAG))
				return;

			var w:Number=_videoWidth / 2 - _blackPixelsBetweenVideos;
			var h:int=Math.ceil(w * 0.75);//_video.height / _video.width);

			if (_videoHeight != h) // cause we can call twice to this method
				_lastVideoHeight=_videoHeight; // store last value

			_videoHeight=h;
			
			//trace("[INFO] Video player Babelium: BEFORE SPLIT VIDEO PANEL Video area dimensions: "+_videoWidth+"x"+_videoHeight+" video dimensions: "+_video.width+"x"+_video.height+" video placement: x="+_video.x+" y="+_video.y+" last video area heigth: "+_lastVideoHeight);

			var scaleY:Number=h / _video.height;
			var scaleX:Number=w / _video.width;
			var scaleC:Number=scaleX < scaleY ? scaleX : scaleY;

			_video.y=Math.floor(h / 2 - (_video.height * scaleC) / 2);
			_video.x=Math.floor(w / 2 - (_video.width * scaleC) / 2);
			_video.y+=_defaultMargin;
			_video.x+=_defaultMargin;

			_video.width*=scaleC;
			_video.height*=scaleC;

			//trace("[INFO] Video player Babelium: AFTER SPLIT VIDEO PANEL Video area dimensions: "+_videoWidth+"x"+_videoHeight+" video dimensions: "+_video.width+"x"+_video.height+" video placement: x="+_video.x+" y="+_video.y+" last video area heigth: "+_lastVideoHeight);
			
			//Resize the cam display
			scaleCamVideo(w,h);

			updateDisplayList(0, 0); // repaint

			//trace("The video panel has been splitted");
		}

		/**
		 * Recover video panel's original size
		 */
		private function recoverVideoPanel():void
		{
			trace("[INFO] Video player Babelium: Recover video panel");
			// NOTE: problems with _videoWrapper.width
			if (_lastVideoHeight > _videoHeight)
				_videoHeight=_lastVideoHeight;

			scaleVideo();

			_camVideo.visible=false;
			_micImage.visible=false;
			_micActivityBar.visible=false;

			//trace("The video panel recovered its original size");
		}

		// Aux: scaling cam image
		private function scaleCamVideo(w:Number, h:Number,split:Boolean=true):void
		{
		
			var scaleY:Number=h / DataModel.getInstance().cameraHeight;
			var scaleX:Number=w / DataModel.getInstance().cameraWidth;
			var scaleC:Number=scaleX < scaleY ? scaleX : scaleY;

			_camVideo.width=DataModel.getInstance().cameraWidth * scaleC;
			_camVideo.height=DataModel.getInstance().cameraHeight * scaleC;

			if(split){
				_camVideo.y=Math.floor(h / 2 - _camVideo.height / 2);
				_camVideo.x=Math.floor(w / 2 - _camVideo.width / 2);
				_camVideo.y+=_defaultMargin;
				_camVideo.x+=(w + _defaultMargin);
			} else {
				_camVideo.y=_defaultMargin + 2;
				_camVideo.height-=4;
				_camVideo.x=_defaultMargin + 2;
				_camVideo.width-=4;
			}

			
			_micImage.y=(_videoHeight - _micImage.height)/2;
			_micImage.x=_videoWidth - _micImage.width - (_camVideo.width - _micImage.width)/2;
		}

		override protected function scaleVideo():void
		{
			super.scaleVideo();
			if (_state & SPLIT_FLAG)
			{
				var w:Number=_videoWidth / 2 - _blackPixelsBetweenVideos;
				var h:int=Math.ceil(w * 0.75);

				if (_videoHeight != h) // cause we can call twice to this method
					_lastVideoHeight=_videoHeight; // store last value

				_videoHeight=h;

				var scaleY:Number=h / _video.height;
				var scaleX:Number=w / _video.width;
				var scaleC:Number=scaleX < scaleY ? scaleX : scaleY;

				_video.y=Math.floor(h / 2 - (_video.height * scaleC) / 2);
				_video.x=Math.floor(w / 2 - (_video.width * scaleC) / 2);
				_video.y+=_defaultMargin;
				_video.x+=_defaultMargin;

				_video.width*=scaleC;
				_video.height*=scaleC;
				//trace("[INFO] Video player babelia: AFTER SCALE Video area dimensions: "+_videoWidth+"x"+_videoHeight+" video dimensions: "+_video.width+"x"+_video.height+" video placement: x="+_video.x+" y="+_video.y+" last video area heigth: "+_lastVideoHeight);
			}
		}

		override protected function resetAppearance():void
		{
			super.resetAppearance();

			if (state & SPLIT_FLAG)
			{
				_camVideo.attachNetStream(null);
				_camVideo.clear();
				_camVideo.visible=false;
				_micImage.visible=false;
			}
		}

		/**
		 * Overriden on recording finished:
		 * Gives the filename to the parent component
		 **/
		override protected function onVideoFinishedPlaying(e:VideoPlayerEvent):void
		{
			super.onVideoFinishedPlaying(e);

			if (state & RECORD_MODE_MASK || state == UPLOAD_MODE_STATE)
			{
				//addDummyVideo();
				unattachUserDevices();

				trace("[INFO] Response stream: Finished recording " + _fileName);
				dispatchEvent(new RecordingEvent(RecordingEvent.END, _fileName));
				enableControls(); 
			}
			else
				dispatchEvent(new RecordingEvent(RecordingEvent.REPLAY_END));
		}
		
		public function unattachUserDevices():void{
			if (streamReady(_recordMedia))
			{
				_recordMedia.netStream.attachCamera(null);
				_recordMedia.netStream.attachAudio(null);
				_camVideo.clear();
				_camVideo.attachCamera(null);
			}
		}

		/**
		 * PLAY_BOTH related commands
		 **/
		private function playSecondStream():void
		{
			_camVideo.clear();
			_camVideo.attachNetStream(_parallelMedia.netStream);
			_camVideo.visible=true;
			_micImage.visible=true;

			_parallelMedia.volume=_currentVolume;
			_parallelMedia.play();

				// Needed for video mute
				muteRecording(false);
				muteRecording(true);

				if (_media != null)
				{
					//_ns.resume();
					_media.play();
				}
				_ppBtn.state=PlayButton.PAUSE_STATE;
		}
		
		/**
		 * The overriden loadVideoByUrl accepts parallel media loading 
		 * @param param
		 */		
		override public function loadVideoByUrl(param:Object):void{
			if(getQualifiedClassName(param) == 'Object')
			{
				if(param.leftMedia){
					var lmedia:Object=parseMediaObject(param.leftMedia);
					var rmedia:Object;
					if(param.rightMedia){
						rmedia=parseMediaObject(param.rightMedia);
					}
					if(lmedia && rmedia){
						setInternalState(PLAY_BOTH_STATE);
						
						_mediaNetConnectionUrl=lmedia.netConnectionUrl;
						_mediaUrl=lmedia.mediaUrl;
						_mediaPosterUrl=lmedia.mediaPosterUrl;
						_parallelMediaNetConnectionUrl=rmedia.netConnectionUrl;
						_parallelMediaUrl=rmedia.mediaUrl;
						
						loadParallelVideo();
							
					} else if(lmedia){
						setInternalState(PLAY_STATE);
						super.loadVideoByUrl(lmedia);
					}
				} else if (param.recordMedia){
					var recmedia:Object=parseMediaObject(param.recordMedia);
					var playmedia:Object;
					if(param.playbackMedia){
						playmedia=parseMediaObject(param.playbackMedia);
					}
					if(recmedia && playmedia){
						
						_recordMediaNetConnectionUrl=recmedia.netConnectionUrl;
						_recordMediaUrl=recmedia.mediaUrl;
						_mediaNetConnectionUrl=playmedia.netConnectionUrl;
						_mediaUrl=playmedia.mediaUrl;
						_mediaPosterUrl=playmedia.mediaPosterUrl;
						setInternalState(_recordUseWebcam ? RECORD_MICANDCAM_STATE : RECORD_MIC_STATE);
					} else if (recmedia){
						_mediaNetConnectionUrl=null;
						_mediaUrl=null;
						_mediaPosterUrl=null;
						_recordMediaNetConnectionUrl=recmedia.netConnectionUrl;
						_recordMediaUrl=recmedia.mediaUrl;
					}
					loadRecordVideo();
				} else {
					super.loadVideoByUrl(param);
				}
			}
		}
		
		protected function loadParallelVideo():void{
			_mediaReady=false;
			_parallelMediaReady=false;
			logger.info("Load parallel videos: {0}, {1}",[_mediaNetConnectionUrl+'/'+_mediaUrl, _parallelMediaNetConnectionUrl+'/'+_parallelMediaUrl]); 
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
				
				//Close the streams and free the their resources
				if(_media) _media.dispose();
				if(_parallelMedia) _parallelMedia.dispose();
				_media=null;
				_parallelMedia=null;
				
				if(_mediaNetConnectionUrl){
					_media=new ARTMPManager("leftStream");
					_media.addEventListener(MediaStatusEvent.STREAM_SUCCESS, onStreamSuccess, false, 0, true);
					_media.addEventListener(MediaStatusEvent.STREAM_FAILURE, onStreamFailure, false, 0, true);
					_media.setup(_mediaNetConnectionUrl, _mediaUrl);
				} else {
					_media=new AVideoManager("leftStream");
					_media.addEventListener(MediaStatusEvent.STREAM_SUCCESS, onStreamSuccess, false, 0, true);
					_media.addEventListener(MediaStatusEvent.STREAM_FAILURE, onStreamFailure, false, 0, true);
					_media.setup(_mediaUrl);
				}
				
				if(_parallelMediaNetConnectionUrl){
					_parallelMedia=new ARTMPManager("rightStream");
					_parallelMedia.addEventListener(MediaStatusEvent.STREAM_SUCCESS, onStreamSuccess, false, 0, true);
					_parallelMedia.addEventListener(MediaStatusEvent.STREAM_FAILURE, onStreamFailure, false, 0, true);
					_parallelMedia.setup(_parallelMediaNetConnectionUrl, _parallelMediaUrl);
				} else {
					_parallelMedia=new AVideoManager("rightStream");
					_parallelMedia.addEventListener(MediaStatusEvent.STREAM_SUCCESS, onStreamSuccess, false, 0, true);
					_parallelMedia.addEventListener(MediaStatusEvent.STREAM_FAILURE, onStreamFailure, false, 0, true);
					_parallelMedia.setup(_parallelMediaUrl);
				}
			}
		}
		
		public function loadRecordVideo():void{
			_mediaReady=false;
			_recordMediaReady=false;
			
			_busyIndicator.visible=true;
			resetAppearance();
				
			if(!_autoPlay){
				if(_mediaPosterUrl){
					_posterSprite = new BitmapSprite(_mediaPosterUrl, _lastWidth, _lastHeight);
					_topLayer.addChild(_posterSprite);
				}
			}
				
			//Close the streams and free their resources
			if(_media) _media.dispose();
			if(_recordMedia) _recordMedia.dispose();
			if(_parallelMedia) _parallelMedia.dispose();
			_media=null;
			_recordMedia=null;
			_parallelMedia=null;
			
			if(_mediaUrl != ''){
				if(_mediaNetConnectionUrl){
					_media=new ARTMPManager("playStream");
					_media.addEventListener(MediaStatusEvent.STREAM_SUCCESS, onStreamSuccess, false, 0, true);
					_media.addEventListener(MediaStatusEvent.STREAM_FAILURE, onStreamFailure, false, 0, true);
					_media.setup(_mediaNetConnectionUrl, _mediaUrl);
				} else {
					_media=new AVideoManager("playStream");
					_media.addEventListener(MediaStatusEvent.STREAM_SUCCESS, onStreamSuccess, false, 0, true);
					_media.addEventListener(MediaStatusEvent.STREAM_FAILURE, onStreamFailure, false, 0, true);
					_media.setup(_mediaUrl);
				}
			}
			if(_recordMediaUrl !=''){
				if(_recordMediaNetConnectionUrl){
					_recordMedia=new ARTMPManager("recordStream");
					_recordMedia.addEventListener(MediaStatusEvent.STREAM_SUCCESS, onStreamSuccess, false, 0, true);
					_recordMedia.addEventListener(MediaStatusEvent.STREAM_FAILURE, onStreamFailure, false, 0, true);
					_recordMedia.setup(_recordMediaNetConnectionUrl, _recordMediaUrl);
				} else {
					//To record media a netconnectionurl is a must, if not provided
					logger.debug("NetConnectionUrl for record media not provided. Can't record.");
					//onStreamFailure();
				}
			}
		}
		
		public function recordVideo(media:Object, useWebcam:Boolean, timemarkers:Object):void{	
			unattachUserDevices();
			if(_markermgr){
				removeEventListener(PollingEvent.ENTER_FRAME, _markermgr.onIntervalTimer);
			}
			
			//Set the timeline event markers
			if(timemarkers){
				if(setTimeMarkers(timemarkers)){
					_timeMarkers = timemarkers;
					//Add a listener to poll for event points
					addEventListener(PollingEvent.ENTER_FRAME, _markermgr.onIntervalTimer, false, 0, true);
					//Enable the timeline timer
					pollTimeline=true;
				} else {
					logger.debug("No event points found in given recdata");
				}
			} else {
				_timeMarkers = null;
				trace("No timemarker data");
			}
			
			_recordUseWebcam = useWebcam;
			
			//Set autoplay to false to avoid the exercise from playing once loading is done
			_lastAutoplay=_autoPlay;
			_autoPlay=false;
			_videoPlaying=false;
			
			if(media){
				//Load the exercise to play alongside the recording, if any
				loadVideoByUrl(media);
				//Remove the exercise poster, we don't need it when about to record something
				_topLayer.removeChildren();
			}
		}
		
		override public function resetComponent():void{
			hideCaption();
			_captionmgr.removeAllMarkers();
			state=VideoRecorder.PLAY_STATE;
			arrows=false;
			
			closeStreams();
			closeConnection();
		}
		
		override protected function onStreamSuccess(event:Event):void{
			var mobj:Object = event.currentTarget;
			
			//Deep equality of Object checks if both objects have the same memref
			if(mobj === _media){
				_mediaReady=true;
			}
			if(mobj === _parallelMedia){
				_parallelMediaReady=true;
			}
			if(mobj === _recordMedia){
				_recordMediaReady=true;
			}
			
			//State belongs to the recording state group
			if(_state & RECORD_MODE_MASK) 
			{
				if(_mediaReady && _recordMediaReady){
					_video.attachNetStream(_media.netStream);
					_media.volume=_currentVolume;
					_media.addEventListener(MediaStatusEvent.METADATA_RETRIEVED, onMetaData, false, 0, true);
					_media.addEventListener(MediaStatusEvent.STATE_CHANGED, onStreamStateChange, false, 0, true);
				
					_recordMedia.volume=_currentVolume;
					_recordMedia.addEventListener(MediaStatusEvent.STATE_CHANGED, onStreamStateChange, false, 0, true);
					
					prepareDevices();
				}
			} 
			else 
			{
				
			}
			super.onStreamSuccess(event);
		}
		
		override protected function onStreamStateChange(event:MediaStatusEvent):void{
			
			var streamId:String=event.streamid;
			
			if(event.state == AMediaManager.STREAM_SEEKING_START){
				_captionmgr.reset();
			}
			if(event.state == AMediaManager.STREAM_FINISHED){
				_captionmgr.reset();
				hideCaption();
			}
			super.onStreamStateChange(event);
		}
		
		private function closeStreams():void
		{
			destroyNetstream(_recordMedia);
			destroyNetstream(_parallelMedia);
			destroyVideo(_video);
		}
		
		private function destroyNetstream(nc:AMediaManager):void{
			if (nc && nc.netStream)
			{
				nc.netStream.attachCamera(null);
				nc.netStream.attachAudio(null);
				nc.netStream.close();
				nc=null;
			}
		}
		
		private function destroyVideo(video:Video):void{
			if(video){
				video.attachNetStream(null);
				video.attachCamera(null);
				video.clear();
				video=null;
			}
		}
		
		private function closeConnection():void
		{
			new FullStreamingEvent(FullStreamingEvent.CLOSE_CONNECTION).dispatch();
		}
	}
}
