package modules.videoPlayer.controls.babelia
{
	import mx.controls.Alert;
	import mx.controls.ProgressBar;
	import mx.controls.Text;
	import mx.core.UIComponent;
	import flash.display.Sprite;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	public class RoleTalkingPanel extends UIComponent
	{
		private var _bg:Sprite;
		private var _textBox:Text;
		private var _roleBox:Text;
		private var _pBar:ProgressBar;
		private var _talking:Boolean = false;
		private var _boxWidth:Number = 200;
		private var _boxHeight:Number = 50;
		private var _defaultMargin:Number = 5;
		private var _timer:Timer;
		private var _duration:Number;
		private var _refreshTime:Number = 10;
		private var _startTime:Number;
		private var _pauseTime:Number;
		
		public function RoleTalkingPanel()
		{
			super();

			_bg = new Sprite();
			addChildAt(_bg, 0);

			_textBox = new Text();
			_textBox.setStyle("color", "haloOrange");
			_textBox.setStyle("fontWeight", "bold");
			_textBox.selectable = false;
			_textBox.text = "Talking: ";
			
			addChild(_textBox);
			
			_roleBox = new Text();
			_roleBox.setStyle("color", "white");
			_roleBox.setStyle("weight", "bold");
			_roleBox.selectable = false;
			
			addChild(_roleBox);
			
			_pBar = new ProgressBar();
			_pBar.mode = "manual";
			_pBar.setStyle("barColor", "haloOrange");
			
			addChild(_pBar);

			resize(_boxWidth, _boxHeight);
		}
		
		public function resize(width:Number, height:Number) : void
		{			
			this.width = width;
			this.height = height;
			
			CreateBG( width, height );
			
			_textBox.x = _defaultMargin;
			_textBox.y = _defaultMargin;
			_textBox.width = 55;
			_textBox.height = 20;
			
			_roleBox.x = _textBox.x + _textBox.width;
			_roleBox.y = _textBox.y;
			_roleBox.width = width - _textBox.width - 2*_defaultMargin;
			_roleBox.height = 20;
			
			_pBar.x = _textBox.x + _defaultMargin;
			_pBar.y = _textBox.y + _textBox.height;
			_pBar.width = width - 4*_defaultMargin;
		}
		
		public function get talking() : Boolean
		{
			return _talking;
		}
		
		public function setTalking(role:String, duration:Number) : void
		{
			_talking = true;
			_duration = duration;
			_roleBox.text = role;
			_pBar.minimum = 0;
			_pBar.maximum = duration;
			_startTime = flash.utils.getTimer();
			
			_timer = new Timer(_refreshTime);
			_timer.addEventListener(TimerEvent.TIMER, onTick);
			_timer.start();
		}
		
		public function pauseTalk() : void
		{
			_timer.stop();
			_pauseTime = flash.utils.getTimer();
		}
		
		public function resumeTalk() : void
		{
			var timeRunning:Number = _pauseTime - _startTime;
			_startTime = flash.utils.getTimer() - timeRunning;
			_timer.start();
		}
		
		public function stopTalk() : void
		{
			_timer.stop();
			_timer.reset();
			_pBar.setProgress(0,1);
			_roleBox.text = "";
		}
		
		private function onTick(event:TimerEvent) : void
		{
			var currentTime:Number = (flash.utils.getTimer() - _startTime) / 1000;
			
			if ( currentTime >= _duration )
			{
				_pBar.setProgress(0, _duration);
				_talking = false;
				_roleBox.text = "";
				_timer.stop();
				_timer.reset();
			}
			else
				_pBar.setProgress(currentTime, _duration);	
		}
		
		private function CreateBG( bgWidth:Number, bgHeight:Number ):void
		{
			_bg.graphics.clear();
			_bg.graphics.beginFill( 0x000000 );
			_bg.graphics.drawRoundRect(0, 0, width, height, 12, 12);
			_bg.graphics.endFill();
			_bg.graphics.beginFill( 0x343434 );
			_bg.graphics.drawRoundRect(2, 2, width-4, height-4, 10, 10);
			_bg.graphics.endFill();
		}
	}
}