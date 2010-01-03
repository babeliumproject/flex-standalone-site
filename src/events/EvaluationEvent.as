package events {
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class EvaluationEvent extends CairngormEvent {

		public static const AUTOMATIC_EVAL_RESULTS:String = "automaticEvalResults";

		public static const ENABLE_TRANSCRIPTION_TO_EXERCISE:String = "enableTranscriptionToExercise";
		public static const ENABLE_TRANSCRIPTION_TO_RESPONSE:String = "enableTranscriptionToResponse";
		
		public static const CHECK_AUTOEVALUATION_SUPPORT_EXERCISE:String = "checkAutoevaluationSupportExercise";
		public static const CHECK_AUTOEVALUATION_SUPPORT_RESPONSE:String = "checkAutoevaluationSupportResponse";

		public var responseID:int;

		public var exerciseID:int;

		public var transcriptionSystem:String;

		public function EvaluationEvent(type:String, responseID:int = 0, exerciseID:int = 0, transcriptionSystem:String = "") {
			super(type);
			this.responseID = responseID;
			this.exerciseID = exerciseID;
			this.transcriptionSystem = transcriptionSystem;
		}

		override public function clone():Event {
			return new EvaluationEvent(type, responseID, exerciseID, transcriptionSystem);
		}
	}
}