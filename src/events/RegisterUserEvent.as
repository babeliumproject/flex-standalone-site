package events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	import flash.events.Event;	
	import vo.NewUserVO;

	public class RegisterUserEvent extends CairngormEvent
	{
		
		public static const REGISTER_USER: String = "registerUser";
		public static const ACTIVATE_USER: String = "activateUser";
		
		public var user:NewUserVO;
		
		public function RegisterUserEvent(type:String, user:NewUserVO)
		{
			super(type);
			this.user = user;
		}
		
		override public function clone():Event{
			return new RegisterUserEvent(type,user);
		}
		
	}
}