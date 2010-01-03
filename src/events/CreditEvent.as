package events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;
	
	public class CreditEvent extends CairngormEvent
	{
		
		//The user requested it's video to be evaluated
		public static const SUB_CREDITS_FOR_EVAL_REQUEST:String = "subCreditsForEvalRequest";
		//The evaluator evaluates giving a comment / adding video for user feedback
		public static const ADD_CREDITS_FOR_EVALUATING:String = "addCreditsForEvaluating";
		//The evaluator evaluates giving only a score
		public static const ADD_CREDITS_FOR_SCORED_EVALUATION:String = "addCreditsForScoredEvaluation";
		//Granted when the user adds full credits to an exercise
		public static const ADD_CREDITS_FOR_SUBTITLING:String = "addCreditsForSubtitling";
		//Granted when the user suggests a new exercise to be added to the application
		public static const ADD_CREDITS_FOR_EXERCISE_ADVISING:String = "addCreditsForExerciseAdvising";
		//Granted when the user add tags, such as language, description... to an exercise
		public static const ADD_CREDITS_FOR_EXERCISE_TAGGING:String = "addCreditsForTagging";
		//Add credits once a day for signing-in in the application
		public static const ADD_CREDITS_FOR_DAILY_LOGIN:String = "addCreditsForDailyLogin";
		//Granted when viewing exercises
		public static const ADD_CREDITS_FOR_EXERCISE_VIEWING:String = "addCreditsForExerciseViewing";
		//Granted when the user uploads a new exercise
		public static const ADD_CREDITS_FOR_UPLOADING:String = "addCredtisForUploading";
		
		
		public static const ADD_CREDIT_ENTRY_EVAL_REQUEST:String = "addCreditEntryEvalRequest";
		public static const ADD_CREDIT_ENTRY_SUBTITLING:String = "addCreditEntrySubtitling";
		public static const ADD_CREDIT_ENTRY_EVALUATING:String = "addCreditEntryEvaluating";
		public static const ADD_CREDIT_ENTRY_EX_ADVISING:String = "addCreditEntryExAdvising";
		public static const ADD_CREDIT_ENTRY_UPLOADING:String = "addCreditEntryUploading";
		
		public static const GET_CURRENT_DAY_CREDIT_HISTORY:String = "getCurrentDayCreditHistory"; 
		public static const GET_LAST_WEEK_CREDIT_HISTORY:String = "getLastWeekCreditHistory";
		public static const GET_LAST_MONTH_CREDIT_HISTORY:String = "getLastMonthCreditHistory";
		public static const GET_ALL_TIME_CREDIT_HISTORY:String = "getAllTimeCreditHistory";
		
		public var userId:int;
		
		public function CreditEvent(type:String, userId:int = 0)
		{
			super(type);
			this.userId = userId;
		}
		
		override public function clone():Event{
			return new CreditEvent(type, userId);
		}

	}
}