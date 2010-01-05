/**
 * NOTES
 * 
 * Player needs a way to tell if a video exsists when streaming video.
 */

package modules.videoPlayer
{
	import modules.videoPlayer.controls.babelia.SubtitleTextBox;
	import modules.videoPlayer.controls.babelia.LocaleComboBox;
	import modules.videoPlayer.controls.babelia.SubtitleButton;
	import modules.videoPlayer.controls.babelia.ArrowPanel;
	import modules.videoPlayer.events.babelia.SubtitleButtonEvent;
	import modules.videoPlayer.events.babelia.SubtitleComboEvent;
	import modules.videoPlayer.VideoPlayer;
	
	import flash.display.Sprite;

	import mx.core.UIComponent;
	import mx.collections.ArrayCollection;
	import mx.effects.AnimateProperty;

	public class VideoPlayerBabelia extends VideoPlayer
	{
		
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
		private var _bgArrow:Sprite;
		
		
		public function VideoPlayerBabelia()
		{
			super();
			
			_subtitleButton = new SubtitleButton();
			_videoBarPanel.addChild(_subtitleButton);
			
			_subtitlePanel = new UIComponent();
			_subtitlePanel.visible = false;
			_subtitleBox = new SubtitleTextBox();
			_subtitleBox.setText("PRUEBA DE SUBTITULOS");
			_subtitlePanel.addChild( _subtitleBox );
			_localeComboBox = new LocaleComboBox();
			_subtitlePanel.addChild( _localeComboBox );
			
			_arrowContainer = new UIComponent();
			
			_bgArrow = new Sprite();
			
			_arrowContainer.addChild(_bgArrow);
			_arrowPanel = new ArrowPanel();
			_arrowContainer.visible = false;
			_arrowContainer.addChild(_arrowPanel);
			
			addChild(_subtitlePanel);
			addChild(_arrowContainer);
			
			//Event Listeners
			_subtitleButton.addEventListener( SubtitleButtonEvent.STATE_CHANGED, onSubtitleButtonClicked);
			_localeComboBox.addEventListener( SubtitleComboEvent.SELECTED_CHANGED, onLocaleChanged);
		}
		
		
		/**
		 * Setters and Getters
		 * 
		 */
		public function setSubtitle(text:String) : void
		{
			_subtitleBox.setText(text);
		}
		
		public function set Subtitles(flag:Boolean) : void
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
		
		
		public function set Arrows(flag:Boolean) : void
		{
			_arrowContainer.visible = flag;
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
			
			var y1:Number = _subtitlePanel.visible? _subtitlePanel.height : 0;
			var y2:Number = _arrowContainer.visible? _arrowContainer.height : 0;
			
			_videoBarPanel.y += (y1+y2);
			
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
			
			_localeComboBox.x = _subtitleBox.x + _subtitleBox.width;
			_localeComboBox.resize(this.width - _subtitleBox.width - 2*_defaultMargin, _subtitleBox.height);
			
			
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

			_bg.graphics.beginFill( 0x000000 );
			_bg.graphics.drawRoundRect( 0, 0, width, height, 15, 15 );
			_bg.graphics.endFill();
			_bg.graphics.beginFill( 0x343434 );
			_bg.graphics.drawRoundRect( 3, 3, width-6, height-6, 12, 12 );
			_bg.graphics.endFill();
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
			
			this.drawBG(); // Repaint bg
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
			
			this.drawBG(); // Repaint bg
		}
		
		// This gives the event to parent component
		private function onLocaleChanged(e:SubtitleComboEvent) : void
		{
			this.dispatchEvent(e);
		}
		
	}
}