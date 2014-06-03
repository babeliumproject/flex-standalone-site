package modules.create.event
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import vo.ExerciseVO;
	
	public class CreateEvent extends CairngormEvent
	{
		
		public static const CREATEUPDATE_EXERCISE:String = "createUpdateExercise";
		public static const UNPROCESSED:String = "unprocessed";
		public static const WEBCAM:String = "webcam";
		
		public var exercisedata:ExerciseVO;
		
		public function CreateEvent(type:String, exercisedata:ExerciseVO)
		{
			super(type);
			this.exercisedata = exercisedata;
		}
	}
}