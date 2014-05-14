package events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	public class CourseEvent extends CairngormEvent
	{
		
		public static const GET_COURSES:String = 'getcourses';
		public static const VIEW_COURSE:String = 'viewcourse';
		
		public var action:String;
		public var id:uint;
		
		public function CourseEvent(type:String, action:String, id:uint=0)
		{
			super(type);
			this.action = action;
			this.id = id;
		}
	}
}