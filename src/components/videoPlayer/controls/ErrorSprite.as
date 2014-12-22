package components.videoPlayer.controls
{
	import flash.display.Bitmap;
	import flash.display.GradientType;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	import mx.resources.ResourceManager;
	
	public class ErrorSprite extends Sprite
	{
		private var container_width:uint = 320;
		private var container_height:uint = 240;

		private var frame:Shape;
		private var textHolder:TextField;
		private var message:String;
		
		public function ErrorSprite(errorCode:String, unscaledWidth:uint, unscaledHeight:uint)
		{
			super();
		
			var msg:String=ResourceManager.getInstance().getString('myResources',errorCode);
			message = msg ? msg : "An error occurred. Please try again later.";
			updateDisplayList(unscaledWidth,unscaledHeight);
		}
		
		public function updateDisplayList(unscaledWidth:uint, unscaledHeight:uint):void{
			
			container_width  = !unscaledWidth  ? container_width  : unscaledWidth;
			container_height = !unscaledHeight ? container_height : unscaledHeight;
			
			var m:Matrix = new Matrix();
			m.createGradientBox(container_width, container_height, 90*Math.PI/180, 0, 0);
			this.graphics.clear();
			this.graphics.beginGradientFill(GradientType.LINEAR, [0x383838, 0x131313], [1,1], [80,255], m);
			this.graphics.drawRect(0, 0, container_width, container_height);
			this.graphics.endFill();
			
			var _textFormat:TextFormat = new TextFormat();
			_textFormat.align = "center";
			_textFormat.font = "arial,sans-serif";
			_textFormat.color=0xFFFFFF;
			//_textFormat.bold = true;
			_textFormat.size = Math.floor(container_height * .04); //Make the text's height proportional to the frame height
			
			textHolder = new TextField();
			textHolder.text = message;
			textHolder.setTextFormat(_textFormat);
			textHolder.width = container_width * .8;
			textHolder.autoSize = TextFieldAutoSize.CENTER;
			textHolder.wordWrap = true;
			textHolder.x = container_width/2 - textHolder.width/2;
			textHolder.y = container_height/2 - textHolder.height/2;
			textHolder.setTextFormat(_textFormat);
			
			this.addChild(textHolder);
			
		}
		
	}
}