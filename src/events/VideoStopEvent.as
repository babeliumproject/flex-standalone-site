package events
{
	import com.adobe.cairngorm.control.CairngormEvent;


	public class VideoStopEvent extends CairngormEvent
	{
		public static const STOP_ALL_VIDEOS:String = "videoStopEvent";

		public function VideoStopEvent()
		{
			super(STOP_ALL_VIDEOS);
		}

	}
}