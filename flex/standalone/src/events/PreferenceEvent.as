package events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	public class PreferenceEvent extends CairngormEvent
	{
		public static const GET_APP_PREFERENCES:String = "getAppPreferences";
		
		public function PreferenceEvent(type:String)
		{
			super(type);
		}

	}
}