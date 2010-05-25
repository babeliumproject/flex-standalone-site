package events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	import flash.events.Event;	
	import vo.ChangePassVO;

	public class ModifyUserEvent extends CairngormEvent
	{
		
		public static const CHANGE_PASS: String = "changepass";
		
		public var user:ChangePassVO;
		
		public function ModifyUserEvent(type:String, user:ChangePassVO)
		{
			super(type);
			this.user = user;
		}
		
		override public function clone():Event{
			return new ModifyUserEvent(type,user);
		}
		
	}
}