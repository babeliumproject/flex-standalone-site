package view
{
	import flash.display.Sprite;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import mx.controls.Text;

	[SWF(backgroundColor="#808080")]
	public class TextOutlines extends Sprite
	{

		private var tf:TextField;
		private var borderWeight:Number;
		private var background:Sprite;

		public function TextOutlines(width:int, height:int, borderWeight:Number )
		{
//			stage.align=StageAlign.TOP_LEFT;
//			stage.scaleMode=StageScaleMode.NO_SCALE;

			tf=new TextField();
			tf.antiAliasType=AntiAliasType.ADVANCED;
			tf.defaultTextFormat=new TextFormat("Verdana", 12, null, true);
			tf.textColor=0xffffff;
			tf.text="";
//			tf.x=5;
//			tf.y=5;
			tf.autoSize = TextFieldAutoSize.CENTER;
			

			background=new Sprite();

			borderWeight=borderWeight;

			for (var i:int=-borderWeight; i <= borderWeight; i++)
			{
				for (var j:int=-borderWeight; j <= borderWeight; j++)
				{
					if (i == 0 && j == 0)
						continue;
					var otf:TextField=clone(tf);
					otf.selectable=false;
					otf.textColor=0x000000;
					otf.x=i;
					otf.y=j;
					background.addChild(otf);
				}
			}

//			background.x=tf.x;
//			background.y=tf.y;

			background.cacheAsBitmap=true;
			background.mouseEnabled=false;
			addChild(background);

			addChild(tf);
			
		}
		
		private function doTheMagic():void{
			removeChild(background);
			removeChild(tf);
			
			tf.x=5;
			tf.y=5;
			tf.width=tf.textWidth + 4;
			tf.height=tf.textHeight + 4;

			background=new Sprite();

			borderWeight=1.8;

			for (var i:int=-borderWeight; i <= borderWeight; i++)
			{
				for (var j:int=-borderWeight; j <= borderWeight; j++)
				{
					if (i == 0 && j == 0)
						continue;
					var otf:TextField=clone(tf);
					otf.selectable=false;
					otf.textColor=0x000000;
					otf.x=i;
					otf.y=j;
					background.addChild(otf);
				}
			}

			background.x=tf.x;
			background.y=tf.y;

			background.cacheAsBitmap=true;
			background.mouseEnabled=false;
			addChild(background);

			addChild(tf);
		}

		public function clone(tf:TextField):TextField
		{
			var otf:TextField=new TextField();
			for each (var prop:String in['defaultTextFormat', 'antiAliasType', 'text', 'width', 'height'])
			{
				otf[prop]=tf[prop];
			}
			return otf;
		}
		
		public function setOutLineWeight(weight:Number):void{
			this.borderWeight = weight;
		}
		
		public function setText(text:String):void{
			this.tf.text = text;
			doTheMagic();
		}
	}

}