package modules.assignment.event
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;
	
	public class AssignmentEvent extends CairngormEvent
	{
		public static const ADD_ASSIGNMENT:String="addAssignment";
		public static const EDIT_ASSIGNMENT:String="editAssignment";
		public static const PICK_EXERCISE:String="pickExercise";
		
		public var params:Object;
		
		public function AssignmentEvent(type:String, params:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.params=params;
		}
		
		override public function clone():Event {
			return new AssignmentEvent(type, params);
		}
	}
}