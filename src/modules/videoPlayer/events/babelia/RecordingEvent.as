package modules.videoPlayer.events.babelia
{
	import flash.events.Event;

	public class RecordingEvent extends Event
	{
		
		public static const END:String = "EndRecord";
		public var fileName:String;
		
		public function RecordingEvent(type:String, fileName:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.fileName = fileName;
		}
		
	}
}