package events
{
	import com.adobe.cairngorm.control.CairngormEvent;

	public class UserEvent extends CairngormEvent
	{
		public static const GET_TOP_TEN_CREDITED:String = "getTopTenCredited";
		public static const GET_USER_INFO:String = "getUserInfo";
		
		public function UserEvent(type:String)
		{
			super(type);
		}
		
	}
}