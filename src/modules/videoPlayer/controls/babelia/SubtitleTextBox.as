package modules.videoPlayer.controls.babelia
{
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	import flash.text.FontStyle;
	import flash.text.engine.FontWeight;
	
	import flashx.textLayout.formats.TextAlign;
	
	import modules.videoPlayer.controls.SkinableComponent;
	
	import mx.controls.Text;
	
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.layouts.HorizontalAlign;
	import spark.layouts.VerticalAlign;

	public class SubtitleTextBox extends SkinableComponent
	{
		/**
		 * SKIN CONSTANTS
		 */
		public static const TEXT_COLOR:String="textColor";
		public static const BOX_COLOR:String="boxColor";
		public static const BORDER_COLOR:String="borderColor";
		public static const BG_COLOR:String="bgColor";

		//private var _box:Sprite;
		//private var _bg:Sprite;
		private var _textBox:Label;
		private var _boxWidth:Number=100;
		private var _boxHeight:Number=30;
		private var _defaultHeight:Number=30;
		
		private var _dropShadowFilter:DropShadowFilter;
		private var _group:HGroup;

		public function SubtitleTextBox()
		{
			super("SubtitleTextBox"); // Required for setup skinable component
			
			_dropShadowFilter = new DropShadowFilter();
			_dropShadowFilter.alpha = 1;
			_dropShadowFilter.distance = 0;
			_dropShadowFilter.color = 0x000000;
			_dropShadowFilter.strength = 15;
			_dropShadowFilter.blurX = 6;
			_dropShadowFilter.blurY = 6;
			
			_group = new HGroup();
			_group.verticalAlign = VerticalAlign.BOTTOM;
			_group.horizontalAlign = HorizontalAlign.CENTER;

			_textBox=new Label();
			_textBox.setStyle("textAlign", "center");
			_textBox.setStyle("fontWeight", FontWeight.BOLD);
			_textBox.setStyle("fontSize", 14);
			_textBox.filters = [_dropShadowFilter];
			
			_group.addElement(_textBox);
			
			addChild(_group);

			resize(_boxWidth, _boxHeight);
		}

		override public function availableProperties(obj:Array=null):void
		{
			super.availableProperties([BG_COLOR, BORDER_COLOR, BOX_COLOR, TEXT_COLOR]);
		}

		public function resize(width:Number, height:Number):void
		{
			this.width=width;
			this.height=height;
			
			_group.width = width;
			_group.height = height;

			//CreateBG(width, height);
			//CreateBox(_box, getSkinColor(BOX_COLOR), width - 5, height - 5, true, getSkinColor(BORDER_COLOR));
			//CreateBox(_box, getSkinColor(BOX_COLOR), width, height);
//			_box.x=width / 2 - _box.width / 2;
//			_box.y=height / 2 - _box.height / 2;
//
//			_textBox.x=_box.x;
//			_textBox.y=_box.y + 2;
//			_textBox.width=_box.width*0.9;
//			_textBox.height=_box.height;
			
			
			_textBox.width=_group.width*0.9;
//			_textBox.height=height;
//			_textBox.x=width / 2 - _textBox.width / 2;
//			_textBox.y=height / 2 - _textBox.height / 2 + 2;
			
			
			
		
			_textBox.setStyle("color", getSkinColor(TEXT_COLOR));
		}

		public function setText(text:String,textColor:uint=0xffffff):void
		{
			_textBox.setStyle("color", textColor);
			_textBox.text=text;
		}

		/*
		private function CreateBG(bgWidth:Number, bgHeight:Number):void
		{
			_bg.graphics.clear();
			//_bg.graphics.beginFill(getSkinColor(BG_COLOR));
			_bg.graphics.beginFill(getSkinColor(BG_COLOR),0.0);
			_bg.graphics.drawRect(0, 0, bgWidth, bgHeight);
			_bg.graphics.endFill();
		}

		private function CreateBox(b:Sprite, color:Object, bWidth:Number, bHeight:Number, border:Boolean=false, borderColor:uint=0, borderSize:Number=1):void
		{
			b.graphics.clear();
			//b.graphics.beginFill(color as uint);
			b.graphics.beginFill(color as uint, 0.0);
			if (border)
				b.graphics.lineStyle(borderSize, borderColor);
			b.graphics.drawRect(0, 0, bWidth, bHeight);
			b.graphics.endFill();
		}
		*/
	}
}