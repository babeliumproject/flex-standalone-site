package modules.videoPlayer.controls.babelia
{
	import mx.controls.Button;
	import mx.core.UIComponent;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import modules.videoPlayer.events.babelia.SubtitleButtonEvent;
	import modules.videoPlayer.controls.SkinableComponent;
	
	public class SubtitleButton extends SkinableComponent
	{
		/**
		 * CONSTANTS
		 */
		public static const SUBTITLES_ENABLED:String = "enabled";
		public static const SUBTITLES_DISABLED:String = "disabled";
		
		/**
		 * SKIN CONSTANTS
		 */
		public static const BG_COLOR:String = "bgColor";
		
		/**
		 * VARIABLES
		 */
		private var _bg:Sprite;
		private var _button:Button;
		private var _state:String;
		private var _boxWidth:Number = 40;
		private var _boxHeight:Number = 20;
		private var _boxColor:uint = 0xFFFFFF;
		private var _defaultHeight:Number = 20;
		
		public function SubtitleButton(state:Boolean = false)
		{
			super("SubtitleButton"); // Required for setup skinable component
			
			_bg = new Sprite();
			addChild(_bg);
			
			_button = new Button();
			// Change button's padding
			_button.setStyle("paddingLeft", 2);
			_button.setStyle("paddingRight", 2);
			_button.setStyle("paddingTop", 2);
			_button.setStyle("paddingBottom", 2);
			_button.label = "SUB";
			addChild( _button );
			
			_state = state? SUBTITLES_ENABLED : SUBTITLES_DISABLED;

			_button.addEventListener(MouseEvent.CLICK, showHideSubtitles);

			resize(_boxWidth, _boxHeight);
		}
		
		override public function availableProperties(obj:Array = null) : void
		{
			super.availableProperties([BG_COLOR]);
		}
		
		public function resize(width:Number, height:Number) : void
		{
			this.width = width;
			this.height = height;
			
			CreateBG( width, height );
			
			_button.x = 2;
			_button.y = 2;
			_button.width = _boxWidth - 4;
			_button.height = _boxHeight -4;
		}
		
		public function setEnabled(flag:Boolean) : void
		{
			_state = (!flag) ? SUBTITLES_DISABLED: SUBTITLES_ENABLED;
			_button.enabled = flag;
		}
		
		private function showHideSubtitles(e:MouseEvent) : void
		{
			_state = (_state == SUBTITLES_ENABLED) ? SUBTITLES_DISABLED : SUBTITLES_ENABLED;
			this.dispatchEvent(new SubtitleButtonEvent(SubtitleButtonEvent.STATE_CHANGED, _state));
		}
		
		private function CreateBG( bgWidth:Number, bgHeight:Number ):void
		{
			_bg.graphics.clear();
			_bg.graphics.beginFill( getSkinColor(BG_COLOR) );
			_bg.graphics.drawRect( 0, 0, bgWidth, bgHeight );
			_bg.graphics.endFill();
		}
	}
}