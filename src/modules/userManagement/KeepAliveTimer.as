package modules.userManagement
{
	import events.UserEvent;
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import model.DataModel;
	
	import vo.UserVO;

	public class KeepAliveTimer
	{
		
		private static var keepAlive:Timer;
		
		public static function startKeepAlive():void{
			keepAlive = new Timer(DataModel.getInstance().keepAliveInterval,0); //Schedule to raise every 3minutes
			keepAlive.addEventListener(TimerEvent.TIMER, onTimerTick);
		}
		
		public static function stopKeepAlive():void{
			keepAlive.stop();
			keepAlive.removeEventListener(TimerEvent.TIMER, onTimerTick);
		}
		
		private static function onTimerTick(event:TimerEvent):void{
			var currentUser:UserVO = DataModel.getInstance().loggedUser;
			new UserEvent(UserEvent.KEEP_SESSION_ALIVE, currentUser.id).dispatch();
		}
	}
}