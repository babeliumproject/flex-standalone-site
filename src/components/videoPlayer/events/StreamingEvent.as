package components.videoPlayer.events
{
	import flash.events.Event;
	
	public class StreamingEvent extends Event
	{
		public static const CONNECTED_CHANGE:String = "connectedChanged";
		
		public function StreamingEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}