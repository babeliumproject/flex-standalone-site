package events {
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;
	
	import vo.EvaluationVO;

	public class EvaluationEvent extends CairngormEvent {
		
		public static const GET_RESPONSES_WAITING_ASSESSMENT:String = "getResponsesWaitingAssessment";
		public static const GET_RESPONSES_ASSESSED_TO_CURRENT_USER:String="getResponsesAssessedToCurrentUser";
		public static const GET_RESPONSES_ASSESSED_BY_CURRENT_USER:String="getResponsesAssessedByCurrentUser";
		
		public static const ADD_ASSESSMENT:String="addAssessment";
		public static const ADD_VIDEO_ASSESSMENT:String="addVideoAssessment";
		
		public static const DETAILS_OF_ASSESSED_RESPONSE:String="detailsOfAssessedResponse";
		public static const UPDATE_RESPONSE_RATING_AMOUNT:String="updateResponseRatingAmount";
		

		public static const AUTOMATIC_EVAL_RESULTS:String = "automaticEvalResults";

		public static const ENABLE_TRANSCRIPTION_TO_EXERCISE:String = "enableTranscriptionToExercise";
		public static const ENABLE_TRANSCRIPTION_TO_RESPONSE:String = "enableTranscriptionToResponse";
		
		public static const CHECK_AUTOEVALUATION_SUPPORT_EXERCISE:String = "checkAutoevaluationSupportExercise";
		public static const CHECK_AUTOEVALUATION_SUPPORT_RESPONSE:String = "checkAutoevaluationSupportResponse";
		
		public var requestData:EvaluationVO;

		public function EvaluationEvent(type:String, requestData:EvaluationVO = null) {
			super(type);
			this.requestData = requestData;
		}

		override public function clone():Event {
			return new EvaluationEvent(type, requestData);
		}
	}
}