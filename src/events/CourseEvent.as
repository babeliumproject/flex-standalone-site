package events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	public class CourseEvent extends CairngormEvent
	{
		
		public static const GET_COURSES:String = 'getcourses';
		public static const VIEW_COURSE:String = 'viewcourse';
		
		public var id:uint;
		
		public function CourseEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}