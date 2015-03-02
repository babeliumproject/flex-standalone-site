package components.videoPlayer.controls
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	
	import components.videoPlayer.IDisposableObject;

	public class BitmapSprite extends Sprite implements IDisposableObject
	{
		private var img:Bitmap;
		private var img_width:uint;
		private var img_height:uint;
		private var container_width:uint = 320;
		private var container_height:uint = 240;
		
		private var loader:Loader;
		private var request:URLRequest;

		public function BitmapSprite(url:String, unscaledWidth:uint, unscaledHeight:uint)
		{
			super();
			updateDisplayList(unscaledWidth,unscaledHeight);
			loadAsset(url);
		}
		
		public function dispose():void{
			if(loader){
				loader.removeEventListener(Event.COMPLETE, completeHandler);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			}
		}

		public function updateDisplayList(unscaledWidth:uint, unscaledHeight:uint):void
		{
			container_width  = !unscaledWidth  ? container_width  : unscaledWidth;
			container_height = !unscaledHeight ? container_height : unscaledHeight;
			
			this.graphics.clear();
			this.graphics.beginFill(0x000000, 0);
			this.graphics.drawRect(0, 0, container_width, container_height);
			this.graphics.endFill();
			
			if(img){
				scale(img, img_width, img_height, container_width, container_height);
			}
		}
		
		protected function scale(target:DisplayObject, target_width:uint, target_height:uint, container_width:uint, container_height:uint):void{
			
			//Get the scale factor of each dimension, pick the smaller one to maintain the aspect ratio of the DisplayObject
			var scaleY:Number=container_height / img_height;
			var scaleX:Number=container_width / img_width;
			var scaleC:Number=scaleX < scaleY ? scaleX : scaleY;
			
			//Center the DisplayObject in the container
			target.y=Math.floor(container_height / 2 - (target.height * scaleC) / 2);
			target.x=Math.floor(container_width / 2 - (target.width * scaleC) / 2);
			
			
			//Scale the DisplayObject
			target.width=Math.ceil(target.width * scaleC);
			target.height=Math.ceil(target.height * scaleC);
		}
		
		public static function parseUrl(url:String):Boolean{
			var rtmpUrlFormat:RegExp=new RegExp("(^rtmp[t|e|s]?\:\\/\\/.+?\\/.+?)\\/(.+)"); //Non-greedy
			var httpUrlFormat:RegExp=new RegExp("(^http[s]?\:\\/\\/.+)\\/(.+)");
			
			var rresult:Array = rtmpUrlFormat.exec(url);
			var hresult:Array = httpUrlFormat.exec(url);
			
			//ObjectUtil.toString(rresult);
			//ObjectUtil.toString(hresult);
			
			return (rresult || hresult);
		}

		protected function loadAsset(url:String):void
		{
			if (BitmapSprite.parseUrl(url))
			{
				loader=new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				

				request=new URLRequest(url);
				loader.load(request);
			}
		}

		protected function completeHandler(event:Event):void
		{
			var loader:Loader=Loader(event.target.loader);
			img=Bitmap(loader.content);
			img_width=img.bitmapData.width;
			img_height=img.bitmapData.height;
			//trace("img reported dimensions: " + img_width + "x" + img_height);

			this.addChild(img);
			updateDisplayList(0, 0);
		}

		protected function ioErrorHandler(event:IOErrorEvent):void
		{
			trace("Unable to load image: " + event.errorID + " " + event.text);
		}
	}
}
