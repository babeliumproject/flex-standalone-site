package modules.videoPlayer.controls
{
	import mx.controls.Button;
	import mx.core.UIComponent;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import modules.videoPlayer.events.SubtitleButtonEvent;
	
	public class SubtitleButton extends UIComponent
	{
		private var _bg:Sprite;
		private var _button:Button;
		private var _state:String;
		private var _boxWidth:Number = 40;
		private var _boxHeight:Number = 20;
		private var _boxColor:uint = 0xFFFFFF;
		private var _defaultHeight:Number = 20;
		
		public function SubtitleButton(state:Boolean = false)
		{
			super();
			
			_button = new Button();
			// Change button's padding
			_button.setStyle("paddingLeft", 2);
			_button.setStyle("paddingRight", 2);
			_button.setStyle("paddingTop", 2);
			_button.setStyle("paddingBottom", 2);
			_button.label = "SUB";
			_state = state? "enabled" : "disabled";

			_button.addEventListener(MouseEvent.CLICK, showHideSubtitles);

			resize(_boxWidth, _boxHeight);
		}
		
		public function resize(width:Number, height:Number) : void
		{
			while ( numChildren > 0 ) removeChildAt(0);
			
			this.width = width;
			this.height = height;
			
			CreateBG( width, height );
			
			_button.x = 2;
			_button.y = 2;
			_button.width = _boxWidth - 4;
			_button.height = _boxHeight -4;
			addChild( _button );
		}
		
		public function setEnabled(flag:Boolean) : void
		{
			_state = (!flag) ? "disabled" : "enabled";
			_button.enabled = flag;
		}
		
		private function showHideSubtitles(e:MouseEvent) : void
		{
			_state = (_state == "enabled") ? "disabled" : "enabled";
			this.dispatchEvent(new SubtitleButtonEvent(SubtitleButtonEvent.STATE_CHANGED, _state));
		}
		
		private function CreateBG( bgWidth:Number, bgHeight:Number ):void
		{
			_bg = new Sprite();
			_bg.graphics.beginFill( 0x343434 );
			_bg.graphics.drawRect( 0, 0, bgWidth, bgHeight );
			_bg.graphics.endFill();
			addChild(_bg);
			
		}
		
		private function CreateBox( color:Object, bWidth:Number, bHeight:Number, border:Boolean = false, borderColor:uint = 0, borderSize:Number = 1 ): Sprite
		{
			var b:Sprite = new Sprite();
			b.graphics.beginFill( color as uint );
			if( border ) b.graphics.lineStyle( borderSize, borderColor );
			b.graphics.drawRect( 0, 0, bWidth, bHeight );
			b.graphics.endFill();
			
			return b;
		}
	}
}