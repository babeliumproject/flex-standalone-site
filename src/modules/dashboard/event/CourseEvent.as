package modules.dashboard.event
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;
	
	public class CourseEvent extends CairngormEvent
	{
		public static const GET_COURSES:String = 'getCourses';
		public static const VIEW_COURSE:String = 'viewCourse';
		
		public var query:Object;
		
		public function CourseEvent(type:String, query:Object = null)
		{
			super(type);
			this.query = query;
		}
		
		override public function clone():Event{
			return new CourseEvent(type,query);
		}
	}
}