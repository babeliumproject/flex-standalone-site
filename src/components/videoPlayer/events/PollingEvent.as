package components.videoPlayer.events
{
	import flash.events.TimerEvent;

	public class PollingEvent extends TimerEvent
	{
		
		public static const ENTER_FRAME:String = "FrameEntered";
		public var time:Number;
		
		public function PollingEvent(type:String, time:Number, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.time = time;
		}
		
	}
}