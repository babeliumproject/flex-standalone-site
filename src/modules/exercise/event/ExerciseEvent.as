package modules.exercise.event
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;
	
	import vo.ExerciseReportVO;
	import vo.ExerciseScoreVO;
	import vo.ExerciseVO;

	public class ExerciseEvent extends CairngormEvent
	{
		public static const GET_EXERCISES:String="getExercises";
		public static const GET_RECORDABLE_EXERCISES:String="getRecordableExercises";
		public static const WATCH_EXERCISE:String="watchExercise";
		public static const EXERCISE_SELECTED:String="exerciseSelected";
		public static const GET_EXERCISE_LOCALES:String="exerciseLocales";
		public static const RATE_EXERCISE:String="rateExercise";
		public static const REPORT_EXERCISE:String="reportExercise";
		public static const USER_RATED_EXERCISE:String="userRatedExercise";
		public static const USER_REPORTED_EXERCISE:String="userReportedExercise";

		public var params:Object;

		public function ExerciseEvent(type:String, params:Object=null)
		{
			super(type);
			this.params = params;
		}
		
		override public function clone():Event{
			return new ExerciseEvent(type,params);
		}

	}
}