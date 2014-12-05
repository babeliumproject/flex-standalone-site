package components.videoPlayer.events
{
	import flash.events.Event;
	
	public class UserDeviceEvent extends Event
	{
		
		public static const DEVICE_STATE_CHANGE:String="deviceStateChange";
		
		public static const ACCEPT:String="accept";
		public static const RETRY:String="retry";
		public static const CANCEL:String="cancel";
		
		public static const AV_HARDWARE_DISABLED:int=-1;
		public static const NO_MICROPHONE_FOUND:int=0;
		public static const NO_CAMERA_FOUND:int=1;
		public static const DEVICE_ACCESS_NOT_GRANTED:int=2;
		public static const DEVICE_ACCESS_GRANTED:int=3;
		
		public var state:int;
		
		public function UserDeviceEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, state:int=-1)
		{
			super(type, bubbles, cancelable);
			this.state=state;
		}
		
		/**
		 *  @private
		 */
		override public function clone():Event
		{
			return new UserDeviceEvent(type, bubbles, cancelable, state);
		}
	}
}