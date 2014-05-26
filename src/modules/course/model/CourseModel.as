package modules.course.model
{
	import mx.collections.ArrayCollection;

	public class CourseModel
	{
		
		public var getCoursesData:ArrayCollection;
		[Bindable]
		public var getCoursesDataChanged:Boolean;
		
		public var viewCourseData:Object;
		[Bindable]
		public var viewCourseDataChanged:Boolean;
		
	}
}