package components.configuration
{
	import flash.events.Event;
	
	public class ShowStatusMessage extends Event
	{
		public static const MIC_MESSAGE:String = "mic_message";
		public static const CAM_MESSAGE:String = "cam_message";
		
		public function ShowStatusMessage(eventName:String)
		{
			super(eventName);
		}
	}
}