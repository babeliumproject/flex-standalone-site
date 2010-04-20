package modules.configuration
{
	import flash.events.Event;

	public class ConfigurationResultEvent extends Event
	{
		public static const WEBCAM_RESULT:String = "webcam_result";
		public static const MICROPHONE_RESULT:String = "microphone_result";
		public static const BANDWIDTH_RESULT:String = "bandwidth_result";
		
		public var status:Boolean; 
		
		public function ConfigurationResultEvent(eventName:String, bool:Boolean){
			super(eventName);
			status=bool;
		}
			
	}
}