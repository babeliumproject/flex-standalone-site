package modules.videoPlayer.events.babelia
{
	import flash.events.Event;

	public class StreamEvent extends Event
	{
		
		public static const ENTER_FRAME:String = "FrameEntered";
		public var time:Number;
		
		public function StreamEvent(type:String, time:Number, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.time = time;
		}
		
	}
}