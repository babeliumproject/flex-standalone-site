package events
{
	import com.adobe.cairngorm.control.CairngormEvent;

	public class VideoSliceEvent extends CairngormEvent
	{
		public static const SEARCH_URL:String = "searchUrl";
		public static const SEARCH_USER:String = "searchUser";	
		public static const CREATE_SLICE:String = "createSlice";
		
		public function VideoSliceEvent(type:String)
		{
			super(type);
		}
		
	}
}