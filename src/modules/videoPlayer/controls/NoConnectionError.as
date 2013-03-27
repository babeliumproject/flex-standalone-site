package modules.videoPlayer.controls
{
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.text.StaticText;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	public class NoConnectionError extends Sprite
	{
		
		private var dWidth:uint = 640;
		private var dHeight:uint = 480;
		private var dWidthBox:uint = dWidth*0.7;
		private var dHeigthBox:uint = dHeight*0.3;
			
		public function NoConnectionError()
		{
			super();
			
			this.graphics.beginFill(0x000000,1);
			this.graphics.drawRect(0,0,dWidth,dHeight);
			this.graphics.endFill();
			
			updateChildren();
			
		}
		
		public function updateChildren():void{
			
			var box:Shape = new Shape();
			var matr:Matrix = new Matrix();
			matr.createGradientBox(dWidthBox, dHeigthBox, 90*Math.PI/180, 0, 0);
			box.graphics.beginGradientFill(GradientType.LINEAR, [0xF5F5F5,0xE6E6E6], [1,1],[120,255],matr);
			box.graphics.lineStyle(4, 0x8A8A8A);
			box.graphics.drawRoundRect(this.width/2-(dWidthBox/2),this.height/2-(dHeigthBox/2),dWidthBox,dHeigthBox,16);
			
			box.graphics.endFill();
			
			var message:TextField = new TextField();
			message.htmlText = "<font size=\"24\" face=\"Arial\">No connection available</font>";
			message.selectable = false;
			message.autoSize = TextFieldAutoSize.CENTER;
			message.x = this.width/2 - message.textWidth/2;
			message.y = this.height/2 - message.textHeight/2;
			
			this.addChild(box);
			this.addChild(message);
		}
		
	}
}