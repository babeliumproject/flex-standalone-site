package modules.videoPlayer.controls.babelia
{
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.media.Microphone;
	import flash.text.FontStyle;
	import flash.utils.Timer;
	
	import modules.videoPlayer.controls.SkinableComponent;
	
	import mx.controls.Text;

	/**
	 * Merged from iñigo's:
	 * modules/configuration/microphone/barraSonido.mxml
	 **/
	public class MicActivityBar extends SkinableComponent
	{
		/**
		 * Skin constants
		 */
		public static const BORDER_COLOR:String = "bgColor";
		public static const BARBG_COLOR:String = "barBgColor";
		public static const BAR_COLOR:String = "barColor";
		public static const TEXT_COLOR:String = "textColor";
		
		/**
		 * Variables
		 * 
		 */
		
		private var _defaultWidth:Number = 80;
		private var _defaultHeight:Number = 20;
		
		private var _bg:Sprite;
		private var _sliderArea:Sprite;
		private var _amount:Sprite;
		private var _textBox:Text;
		
		private var _mic:Microphone;
		private var _micTimer:Timer;
		
		public function MicActivityBar()
		{
			super("MicActivityBar"); // Required for setup skinable component
			
			width = _defaultWidth;
			height = _defaultHeight;
			
			_bg = new Sprite();
			_sliderArea = new Sprite();
			_amount = new Sprite();
			_textBox = new Text();
			_textBox.setStyle("textAlign", "center");
			_textBox.setStyle("fontWeight", FontStyle.BOLD);
			_textBox.setStyle("fontSize", 10);
			_textBox.selectable = false;
			
			addChild( _bg );;
			addChild( _sliderArea );
			addChild( _amount );
			addChild( _textBox );
		}
		
		override public function availableProperties(obj:Array = null) : void
		{
			super.availableProperties([BORDER_COLOR,BARBG_COLOR,BAR_COLOR]);
		}
		
		
		/** 
		 * Methods
		 * 
		 */
		
		public function set mic(_mic:Microphone) : void
		{
			this._mic = _mic;
			
			_micTimer = new Timer(20);
			_micTimer.addEventListener(TimerEvent.TIMER, onGainTick);
			_micTimer.start();
		}
		
		private function onGainTick(e:TimerEvent) : void
		{
			this.setProgress(_mic.activityLevel, 100);
			this.label=resourceManager.getString('myResources','LABEL_MIC_INPUT_LEVEL')+":   " + _mic.activityLevel+"%";
		}
		
		/** Overriden */
		
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
			_textBox.setStyle("color", getSkinColor(TEXT_COLOR));
			_textBox.text = text;
		}
		
		
	}
}