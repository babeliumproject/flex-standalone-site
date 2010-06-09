package events
{
	import com.adobe.cairngorm.control.CairngormEvent;

	public class UserEvent extends CairngormEvent
	{
		public static const GET_TOP_TEN_CREDITED:String = "getTopTenCredited";
		public static const GET_USER_INFO:String = "getUserInfo";
		public static const KEEP_SESSION_ALIVE:String = "keepSessionAlive";
		
		public var userId:int;
		
		public function UserEvent(type:String, userId:int = 0)
		{
			super(type);
			this.userId = userId;
		}
		
	}
}