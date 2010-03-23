package events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;
	
	import vo.ExerciseVO;

	public class ExerciseEvent extends CairngormEvent
	{

		public static const ADD_EXERCISE:String="addExercise";
		public static const ADD_UNPROCESSED_EXERCISE:String="addUnprocessedExercise";
		public static const GET_EXERCISES:String="getExercises";
		public static const WATCH_EXERCISE:String="watchExercise";
		public static const EXERCISE_SELECTED:String="exerciseSelected";
		public static const GET_EXERCISE_LOCALES:String="exerciseLocales";

		public var exercise:ExerciseVO;

		public function ExerciseEvent(type:String, exercise:ExerciseVO = null)
		{
			super(type);
			this.exercise=exercise;
		}
		
		override public function clone():Event{
			return new ExerciseEvent(type,exercise);
		}

	}
}