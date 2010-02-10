/**
 * NOTES
 * 
 * If seek is enabled arrows must be disabled
 */

package modules.videoPlayer
{
	import model.DataModel;
	import modules.videoPlayer.controls.babelia.SubtitleTextBox;
	import modules.videoPlayer.controls.babelia.LocaleComboBox;
	import modules.videoPlayer.controls.babelia.SubtitleButton;
	import modules.videoPlayer.controls.babelia.ArrowPanel;
	import modules.videoPlayer.controls.babelia.RoleTalkingPanel;
	import modules.videoPlayer.events.babelia.SubtitleButtonEvent;
	import modules.videoPlayer.events.babelia.SubtitleComboEvent;
	import modules.videoPlayer.events.babelia.StreamEvent;
	import modules.videoPlayer.VideoPlayer;
	
	import flash.display.*;
	import flash.media.*;
	import flash.net.*;
	import flash.events.*;
	import flash.utils.*;
	
	import mx.controls.Alert;
	import mx.controls.Text;

	import mx.core.UIComponent;
	import mx.collections.ArrayCollection;
	import mx.effects.AnimateProperty;
	import mx.events.EffectEvent;
	import events.ViewChangeEvent;

	public class VideoPlayerBabelia extends VideoPlayer
	{		
		/**
		 * Skin related constants
		 */
		public static const CAMBG_COLOR:String = "camBgColor";
		public static const COUNTDOWN_COLOR:String = "countdownColor";
		public static const ROLEBG_COLOR:String = "roleBgColor";
		public static const ROLEBORDER_COLOR:String = "roleBorderColor";
		
		/**
		 * Interface variables
		 */
		private var _subtitleButton:SubtitleButton;
		private var _subtitlePanel:UIComponent;
		private var _subtitleBox:SubtitleTextBox;
		private var _localeComboBox:LocaleComboBox;
		private var _arrowContainer:UIComponent;
		private var _arrowPanel:ArrowPanel;
		private var _roleTalkingPanel:RoleTalkingPanel;
		private var _bgArrow:Sprite;
		private var _bgCam:Sprite;
		
		/**
		 * Recording related variables
		 */
		// errors
		public static const ERR_NOCAMORMIC:String = "NOCAMORMIC";
		public static const ERR_NOMIC:String = "NOMIC";
		public static const ERR_CAMMICREFRESH:String = "CAMMICREFRESH";
		public static const ERR_MICREFRESH:String = "MICREFRESH";
		public static const ERR_ERROR:String = "ERROR"; 
		
		// states
		public static const PLAY_STATE:String = "playing";
		public static const RECORD_BOTH_STATE:String = "recordingBoth";
		public static const RECORD_MIC_STATE:String = "recordingMic";
		private var _state:String;
		
		private var _mic:Microphone;
		private var _micEnabled:Boolean = false;
		private var _volumeTransform:SoundTransform = new SoundTransform();
		
		private var _camera:Camera;
		private var _cameraEnabled:Boolean = false;
		private var _camWrapper:MovieClip;
		private var _camVideo:Video;
		
		private var _countdown:Timer;
		private var _countdownTxt:Text;
		private var _accessTimeout:Timer;
		
		private var _lastVideoHeight:Number;
		
		/**
		 * CONSTRUCTOR
		 */
		public function VideoPlayerBabelia()
		{
			super("VideoPlayerBabelia");
			
			_subtitleButton = new SubtitleButton();
			_videoBarPanel.addChild(_subtitleButton);
			
			_subtitlePanel = new UIComponent();
			
			_subtitleBox = new SubtitleTextBox();
			_subtitleBox.setText("PRUEBA DE SUBTITULOS");
			
			_localeComboBox = new LocaleComboBox();
			
			_subtitlePanel.visible = false;
			_subtitlePanel.addChild( _subtitleBox );
			_subtitlePanel.addChild( _localeComboBox );
			
			_arrowContainer = new UIComponent();
			
			_bgArrow = new Sprite();
			
			_arrowContainer.addChild(_bgArrow);
			_arrowPanel = new ArrowPanel();
			_roleTalkingPanel = new RoleTalkingPanel();
			
			_arrowContainer.visible = false;
			_arrowContainer.addChild(_arrowPanel);
			_arrowContainer.addChild(_roleTalkingPanel);
			
			_countdownTxt = new Text();
			_countdownTxt.text = "5";
			_countdownTxt.setStyle("fontWeight", "bold");
			_countdownTxt.setStyle("fontSize", 30);
			_countdownTxt.selectable = false;
			_countdownTxt.visible = false;
			
			_camWrapper = new MovieClip();
			_camVideo = new Video();
			_bgCam = new Sprite();
			_camWrapper.addChild(_bgCam);
			_camWrapper.addChild(_camVideo);
			_camWrapper.height = 0;
			_camWrapper.visible = false;
			
			//Event Listeners
			_subtitleButton.addEventListener( SubtitleButtonEvent.STATE_CHANGED, onSubtitleButtonClicked);
			_localeComboBox.addEventListener( SubtitleComboEvent.SELECTED_CHANGED, onLocaleChanged);
			
			/**
			 * Adds components to player
			 */
			removeChild(_videoBarPanel);
			addChild(_subtitlePanel);
			addChild(_arrowContainer);
			addChild(_videoBarPanel);
			addChild(_camWrapper);
			addChild(_countdownTxt);
			
			
			/**
			 * Adds skinable components to dictionary
			 */
			putSkinableComponent(COMPONENT_NAME, this);
			putSkinableComponent(_subtitleButton.COMPONENT_NAME, _subtitleButton);
			putSkinableComponent(_subtitleBox.COMPONENT_NAME, _subtitleBox);
			putSkinableComponent(_localeComboBox.COMPONENT_NAME, _localeComboBox);
			putSkinableComponent(_arrowPanel.COMPONENT_NAME, _arrowPanel);
			putSkinableComponent(_roleTalkingPanel.COMPONENT_NAME, _roleTalkingPanel);
			
			// Loads default skin
			skin = "default";
		}
		
		
		/**
		 * Setters and Getters
		 * 
		 */
		public function setSubtitle(text:String) : void
		{
			_subtitleBox.setText(text);
		}
		
		public function set subtitles(flag:Boolean) : void
		{
			_subtitlePanel.visible = flag;
			_subtitleButton.setEnabled(flag);
		}
		
		/**
		 * @param arrows: ArrayCollection[{time:Number,role:String}]
		 * @param selectedRole: selected role by the user.
		 * 						This makes the arrows be red or black.
		 */
		public function setArrows(arrows:ArrayCollection, selectedRole:String) : void
		{
			_arrowPanel.setArrows(arrows, _duration, selectedRole);
		}
		
		public function removeArrows() : void
		{
			_arrowPanel.removeArrows();
		}
		
		
		public function set arrows(flag:Boolean) : void
		{
			_arrowContainer.visible = flag;
		}
		
		public function setLocales(locales:ArrayCollection) : void
		{
			_localeComboBox.setDataProvider(locales);
		}
		
		public function startTalking(role:String, duration:Number) : void
		{
			if ( !_roleTalkingPanel.talking )
				_roleTalkingPanel.setTalking(role, duration);
		}
		
		public function set state(state:String) : void
		{
			_state = state;
			stopVideo();
			
			if ( state == RECORD_MIC_STATE && DataModel.getInstance().micAccessDenied ) 
			{
				goBackHome(ERR_MICREFRESH);
				return;
			}
			else if ( state == RECORD_BOTH_STATE && 
						(DataModel.getInstance().micAccessDenied || DataModel.getInstance().camAccessDenied) )
			{
				goBackHome(ERR_CAMMICREFRESH);
				return;
			}
			
			switch ( _state )
			{
				case RECORD_BOTH_STATE:
					// TODO: improve
					_camera = Camera.getCamera();
					_camera.addEventListener(StatusEvent.STATUS, camera_status);
				
					_mic = Microphone.getMicrophone();
					_mic.setUseEchoSuppression(true); 
					_mic.setLoopBack(true);
					_mic.addEventListener(StatusEvent.STATUS,mic_status);
				
					_accessTimeout = new Timer(1000, 5); // 5 sec to accept access
					_accessTimeout.addEventListener(TimerEvent.TIMER, onAccessTick);
					_accessTimeout.start();
					
					break;
			
				default:
					// NOTE: problems with _videoWrapper.width
					_videoHeight = _lastVideoHeight;

					_camWrapper.visible = false;
					_camVideo.attachCamera(null); // TODO: deattach camera
					
					if ( !autoScale )
						scaleVideo();
						
					this.updateDisplayList(0,0);
				
					playVideo();
					
					break;
			}
		}
		
		public function get state() : String
		{
			return _state;
		}
		
		/**
		 * Methods
		 * 
		 */
		
		/** Overriden */
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList( unscaledWidth, unscaledHeight );
			
			_camWrapper.width = _videoWidth/2 - 2;
			_camWrapper.height = _videoHeight;
			_camWrapper.x = _defaultMargin + _videoWidth/2 + 2;
			_camWrapper.y = _defaultMargin;
			
			_bgCam.graphics.clear();
			_bgCam.graphics.beginFill( getSkinColor(CAMBG_COLOR) );
			_bgCam.graphics.drawRect( 0, 0, _arrowContainer.width, _arrowContainer.height );
			_bgCam.graphics.endFill();
			
			var y1:Number = _subtitlePanel.visible? _subtitlePanel.height : 0;
			var y2:Number = _arrowContainer.visible? _arrowContainer.height : 0;
			
			_videoBarPanel.y += (y1+y2);
			
			_arrowContainer.width = _videoBarPanel.width;
			_arrowContainer.height = 50;
			_arrowContainer.y = _videoBarPanel.y - _arrowContainer.height;
			_arrowContainer.x = _defaultMargin;
			_bgArrow.graphics.clear();	
			_bgArrow.graphics.beginFill( getSkinColor(ROLEBORDER_COLOR) );
			_bgArrow.graphics.drawRect( 0, 0, _arrowContainer.width, _arrowContainer.height );
			_bgArrow.graphics.endFill();
			_bgArrow.graphics.beginFill( getSkinColor(ROLEBG_COLOR) );
			_bgArrow.graphics.drawRect( 1, 1, _arrowContainer.width-2, _arrowContainer.height-2 );
			_bgArrow.graphics.endFill();
			
			_subtitleButton.x = _audioSlider.x + _audioSlider.width;
			_subtitleButton.resize(45, 20);
			_sBar.width -= _subtitleButton.width;
			
			// Put subtitle box at top
			_subtitlePanel.y = _videoBarPanel.y - _videoBarPanel.height - y2;
			_subtitlePanel.width = _videoBarPanel.width;
			_subtitlePanel.height = 20;
			_subtitlePanel.x = _defaultMargin;

			_subtitleBox.resize(_videoWidth - 100, 20);
			
			// Resize arrowPanel
			_arrowPanel.resize(_sBar.width, _arrowContainer.height - 8);
			_arrowPanel.x = _sBar.x;
			_arrowPanel.y = 4;
			
			// Resize RolePanel
			_roleTalkingPanel.resize( _videoWidth - _defaultMargin*6 - _arrowPanel.width - _arrowPanel.x,
										 _arrowPanel.height);
			_roleTalkingPanel.x = _arrowPanel.x + _arrowPanel.width + _defaultMargin*3;
			_roleTalkingPanel.y = 4;
			
			_localeComboBox.x = _subtitleBox.x + _subtitleBox.width;
			_localeComboBox.resize(_videoWidth - _subtitleBox.width, _subtitleBox.height);
			
			_countdownTxt.x = _videoWidth/2 - 10;
			_countdownTxt.y = _videoHeight/2 - 10;
			_countdownTxt.width = _videoWidth;
			_countdownTxt.height = _videoHeight;
			_countdownTxt.setStyle("color", getSkinColor(COUNTDOWN_COLOR));
			
			drawBG();
		}
		
		override protected function drawBG() : void
		{
			/**
			 * Recalculate height
			 */
			var h1:Number = _subtitlePanel.visible? _subtitlePanel.height : 0;
			var h2:Number = _arrowContainer.visible? _arrowContainer.height : 0;
			
			totalHeight = _defaultMargin*2 + _videoHeight + h1 + h2 + _videoBarPanel.height;
			
			_bg.graphics.clear();

			_bg.graphics.beginFill( getSkinColor(BORDER_COLOR) );
			_bg.graphics.drawRoundRect( 0, 0, width, height, 15, 15 );
			_bg.graphics.endFill();
			_bg.graphics.beginFill( getSkinColor(BG_COLOR) );
			_bg.graphics.drawRoundRect( 3, 3, width-6, height-6, 12, 12 );
			_bg.graphics.endFill();
		}
		
		/**
		 * Adds a listener to video widget
		 */
		override public function playVideo() : void
		{
			super.playVideo();
			
			_video.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		/**
		 * Gives parent document an ENTER_FRAME based event
		 * with current stream time (CuePointManager should catch this)
		 */
		private function onEnterFrame(e:Event) : void
		{
			if ( _ns != null )
				this.dispatchEvent(new StreamEvent(StreamEvent.ENTER_FRAME, _ns.time));
		}
		
		/**
		 * Pauses talk if any role is talking
		 */
		override public function pauseVideo() : void
		{
			super.pauseVideo();
			
			if ( _roleTalkingPanel.talking )
				_roleTalkingPanel.pauseTalk();
		}
		
		/**
		 * Resumes talk if any role is talking
		 */
		override public function resumeVideo() : void
		{
			super.resumeVideo();
			
			if ( _roleTalkingPanel.talking )
				_roleTalkingPanel.resumeTalk();
		}
		
		/**
		 * Stops talk if any role is talking
		 */
		override public function stopVideo() : void
		{
			super.stopVideo();
			
			if ( _roleTalkingPanel.talking )
				_roleTalkingPanel.stopTalk();
		}
		
		/**
		 * Catch event and do show/hide subtitle panel
		 */
		private function onSubtitleButtonClicked( e:SubtitleButtonEvent ) : void
		{
			if ( e.state == SubtitleButton.SUBTITLES_ENABLED )
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
			a1.target = _subtitlePanel;
			a1.property = "alpha";
			a1.toValue = 1;
			a1.duration = 250;
			a1.play();
			
			var a2:AnimateProperty = new AnimateProperty();
			a2.target = _videoBarPanel;
			a2.property = "y";
			a2.toValue = _videoBarPanel.y + _subtitlePanel.height;
			a2.duration = 250;
			a2.play();
			
			var a3:AnimateProperty = new AnimateProperty();
			a3.target = _arrowContainer;
			a3.property = "y";
			a3.toValue = _arrowContainer.y + _subtitlePanel.height;
			a3.duration = 250;
			a3.play();
			
			this.drawBG(); // Repaint bg
		}
		
		/**
		 * Subtitle Panel's hide animation
		 */
		private function doHideSubtitlePanel() : void
		{
			var a1:AnimateProperty = new AnimateProperty();
			a1.target = _subtitlePanel;
			a1.property = "alpha";
			a1.toValue = 0;
			a1.duration = 250;
			a1.play();
			a1.addEventListener( EffectEvent.EFFECT_END, onHideSubtitleBar );
			
			var a2:AnimateProperty = new AnimateProperty();
			a2.target = _videoBarPanel;
			a2.property = "y";
			a2.toValue = _videoBarPanel.y - _subtitlePanel.height;
			a2.duration = 250;
			a2.play();
			
			var a3:AnimateProperty = new AnimateProperty();
			a3.target = _arrowContainer;
			a3.property = "y";
			a3.toValue = _arrowContainer.y - _subtitlePanel.height;
			a3.duration = 250;
			a3.play();
		}
		
		private function onHideSubtitleBar(e:Event) : void
		{
			_subtitlePanel.visible = false;
			this.drawBG(); // Repaint bg
		}
		
		// This gives the event to parent component
		private function onLocaleChanged(e:SubtitleComboEvent) : void
		{
			this.dispatchEvent(e);
		}
		
		
		
		/**
		 * When something is wrong
		 */
		private function goBackHome(err:String = ERR_ERROR) : void
		{
			// back to home
			new ViewChangeEvent(ViewChangeEvent.VIEW_HOME_MODULE).dispatch();
			// TODO: locale string
			Alert.show(resourceManager.getString('myResources', err));
		}
		

		/**
		 * Recording related commands
		 */
		// return if users has webcam
		public function hasCam() : Boolean
		{
			if (Camera.names.length>0) return true;
			else return false;
		}
		
		// Mic state - check for a mic
		public function  mic_status(evt:StatusEvent) : void
		{
			switch (evt.code) 
			{
				case "Microphone.Muted": // User denied access to camera, or hasn't got it
					DataModel.getInstance().micAccessDenied = true;
					break;
				case "Microphone.Unmuted": // User allowed access to camera
					if ( !_micEnabled )
						_micEnabled = true;
					break;
            }
		}
		
		// Camera state - check for a cam
		private function camera_status(evt:StatusEvent) : void 
		{
			switch (evt.code) 
			{
				case "Camera.Muted": // User denied access to camera, or hasn't got it
					DataModel.getInstance().camAccessDenied = true;
					break;
				case "Camera.Unmuted": // User allowed access to camera
					if ( !_cameraEnabled )
						_cameraEnabled = true;
					break;
			}
		}
		
		// Access timer as a timeout
		private function onAccessTick(tick:TimerEvent) : void
		{	
			if ( _cameraEnabled && _micEnabled )
			{
				_accessTimeout.stop();
				_accessTimeout.reset();
				
				_video.visible = false;
				_countdownTxt.visible = true;
				
				prepareRecording();
				
				_countdown = new Timer(1000, 5)
				_countdown.addEventListener(TimerEvent.TIMER, onCountdownTick);
				_countdown.start();
			}
			else if ( _accessTimeout.currentCount == 
						_accessTimeout.repeatCount )
			{
				state == RECORD_BOTH_STATE? 
					goBackHome(ERR_NOCAMORMIC) 
					: goBackHome(ERR_NOMIC);
				
				_accessTimeout.reset();
			}
		}
		
		// Countdown timer
		private function onCountdownTick(tick:TimerEvent) : void 
		{
			if ( _countdown.currentCount == _countdown.repeatCount )
			{
				_countdownTxt.visible = false;
				_video.visible = true;
				_camWrapper.visible = true;
				
				_countdownTxt.text = "5";
				_countdown.stop();
				_countdown.reset();
				
				startRecording();
			}
			else
				_countdownTxt.text = new String(5 - _countdown.currentCount);
		}
		
		
		/**
		 * Split video into 2 panels
		 */
		private function prepareRecording() : void 
		{
			_camVideo.attachCamera(_camera);
			
			// should be improved
			_videoWrapper.width = _videoWidth / 2 - 2;	
			var h:int = (_videoWidth / 2 - 2) * _videoHeight / _videoWidth;
			_lastVideoHeight = _videoHeight; // store last value
			_videoWrapper.height = h;
			_videoHeight = h;
			_video.x = 0;
			_video.y = 0;
			
			updateDisplayList(0,0);
		}
		
		/**
		 * Start recording
		 */
		private function startRecording() : void
		{
			
		}
	
	}
}