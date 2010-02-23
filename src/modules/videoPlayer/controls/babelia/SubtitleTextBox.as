package modules.videoPlayer.controls.babelia
{
	import mx.controls.Text;
	import mx.core.UIComponent;
	import flash.display.Sprite;
	import modules.videoPlayer.controls.SkinableComponent;
	
	public class SubtitleTextBox extends SkinableComponent
	{
		/**
		 * SKIN CONSTANTS
		 */
		public static const TEXT_COLOR:String = "textColor";
		public static const BOX_COLOR:String = "boxColor";
		public static const BORDER_COLOR:String = "borderColor";
		public static const BG_COLOR:String = "bgColor";
		
		private var _box:Sprite;
		private var _bg:Sprite;
		private var _textBox:Text;
		private var _boxWidth:Number = 100;
		private var _boxHeight:Number = 20;
		private var _defaultHeight:Number = 20;
		
		public function SubtitleTextBox()
		{
			super("SubtitleTextBox"); // Required for setup skinable component
			
			_bg = new Sprite();
			_box = new Sprite();
			
			addChild(_bg);
			addChild(_box);

			_textBox = new Text();
			_textBox.setStyle("textAlign", "center");
			_textBox.selectable = false;
			addChild( _textBox );

			resize(_boxWidth, _boxHeight);
		}
		
		override public function availableProperties(obj:Array = null) : void
		{
			super.availableProperties([BG_COLOR,BORDER_COLOR,BOX_COLOR,TEXT_COLOR]);
		}
		
		public function resize(width:Number, height:Number) : void
		{
			this.width = width;
			this.height = height;
			
			CreateBG( width, height );
			
			CreateBox( _box, getSkinColor(BOX_COLOR), width-5, height-5, true, getSkinColor(BORDER_COLOR) );
			_box.x = width/2 - _box.width/2;
			_box.y = height/2 - _box.height/2;
			
			_textBox.x = _box.x;
			_textBox.y = _box.y;
			_textBox.width = _box.width;
			_textBox.height = _box.height;
			_textBox.setStyle("color", getSkinColor(TEXT_COLOR));
		}
		
		public function setText(text:String) : void
		{
			_textBox.text = text;
		}
		
		private function CreateBG( bgWidth:Number, bgHeight:Number ):void
		{
			_bg.graphics.clear();
			_bg.graphics.beginFill( getSkinColor(BG_COLOR) );
			_bg.graphics.drawRect( 0, 0, bgWidth, bgHeight );
			_bg.graphics.endFill();
		}
		
		private function CreateBox( b:Sprite, color:Object, bWidth:Number, bHeight:Number, border:Boolean = false, 
				borderColor:uint = 0, borderSize:Number = 1 ) : void
		{
			b.graphics.clear();
			b.graphics.beginFill( color as uint );
			if( border ) b.graphics.lineStyle( borderSize, borderColor );
			b.graphics.drawRect( 0, 0, bWidth, bHeight );
			b.graphics.endFill();
		}
	}
}