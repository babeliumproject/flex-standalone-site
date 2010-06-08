package events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	public class UserVideoHistoryEvent extends CairngormEvent
	{
		public function UserVideoHistoryEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}