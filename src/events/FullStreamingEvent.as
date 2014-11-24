package events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;
	
	public class FullStreamingEvent extends CairngormEvent
	{
		public static const SETUP_CONNECTION:String="setupConnection";
		public static const START_CONNECTION:String="startConnection";
		public static const CLOSE_CONNECTION:String="closeConnection";
		public static const CONNECTION_READY:String="connectionReady";
		public static const CONNECTION_ERROR:String="connectionError";

		
		public var proxy : String;
		public var encoding : uint;
		
		public function FullStreamingEvent(type:String, proxy:String='none', encoding:uint=3)
		{
			super(type);
			this.proxy=proxy;
			this.encoding=encoding;
		}
		
		override public function clone():Event {
			return new FullStreamingEvent(type, proxy, encoding);
		}
	}
}