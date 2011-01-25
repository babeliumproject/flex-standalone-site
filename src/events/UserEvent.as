package events
{
	import com.adobe.cairngorm.control.CairngormEvent;

	public class UserEvent extends CairngormEvent
	{
		public static const GET_TOP_TEN_CREDITED:String = "getTopTenCredited";
		public static const KEEP_SESSION_ALIVE:String = "keepSessionAlive";
		public static const MODIFY_PREFERRED_LANGUAGES:String = "modifyPreferredLanguages";
		
		public var languages:Array;
		
		public function UserEvent(type:String, languages:Array = null)
		{
			super(type);
			this.languages = languages;
		}
		
	}
}