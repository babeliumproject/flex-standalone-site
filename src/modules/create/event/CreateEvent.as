package modules.create.event
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import vo.ExerciseVO;
	
	public class CreateEvent extends CairngormEvent
	{
		
		public static const ADD_EXERCISE:String = "addExercise";
		public static const EDIT_EXERCISE:String = "editExercise";
		public static const ADD_EXERCISE_MEDIA:String = "addExerciseMedia";
		public static const UNPROCESSED:String = "unprocessed";
		public static const WEBCAM:String = "webcam";
		
		public var exercisedata:Object;
		
		public function CreateEvent(type:String, exercisedata:Object)
		{
			super(type);
			this.exercisedata = exercisedata;
		}
	}
}