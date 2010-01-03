package modules.videoPlayer.events
{
	import flash.events.Event;

	public class ScrubberBarEvent extends Event
	{
		public static const SCRUBBER_DROPPED:String = "ScrubberDropped";
		
		public function ScrubberBarEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}