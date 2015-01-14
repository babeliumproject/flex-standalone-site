package modules.profile.event
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;
	
	public class ProfileEvent extends CairngormEvent
	{
		public static const GET_USER_ACTIVITY:String="getUserActivity";
		
		public var params:Object;
		
		public function ProfileEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, params:Object=null)
		{
			super(type, bubbles, cancelable);
			this.params=params;
		}
		
		override public function clone():Event{
			return new ProfileEvent(type,params);
		}
	}
}