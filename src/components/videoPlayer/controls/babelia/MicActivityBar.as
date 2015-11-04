package components.videoPlayer.controls.babelia
{
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.media.Microphone;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	import components.videoPlayer.controls.DictionarySkinnableComponent;
	
	import mx.resources.ResourceManager;
	

	/**
	 * Merged from iñigo's:
	 * modules/configuration/microphone/barraSonido.mxml
	 **/
	public class MicActivityBar extends DictionarySkinnableComponent
	{
		/**
		 * Skin constants
		 */
		public static const BORDER_COLOR:String = "bgColor";
		public static const BARBG_COLOR:String = "barBgColor";
		public static const BAR_COLOR:String = "barColor";
		public static const COLOR:String = "textColor";
		
		private var _defaultWidth:Number = 80;
		private var _defaultHeight:Number = 20;
		
		private var _bg:Sprite;
		private var _sliderArea:Sprite;
		private var _amount:Sprite;
		private var _textBox:TextField;
		private var _textFormat:TextFormat;
		
		private var _mic:Microphone;
		private var _micTimer:Timer;
		
		public function MicActivityBar()
		{
			super("MicActivityBar");
			
			width = _defaultWidth;
			height = _defaultHeight;
			
			_bg = new Sprite();
			_sliderArea = new Sprite();
			_amount = new Sprite();
			
			
			_textFormat = new TextFormat();
			_textFormat.align = "center";
			_textFormat.font = "Arial";
			_textFormat.bold = true;
			_textFormat.size = 10;
			
			_textBox = new TextField();
			_textBox.selectable = false;
			_textBox.setTextFormat(_textFormat);
			
			
			addChild( _bg );
			addChild( _sliderArea );
			addChild( _amount );
			addChild( _textBox );
		}
		
		override public function dispose():void{
			super.dispose();
			
			if(_micTimer){
				_micTimer.stop();
				_micTimer.removeEventListener(TimerEvent.TIMER, onTimerTick);
				_micTimer=null;
			}
		}
		
		override public function availableProperties(obj:Array = null) : void
		{
			super.availableProperties([BORDER_COLOR,BARBG_COLOR,BAR_COLOR]);
		}
		
		public function set mic(_mic:Microphone) : void
		{
			this._mic = _mic;
			
			_micTimer = new Timer(20);
			_micTimer.addEventListener(TimerEvent.TIMER, onTimerTick);
			_micTimer.start();
		}
		
		private function onTimerTick(e:TimerEvent) : void
		{
			if(_mic.activityLevel >= 0){
				this.setProgress(_mic.activityLevel, 100);
				this.label = ResourceManager.getInstance().getString('myResources','MIC_INPUT_LEVEL')+":   " + _mic.activityLevel+"%";
			} else {
				this.setProgress(0, 100);
				this.label = ResourceManager.getInstance().getString('myResources','MIC_WAITING_FOR_INPUT');
			}
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			if( width == 0 ) width = _defaultWidth;
			if( height == 0 ) height = _defaultHeight;
			
			// Create Background
			_bg.graphics.clear();
			_bg.graphics.beginFill( getSkinColor(BORDER_COLOR) );
			_bg.graphics.drawRect( 0, 0, width, height );
			_bg.graphics.endFill();
			
			_sliderArea.graphics.clear();
			_sliderArea.graphics.beginFill( getSkinColor(BARBG_COLOR) );
			_sliderArea.graphics.drawRect( 2, 2, width-4, height-4 );
			_sliderArea.graphics.endFill();
			
			_textBox.width = 300;
			_textBox.height = 16;
			_textBox.y = 2;
			_textBox.x = width/2 - _textBox.width/2;
		}
		
		private function setProgress(actual:Number, max:Number) : void
		{
			var w:Number = (this.width-6) * actual / max;
			
			_amount.graphics.clear();
			_amount.graphics.beginFill( getSkinColor(BAR_COLOR) );
			_amount.graphics.drawRoundRect( 3, 3, w, height-6, 5 );
			_amount.graphics.endFill();
		}
		
		private function set label(text:String) : void
		{
			_textFormat.color = getSkinColor(COLOR);
			_textBox.text = text;
			_textBox.setTextFormat(_textFormat);
		}
	}
}
