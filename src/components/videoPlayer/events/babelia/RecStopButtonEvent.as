package components.videoPlayer.events.babelia
{
	import flash.events.Event;
	
	public class RecStopButtonEvent extends Event
	{
		
		public static const BUTTON_CLICK:String="buttonClick";
		public var state:uint;
		
		public function RecStopButtonEvent(type:String, state:uint, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.state = state;
		}
	}
}