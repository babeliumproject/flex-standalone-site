package modules.create.event
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import vo.ExerciseVO;
	
	public class CreateEvent extends CairngormEvent
	{
		
		public static const ADD_EXERCISE:String = "addExercise";
		public static const EDIT_EXERCISE:String = "editExercise";
		public static const ADD_EXERCISE_MEDIA:String = "addExerciseMedia";
		public static const GET_LATEST_CREATIONS:String = "getLatestCreations";
		public static const RETRIEVE_USER_VIDEOS:String = "retrieveUserVideos";
		public static const DELETE_SELECTED_VIDEOS:String = "deleteSelectedVideos";
		public static const MODIFY_VIDEO_DATA:String = "modifyVideoData";
		public static const UNPROCESSED:String = "unprocessed";
		public static const WEBCAM:String = "webcam";
		
		public var exercisedata:Object;
		
		public function CreateEvent(type:String, exercisedata:Object=null)
		{
			super(type);
			this.exercisedata = exercisedata;
		}
	}
}