package modules.profile.model
{
	import mx.collections.ArrayCollection;

	public class CourseModel
	{
		
		public var myCoursesData:ArrayCollection;
		public var myExercisesData:ArrayCollection;
		
		[Bindable]
		public var getCoursesDataChanged:Boolean;
		
		public var viewCourseData:Object;
		[Bindable]
		public var viewCourseDataChanged:Boolean;
		
	}
}