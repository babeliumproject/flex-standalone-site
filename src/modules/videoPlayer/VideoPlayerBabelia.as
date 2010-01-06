/**
 * NOTES
 * 
 * If seek is enabled arrows must be disabled
 */

package modules.videoPlayer
{
	import modules.videoPlayer.controls.babelia.SubtitleTextBox;
	import modules.videoPlayer.controls.babelia.LocaleComboBox;
	import modules.videoPlayer.controls.babelia.SubtitleButton;
	import modules.videoPlayer.controls.babelia.ArrowPanel;
	import modules.videoPlayer.controls.babelia.RoleTalkingPanel;
	import modules.videoPlayer.events.babelia.SubtitleButtonEvent;
	import modules.videoPlayer.events.babelia.SubtitleComboEvent;
	import modules.videoPlayer.events.babelia.StreamEvent;
	import modules.videoPlayer.VideoPlayer;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import mx.controls.Alert;

	import mx.core.UIComponent;
	import mx.collections.ArrayCollection;
	import mx.effects.AnimateProperty;
	import mx.events.EffectEvent;

	public class VideoPlayerBabelia extends VideoPlayer
	{		
		/**
		 * Skin related constants
		 */
		public static const ROLEBG_COLOR:String = "roleBgColor";
		public static const ROLEBORDER_COLOR:String = "roleBorderColor";
		
		/**
		 * Variables
		 * 
		 */
		private var _subtitleButton:SubtitleButton;
		private var _subtitlePanel:UIComponent;
		private var _subtitleBox:SubtitleTextBox;
		private var _localeComboBox:LocaleComboBox;
		private var _arrowContainer:UIComponent;
		private var _arrowPanel:ArrowPanel;
		private var _roleTalkingPanel:RoleTalkingPanel;
		private var _bgArrow:Sprite;
		
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
			
			
			/**
			 * Adds skinable components to dictionary
			 */
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
		
		/**
		 * Methods
		 * 
		 */
		
		/** Overriden */
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList( unscaledWidth, unscaledHeight );
			
			var y1:Number = _subtitlePanel.visible? _subtitlePanel.height : 0;
			var y2:Number = _arrowContainer.visible? _arrowContainer.height : 0;
			
			_videoBarPanel.y += (y1+y2);
			
			_arrowContainer.width = _videoBarPanel.width;
			_arrowContainer.height = 50;
			_arrowContainer.y = _videoBarPanel.y - _arrowContainer.height;
			_arrowContainer.x = _defaultMargin;			
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
		
	}
}