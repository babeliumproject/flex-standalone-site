package events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;
	
	import vo.LoginVO;

	public class LoginEvent extends CairngormEvent
	{
		
		public static const RESTORE_PASS:String = "restorePass";
		public static const PROCESS_LOGIN: String = "processLogin";
		public static const SIGN_OUT: String = "signOut";
		
		public var user:LoginVO;
		
		public function LoginEvent(type:String, user:LoginVO)
		{
			super(type);
			this.user = user;
		}
		
		override public function clone():Event{
			return new LoginEvent(type,user);
		}
		
	}
}