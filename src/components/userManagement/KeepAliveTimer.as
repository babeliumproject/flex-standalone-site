package components.userManagement
{
	import events.UserEvent;
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import model.DataModel;
	
	import view.common.CustomAlert;
	
	import vo.UserVO;

	public class KeepAliveTimer
	{
		
		private var keepAlive:Timer;
		
		public function startKeepAlive():void{
			keepAlive = new Timer(DataModel.getInstance().keepAliveInterval,0); //Schedule to raise every 3minutes
			keepAlive.start();
			keepAlive.addEventListener(TimerEvent.TIMER, onTimerTick);
		}
		
		public function stopKeepAlive():void{
			keepAlive.stop();
			keepAlive.removeEventListener(TimerEvent.TIMER, onTimerTick);
		}
		
		private function onTimerTick(event:TimerEvent):void{
			new UserEvent(UserEvent.KEEP_SESSION_ALIVE).dispatch();
		}
	}
}