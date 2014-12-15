package components.videoPlayer
{
	import flash.display.Sprite;
	import flash.utils.ByteArray;
	
	import mx.controls.Text;
	
	[SWF(backgroundColor="#808080")]
	public class TextOutlines extends Sprite
	{
		
		private var tf:Text;
		private var borderWeight:Number;
		private var background:Sprite;
		
		public function TextOutlines(width:int, height:int, borderWeight:Number )
		{
			
			tf=new Text();
			tf.setStyle("fontAntiAliasType", "advanced");
			tf.setStyle("fontFamily","Verdana");
			tf.setStyle("fontSize", "12");
			tf.setStyle("color", "0xFFFFFF");
			tf.setStyle("fontWeight", "bold");
			tf.setStyle("textAlign", "center");
			tf.text="";
			tf.x=5;
			tf.y=5;
			tf.width = width;
			tf.height = height;
			
			
			background=new Sprite();
			
			borderWeight=borderWeight;
			
			for (var i:int=-borderWeight; i <= borderWeight; i++)
			{
				for (var j:int=-borderWeight; j <= borderWeight; j++)
				{
					if (i == 0 && j == 0)
						continue;
					var otf:Text=clone(tf);
					otf.selectable=false;
					otf.setStyle("color", "0x000000");
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
					var otf:Text=clone(tf);
					otf.selectable=false;
					otf.setStyle("color", "0x000000");
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
		
		
		public function clone(tf:Text):Text
		{
			var otf:Text=new Text();
			for each (var prop:String in['text', 'width', 'height'])
			{
				otf[prop]=tf[prop];	
			}
			otf.setStyle("fontAntiAliasType", "advanced");
			otf.setStyle("fontFamily","Verdana");
			otf.setStyle("fontSize", "12");
			otf.setStyle("fontWeight", "bold");
			otf.setStyle("textAlign", "center");
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