package modules.create.event
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;
	
	public class CreateEvent extends CairngormEvent
	{
		
		public static const ADD_EXERCISE:String = "addExercise";
		public static const EDIT_EXERCISE:String = "editExercise";
		public static const ADD_EXERCISE_MEDIA:String = "addExerciseMedia";
		public static const LIST_LATEST_CREATIONS:String = "getLatestCreations";
		public static const LIST_CREATIONS:String = "listUserCreations";
		public static const DELETE_SELECTED_CREATIONS:String = "deleteSelectedVideos";
		public static const SAVE_EXERCISE:String = "modifyVideoData";
		public static const UNPROCESSED:String = "unprocessed";
		public static const WEBCAM:String = "webcam";
		public static const LIST_EXERCISE_MEDIA:String = "listExerciseMedia";
		public static const GET_EXERCISE_MEDIA:String = "getExerciseMedia";
		
		public var params:Object;
		
		public function CreateEvent(type:String, params:Object=null)
		{
			super(type);
			this.params = params;
		}
		
		override public function clone():Event {
			return new CreateEvent(type, params);
		}
	}
}