package modules.videoPlayer.controls
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import mx.core.UIComponent;

	public class ElapsedTime extends UIComponent
	{
		/** 
		 * Variables
		 * 
		 */
		 
		 
		private var _bg:Sprite;
		private var _timeBox:TextField;
		private var tf:TextFormat = new TextFormat();
		private var _defaultWidth:Number = 75;
		private var _defaultHeight:Number = 20;
		
		
		public function ElapsedTime()
		{
			super();
			
			width = _defaultWidth;
			height = _defaultHeight;
			
			_timeBox = new TextField();
			_timeBox.text = "Loading...";
			_timeBox.selectable = false;
			
			
			tf.bold = true;
			tf.align = "center";
			tf.color = 0xffffff;
			tf.font = "Arial";
			
			_timeBox.setTextFormat( tf );
			
			addChild( _timeBox );
		}
		
		
		/**
		 * Methods
		 * 
		 */
		
		
		/** Overriden */
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList( unscaledWidth, unscaledHeight );
			
			if( height == 0 ) height = _defaultHeight;
			if( width == 0 ) width = _defaultWidth;
			
			CreateBG( width, height );
			
			_timeBox.width = width;
			
		}
		
		
		private function CreateBG( bgWidth:Number, bgHeight:Number ):void
		{
			_bg = new Sprite();
			_bg.graphics.beginFill( 0x343434 );
			_bg.graphics.drawRect( 0, 0, bgWidth, bgHeight );
			_bg.graphics.endFill();
			
			addChildAt( _bg, 0 );
		}
		
		
		public function updateElapsedTime( curTime:Number, duration:Number ):void
		{
			var cMin:Object = Math.floor( curTime/60 );
			var cSec:Object = Math.floor( curTime - ( Number( cMin )*60 ) );
			
			var dMin:Object = Math.floor( duration/60 );
			var dSec:Object = Math.floor( duration - ( Number( dMin )*60 ) );
			
			if( Number( cSec ) > Number( dSec ) && Number( cMin ) == Number( dMin ) ) cSec = dSec;
			
			if( cSec.toString().length == 1 ) cSec = "0" + cSec;
			
			if( dSec.toString().length == 1 ) dSec = "0" + dSec;
			
			_timeBox.text = cMin + ":" + cSec + " / " + dMin + ":" + dSec;
			
			_timeBox.setTextFormat( tf );
		}
	}
}