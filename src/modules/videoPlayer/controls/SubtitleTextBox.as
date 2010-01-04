package modules.videoPlayer.controls
{
	import mx.controls.Text;
	import mx.core.UIComponent;
	import flash.display.Sprite;
	
	public class SubtitleTextBox extends UIComponent
	{
		private var _box:Sprite;
		private var _bg:Sprite;
		private var _textBox:Text;
		private var _boxWidth:Number = 100;
		private var _boxHeight:Number = 20;
		private var _boxColor:uint = 0xFFFFFF;
		private var _defaultHeight:Number = 20;
		
		public function SubtitleTextBox()
		{
			super();

			_textBox = new Text();
			_textBox.setStyle("textAlign", "center");

			resize(_boxWidth, _boxHeight);
		}
		
		public function resize(width:Number, height:Number) : void
		{
			while ( numChildren > 0 ) removeChildAt(0);
			
			this.width = width;
			this.height = height;
			
			CreateBG( width, height );
			
			_box = CreateBox( _boxColor, width-5, height-5, true, 0x00000 );
			_box.x = width/2 - _box.width/2;
			_box.y = height/2 - _box.height/2;
			addChild( _box );
			
			_textBox.x = _box.x;
			_textBox.y = _box.y;
			_textBox.width = _box.width;
			_textBox.height = _box.height;
			addChild( _textBox );
		}
		
		public function setText(text:String) : void
		{
			_textBox.text = text;
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			//super.updateDisplayList( unscaledWidth, unscaledHeight );
		}
		
		private function CreateBG( bgWidth:Number, bgHeight:Number ):void
		{
			_bg = new Sprite();
			_bg.graphics.beginFill( 0x343434 );
			_bg.graphics.drawRect( 0, 0, bgWidth, bgHeight );
			_bg.graphics.endFill();
			addChildAt(_bg, 0);
			
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