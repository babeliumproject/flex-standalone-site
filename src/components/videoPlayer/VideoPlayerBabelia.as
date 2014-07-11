/**
 * NOTES
 *
 */

package components.videoPlayer
{
	import modules.exercise.event.ResponseEvent;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Matrix;
	import flash.media.*;
	import flash.net.*;
	import flash.utils.*;
	
	import model.DataModel;
	
	import components.videoPlayer.controls.PlayButton;
	import components.videoPlayer.controls.babelia.ArrowPanel;
	import components.videoPlayer.controls.babelia.MicActivityBar;
	import components.videoPlayer.controls.babelia.RecStopButton;
	import components.videoPlayer.controls.babelia.RoleTalkingPanel;
	import components.videoPlayer.controls.babelia.SubtitleButton;
	import components.videoPlayer.controls.babelia.SubtitleStartEndButton;
	import components.videoPlayer.controls.babelia.SubtitleTextBox;
	import components.videoPlayer.events.PlayPauseEvent;
	import components.videoPlayer.events.VideoPlayerEvent;
	import components.videoPlayer.events.babelia.RecStopButtonEvent;
	import components.videoPlayer.events.babelia.RecordingEvent;
	import components.videoPlayer.events.babelia.StreamEvent;
	import components.videoPlayer.events.babelia.SubtitleButtonEvent;
	import components.videoPlayer.events.babelia.SubtitlingEvent;
	import components.videoPlayer.events.babelia.VideoPlayerBabeliaEvent;
	
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
	
	import skins.OverlayPlayButtonSkin;
	
	import spark.components.Button;
	import spark.primitives.BitmapImage;
	
	import view.common.PrivacyRights;
	
	import vo.ResponseVO;

	public class VideoPlayerBabelia extends VideoPlayer
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
		public static const RECORD_BOTH_STATE:int=3; // 0000 0011
		public static const UPLOAD_MODE_STATE:int=4; // 0000 0100

		private const SPLIT_FLAG:int=1; // XXXX XXX1
		private const RECORD_FLAG:int=2; // XXXX XX1X
		private const UPLOAD_FLAG:int=4; // XXXX X1XX

		private var _state:int;

		// Other constants
		private const RESPONSE_FOLDER:String=DataModel.getInstance().responseStreamsFolder;
		private const DEFAULT_VOLUME:Number=40;
		private const COUNTDOWN_TIMER_SECS:int=5;

		private var _outNs:NetStreamClient;
		private var _inNs:NetStreamClient;
		private var _secondStreamSource:String;

		private var _mic:Microphone;
		private var _volumeTransform:SoundTransform=new SoundTransform();

		private var _camera:Camera;
		private var _camVideo:Video;
		private var _defaultCamWidth:Number=DataModel.getInstance().cameraWidth;
		private var _defaultCamHeight:Number=DataModel.getInstance().cameraHeight;
		private var _blackPixelsBetweenVideos:uint = 0;
		private var _lastVideoHeight:Number=0;

		private var _micCamEnabled:Boolean=false;

		private var privacyRights:PrivacyRights;

		private var _countdown:Timer;
		private var _countdownTxt:Text;

		private var _fileName:String;
		private var _recordingMuted:Boolean=false;

	

		public static const SECONDSTREAM_READY_STATE:int=0;
		public static const SECONDSTREAM_STARTED_STATE:int=1;
		public static const SECONDSTREAM_STOPPED_STATE:int=2;
		public static const SECONDSTREAM_FINISHED_STATE:int=3;
		public static const SECONDSTREAM_PAUSED_STATE:int=4;
		public static const SECONDSTREAM_UNPAUSED_STATE:int=5;
		public static const SECONDSTREAM_BUFFERING_STATE:int=6;

		[Bindable]
		public var secondStreamState:int;

		private var _cuePointTimer:Timer;

		public static const SUBTILE_INSERT_DELAY:Number=0.5;

		private var _micImage:Image;
		private var _overlayButton:Button;


		/**
		 * CONSTRUCTOR
		 */
		public function VideoPlayerBabelia()
		{
			super("VideoPlayerBabelia"); // Required for setup skinable component

			_subtitleButton=new SubtitleButton();
			_videoBarPanel.addChild(_subtitleButton);

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

			_micImage.source = DataModel.getInstance().uploadDomain+"resources/images/player_mic_watermark.png";
			_micImage.height = 128;
			_micImage.width = 128;
			_micImage.alpha = 0.7;
			_micImage.autoLoad = true;
			_micImage.visible = false;
	
			_subtitleStartEnd=new SubtitleStartEndButton();
			_subtitleStartEnd.visible=false;
			
			_videoBarPanel.addChild(_subtitleStartEnd);

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
			removeChild(_videoBarPanel); // order
			addChild(_micActivityBar);
			addChild(_arrowContainer);
			
			addChild(_micImage);
			addChild(_camVideo);

			addChild(_subtitlePanel);
			addChild(_videoBarPanel);
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

			// Loads default skin
			skin="default";
		}


		/**
		 * Setters and Getters
		 *
		 */
		public function setSubtitle(text:String, textColor:uint=0xffffff):void
		{
			_subtitleBox.setText(text, textColor);
		}

		public function set subtitles(flag:Boolean):void
		{
			_subtitlePanel.visible=flag;
			_subtitleButton.setEnabled(flag);
			this.updateDisplayList(0, 0);
		}

		public function get subtitlePanelVisible():Boolean
		{
			return _subtitlePanel.visible;
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
		 * Enable/disable subtitling controls
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

		/*
		public function set recControls(value:Boolean):void
		{
			_recStopBtn.recMode=value;	
		}
		
		public function get recControls():Boolean
		{
			return _recStopBtn.recMode;
		}
		
		public function onRecStopEvent(event:RecStopButtonEvent):void{
			if(recControls){
				if(event.state==RecStopButton.REC_STATE){
					state=UPLOAD_MODE_STATE;
				}else{
					Alert.show("Stop recording");
					onVideoFinishedPlaying(new VideoPlayerEvent(VideoPlayerEvent.VIDEO_FINISHED_PLAYING));
				}
			} else {
				stopVideo();
			}
		}
		*/
		
		/**
		 * Autoplay
		 */
		override public function set autoPlay(tf:Boolean):void
		{
			super.autoPlay=tf;
			tf ? _overlayButton.visible=false : _overlayButton.visible=true;
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

		override protected function onPPBtnChanged(e:PlayPauseEvent):void
		{
			super.onPPBtnChanged(e);
			if(_overlayButton.visible)
				_overlayButton.visible=false;
		}

		/**
		 * Mute sound
		 **/
		public function muteVideo(flag:Boolean):void
		{
			_audioSlider.muted=flag;
		}

		public function muteRecording(flag:Boolean):void
		{
			if (_recordingMuted == flag)
				return;
			_recordingMuted=flag;

			if (state & RECORD_FLAG)
				(flag) ? _mic.gain=0 : _mic.gain=DEFAULT_VOLUME;
			else if (state == PLAY_BOTH_STATE)
			{
				if (flag && _inNs && _inNs.netStream){
					_inNs.netStream.soundTransform=new SoundTransform(0);
				}else if (_inNs && _inNs.netStream){
					_inNs.netStream.soundTransform=new SoundTransform(DEFAULT_VOLUME / 100);
				}
			}
		}

		/**
		 * Adds new source to play_both video state
		 **/
		public function set secondSource(source:String):void
		{
			trace("[INFO] Video player: Second video added to stage");
			if (state != PLAY_BOTH_STATE)
				return;

			_secondStreamSource=source;

			if (_nc == null)
			{
				if (_video != null)
					_video.clear();
				return;
			}
			else
				playSecondStream();

			// splits video panel into 2 views
			splitVideoPanel();
		}

		private function netSecurityError(e:SecurityErrorEvent):void
		{
			//Avoid debug messages
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
			return _ns ? _ns.time : 0;
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

			_arrowContainer.width=_videoBarPanel.width;
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
			_subtitlePanel.width=_videoBarPanel.width;
			_subtitlePanel.height=_videoHeight*0.75;
			_subtitlePanel.x=_defaultMargin;
			/*
			 * Subtitle panel
			 */
			var y2:Number=_arrowContainer.visible ? _arrowContainer.height : 0;
			var y3:Number=_micActivityBar.visible ? _micActivityBar.height: 0;

			_videoBarPanel.y+=y3 + y2;

			_arrowContainer.y=_videoBarPanel.y - _arrowContainer.height;
			_subtitlePanel.y=_videoHeight - _subtitlePanel.height;

			_micActivityBar.y=_videoBarPanel.y - y2 - _micActivityBar.height;


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

			totalHeight=_videoHeight + h2 + h4 + _videoBarPanel.height;

			_bg.graphics.clear();

			_bg.graphics.beginFill(getSkinColor(BG_COLOR));
			_bg.graphics.drawRect(0, 0, width, height);
			_bg.graphics.endFill();
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

			if (!_cuePointTimer)
			{
				_cuePointTimer=new Timer(20, 0); //Try to tick every 20ms
				_cuePointTimer.addEventListener(TimerEvent.TIMER, onEnterFrame);
				_cuePointTimer.start();
			}
		}

		/**
		 * Gives parent component an ENTER_FRAME event
		 * with current stream time (CuePointManager should catch this)
		 */
		private function onEnterFrame(e:TimerEvent):void
		{
			if (_ns != null)
				this.dispatchEvent(new StreamEvent(StreamEvent.ENTER_FRAME, _ns.time));
		}

		/**
		 * Overriden pause video:
		 * - Pauses talk if any role is talking
		 * - Pauses second stream if any
		 */
		override public function pauseVideo():void
		{
			super.pauseVideo();

			if (_roleTalkingPanel.talking)
				_roleTalkingPanel.pauseTalk();

			if (state & RECORD_FLAG && _micCamEnabled) // TODO: test
				_outNs.netStream.pause();

			if (state == PLAY_BOTH_STATE){
				_inNs.netStream.pause();
			}
		}

		/**
		 * Overriden resume video:
		 * - Resumes talk if any role is talking
		 * - Resumes secon stream if any
		 */
		override public function resumeVideo():void
		{
			super.resumeVideo();

			if (_roleTalkingPanel.talking)
				_roleTalkingPanel.resumeTalk();

			if (state & RECORD_FLAG && _micCamEnabled) // TODO: test
				_outNs.netStream.resume();

			if (state == PLAY_BOTH_STATE){
				_inNs.netStream.resume();
			}
		}

		/**
		 * Overriden stop video:
		 * - Stops talk if any role is talking
		 * - Stops second stream if any
		 */
		override public function stopVideo():void
		{
			super.stopVideo();

			if (_roleTalkingPanel.talking)
				_roleTalkingPanel.stopTalk();

			if (state & RECORD_FLAG && _micCamEnabled)
				_outNs.netStream.close();

			if (state == PLAY_BOTH_STATE)
			{
				if (_inNs && _inNs.netStream)
				{
					_inNs.netStream.play(false);
				}
			}

			setSubtitle("");
		}

		override public function endVideo():void
		{
			super.endVideo();

			if (state == PLAY_BOTH_STATE && _inNs && _inNs.netStream)
			{
				_inNs.netStream.dispose();
				_inNs=null;
			}
		}

		/**
		 * Overriden on seek end:
		 * - clear subtitles from panel
		 **/
		override protected function onScrubberDropped(e:Event):void
		{
			super.onScrubberDropped(e);

			this.setSubtitle("");
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
			var time:Number=_ns != null ? _ns.time : 0;

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
				case RECORD_BOTH_STATE:
					prepareDevices();
					break;

				case RECORD_MIC_STATE:
					recoverVideoPanel(); // original size
					prepareDevices();
					break;
				
				case UPLOAD_MODE_STATE:
					recoverVideoPanel();
					scaleCamVideo(_videoWidth,_videoHeight,false);
					prepareDevices();
					break;

				case PLAY_BOTH_STATE:
					_micActivityBar.visible=false;
					this.updateDisplayList(0,0);
					break;

				default: // PLAY_STATE
					recoverVideoPanel();
					_camVideo.attachCamera(null); // TODO: deattach camera
					_camVideo.visible=false;
					_micImage.visible=false;

					this.updateDisplayList(0, 0);

					// Enable seek
					seek=true;

					break;
			}
		}

		/**
		 * Countdown before recording
		 */

		// Prepare countdown timer
		private function startCountdown():void
		{
			_countdown=new Timer(1000, COUNTDOWN_TIMER_SECS)
			_countdown.addEventListener(TimerEvent.TIMER, onCountdownTick);
			_countdown.start();
		}

		// On Countdown tick
		private function onCountdownTick(tick:TimerEvent):void
		{
			if (_countdown.currentCount == _countdown.repeatCount)
			{
				_countdownTxt.visible=false;
				_video.visible=true;

				if (state == RECORD_BOTH_STATE || state == UPLOAD_MODE_STATE)
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


		/**
		 * Methods to prepare the recording
		 */
		private function prepareDevices():void
		{
			//The devices are permitted and initialized. Time to configure them
			if ((state == RECORD_MIC_STATE && PrivacyRights.microphoneReady()) || 
				(state == RECORD_BOTH_STATE && PrivacyRights.cameraReady() && PrivacyRights.microphoneReady()) ||
				(state == UPLOAD_MODE_STATE && PrivacyRights.cameraReady() && PrivacyRights.microphoneReady()))
			{
				configureDevices();
			}
			else
			{
				if (state == RECORD_BOTH_STATE || state == UPLOAD_MODE_STATE)
					PrivacyRights.useMicAndCamera=true;
				if (state == RECORD_MIC_STATE)
					PrivacyRights.useMicAndCamera=false;
				privacyRights=PrivacyRights(PopUpManager.createPopUp(FlexGlobals.topLevelApplication.parent, PrivacyRights, true));
				privacyRights.addEventListener(CloseEvent.CLOSE, privacyBoxClosed);

				PopUpManager.centerPopUp(privacyRights);
			}
		}

		private function configureDevices():void
		{	
			if (state == RECORD_BOTH_STATE || state == UPLOAD_MODE_STATE)
			{
				_camera=DataModel.getInstance().camera;
				_camera.setMode(DataModel.getInstance().cameraWidth, DataModel.getInstance().cameraHeight, 15, false);
			}
			_mic=DataModel.getInstance().microphone;
			_mic.setUseEchoSuppression(true);
			_mic.setLoopBack(true);
			_mic.setSilenceLevel(0, 60000000);

			_video.visible=false;
			_micImage.visible=false;
			_countdownTxt.visible=true;

			prepareRecording();
			startCountdown();
		}

		/*
		public function micActivityHandler(event:ActivityEvent):void
		{
			//The mic has received an input louder than the 0% volume, so there's a mic working correctly.
			if (event.activating)
			{
				DataModel.getInstance().gapsWithNoSound=0;
				DataModel.getInstance().soundDetected=true;
				DataModel.getInstance().microphone.removeEventListener(ActivityEvent.ACTIVITY, micActivityHandler);
			}
		}*/

		private function privacyBoxClosed(event:Event):void
		{
		
			PopUpManager.removePopUp(privacyRights);
			_micCamEnabled=DataModel.getInstance().micCamAllowed;
			if (state == RECORD_MIC_STATE)
			{
				if (_micCamEnabled && PrivacyRights.microphoneFound)
					configureDevices();
				else
					dispatchEvent(new RecordingEvent(RecordingEvent.ABORTED));
			}
			if (state == RECORD_BOTH_STATE || state == UPLOAD_MODE_STATE)
			{
				if (_micCamEnabled && PrivacyRights.microphoneFound && PrivacyRights.cameraFound)
					configureDevices();
				else
					dispatchEvent(new RecordingEvent(RecordingEvent.ABORTED));
			}
		}

		// splits panel into a 2 different views
		private function prepareRecording():void
		{
			// Disable seek
			seek=false;
			_mic.setLoopBack(false);

			if (state & SPLIT_FLAG)
			{
				// Attach Camera
				_camVideo.attachCamera(_camera);
				_camVideo.smoothing=true;

				splitVideoPanel();
				_camVideo.visible=false;
				_micImage.visible=false;
				disableControls();
			}

			if (state & RECORD_FLAG)
			{
				_outNs=new NetStreamClient(_nc,"outNs");
				disableControls();
			}
			
			if(state & UPLOAD_FLAG){
				// Attach Camera
				_camVideo.attachCamera(_camera);
				_camVideo.smoothing=true;
				
				//	splitVideoPanel();
				_camVideo.visible=false;
				_micImage.visible=false;
				_outNs=new NetStreamClient(_nc,"outNs");
			}

			_micActivityBar.visible=true;
			_micActivityBar.mic=_mic;
			this.updateDisplayList(0, 0);
		}

		/**
		 * Start recording
		 */
		private function startRecording():void
		{
			if (!(state & RECORD_FLAG))
				return; // security check

			var d:Date=new Date();
			_fileName="resp-" + d.getTime().toString();
			var responseFilename:String=RESPONSE_FOLDER + "/" + _fileName;

			//if (_started)
			//	resumeVideo();
			//else
			playVideo();

			if (state & RECORD_FLAG)
			{
				_outNs.netStream.attachAudio(_mic);
				muteRecording(true); // mic starts muted
			}

			if (state == RECORD_BOTH_STATE)
				_outNs.netStream.attachCamera(_camera);

			_ppBtn.State=PlayButton.PAUSE_STATE;

			_outNs.netStream.publish(responseFilename, "record");

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
		
			var scaleY:Number=h / _defaultCamHeight;
			var scaleX:Number=w / _defaultCamWidth;
			var scaleC:Number=scaleX < scaleY ? scaleX : scaleY;

			_camVideo.width=_defaultCamWidth * scaleC;
			_camVideo.height=_defaultCamHeight * scaleC;

			if(split){
				_camVideo.y=Math.floor(h / 2 - _camVideo.height / 2);
				_camVideo.x=Math.floor(w / 2 - _camVideo.width / 2);
				_camVideo.y+=_defaultMargin;
				_camVideo.x+=(w + _defaultMargin);
				
				//trace("[INFO] Video player Babelium: CAM SCALE Video area dimensions: "+_videoWidth+"x"+_videoHeight+" cam dimensions: "+_camVideo.width+"x"+_camVideo.height+" cam placement: x="+_camVideo.x+" y="+_camVideo.y+" last video area heigth: "+_lastVideoHeight);
				
				
				// 1 black pixel, being smarter
				//_camVideo.y+=1;
				//_camVideo.height-=2;
				//_camVideo.x+=1;
				//_camVideo.width-=2;
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
			if (state & SPLIT_FLAG)
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

			if (state & RECORD_FLAG || state == UPLOAD_MODE_STATE)
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

		/**
		 * Flash 11.2.x has a bug that makes audio only FLV files non-playable. This workaround adds a dummy video stream to those files to recover
		 * the playback functionality while Adobe fixes this bug.
		 */
		/*
		protected function addDummyVideo():void{
			var r:ResponseVO = new ResponseVO();
			r.fileIdentifier = _fileName;
			new ResponseEvent(ResponseEvent.ADD_DUMMY_VIDEO,r).dispatch();
		}
		*/
		
		public function unattachUserDevices():void{
			if (_outNs && _outNs.netStream)
			{
				_outNs.netStream.attachCamera(null);
				_outNs.netStream.attachAudio(null);
				_camVideo.clear();
				_camVideo.attachCamera(null);
			}
		}

		/**
		 * PLAY_BOTH related commands
		 **/
		private function playSecondStream():void
		{
			if (_inNs && _inNs.netStream){
				_inNs.netStream.dispose();
			}

			if (_nc && _nc.connected)
			{
				_inNs=new NetStreamClient(_nc,"inNs");
				_inNs.netStream.soundTransform=new SoundTransform(_audioSlider.getCurrentVolume());

				_camVideo.clear();
				_camVideo.attachNetStream(_inNs.netStream);
				_camVideo.visible=true;
				_micImage.visible=true;

				_inNs.netStream.play(_secondStreamSource);

				// Needed for video mute
				muteRecording(false);
				muteRecording(true);

				if (_ns != null)
				{
					//_ns.resume();
					_ns.play(super.videoSource);
				}
				_ppBtn.State=PlayButton.PAUSE_STATE;
			}
		}
	}
}
