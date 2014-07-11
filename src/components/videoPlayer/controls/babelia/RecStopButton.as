package components.videoPlayer.controls.babelia
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import components.videoPlayer.controls.SkinableButton;
	import components.videoPlayer.events.babelia.RecStopButtonEvent;
	
	import mx.controls.Alert;

	public class RecStopButton extends SkinableButton
	{
		public static const REC_STATE:uint=0;
		public static const STOP_STATE:uint=1;

		private var _recMode:Boolean = false;
		private var _state:uint=STOP_STATE;

		public function RecStopButton()
		{
			super("RecStopButton");
		}
		
		override public function availableProperties(obj:Array = null) : void
		{
			super.availableProperties([BG_COLOR,OVERBG_COLOR,ICON_COLOR]);
		}

		public function set state(value:uint):void
		{
			_state=value;
			invalidateDisplayList();
		}

		public function get state():uint
		{
			return _state;
		}
		
		public function set recMode(value:Boolean):void
		{
			_recMode=value;
			if(_recMode)
				state = REC_STATE;
		}
		
		public function get recMode():Boolean
		{
			return _recMode;	
		}

		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			if (_state == REC_STATE){
				createRecButton();
				btn.x=this.width/2;
				btn.y=this.height/2;
			}else{
				createStopButton();
				btn.x = this.width/2 - btn.width/2;
				btn.y = this.height/2 - btn.height/2;
			}
			
			addChild(btn);
		}

		private function createRecButton():void
		{
			btn.graphics.clear();
			btn.graphics.beginFill(0xFF0000);
			btn.graphics.drawCircle(0, 0, 5);
			btn.graphics.endFill();
		}

		private function createStopButton():void
		{
			btn.graphics.clear();
			btn.graphics.beginFill(getSkinColor(ICON_COLOR));
			btn.graphics.drawRect(0, 0, 10, 10);
			btn.graphics.endFill();
		}

		override protected function onClick(e:MouseEvent):void
		{
			var cstate:uint=_state;
			if(_recMode){
				state = (_state == REC_STATE) ? STOP_STATE : REC_STATE;
			}
			dispatchEvent(new RecStopButtonEvent(RecStopButtonEvent.CLICK,cstate));
		}
	}
}
