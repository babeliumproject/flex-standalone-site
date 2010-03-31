package commands.autoevaluation {
	import business.AutoEvaluationDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import events.EvaluationEvent;
	
	import model.DataModel;
	
	import modules.autoevaluation.Autoevaluator;
	import modules.autoevaluation.AutoevaluatorManager;
	import modules.autoevaluation.Evaluation;
	
	import mx.controls.Alert;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ObjectUtil;
	
	import vo.TranscriptionsVO;

	public class AutoEvaluateCommand implements ICommand, IResponder {

		public function execute(event:CairngormEvent):void {
			new AutoEvaluationDelegate(this).getResponseTranscriptions((event as EvaluationEvent).responseID);
		}

		public function result(data:Object):void {
			var result:Object = data.result;
			var error:String = "";
			if(result is TranscriptionsVO) {
				var transcriptions:TranscriptionsVO = result as TranscriptionsVO;
				if(transcriptions.exerciseTranscriptionStatus.toLowerCase() != "converted") {
					if(transcriptions.exerciseTranscriptionStatus.toLowerCase() == "pending")
						error = "Your autoevaluation request is pending";
					else if(transcriptions.exerciseTranscriptionStatus.toLocaleLowerCase() == "processing")
						error = "Your autoevaluation request is being processed";
					else
						error = "Autoevaluation not available";
				} else if(transcriptions.responseTranscriptionStatus.toLocaleLowerCase() != "converted") {
					if(transcriptions.responseTranscriptionStatus.toLowerCase() == "pending")
						error = "Your autoevaluation request is pending";
					else if(transcriptions.responseTranscriptionStatus.toLocaleLowerCase() == "processing")
						error = "Your autoevaluation request is being processed";
					else
						error = "Autoevaluation not available";
				} else
					evaluate(transcriptions.responseTranscriptionSystem.toLowerCase(), transcriptions.exerciseTranscription, transcriptions.responseTranscription);
				DataModel.getInstance().autoevaluationAvailable = true;
			} else {
				error = "";
				DataModel.getInstance().autoevaluationAvailable = false;
			}
			DataModel.getInstance().autoevaluationError = error;
		}

		public function fault(info:Object):void {
			DataModel.getInstance().autoevaluationAvailable = false;
			var faultEvent:FaultEvent = FaultEvent(info);
			Alert.show("Error: " + faultEvent.message);
			trace(ObjectUtil.toString(info));
		}

		private function evaluate(system:String, exerciseStr:String, responseStr:String):void {
			try{
				var evaluator:Autoevaluator = AutoevaluatorManager.getInstance().getAutoevaluator(system);
				var eval:Evaluation = evaluator.evaluate(exerciseStr, responseStr);
				
				DataModel.getInstance().autoevaluationResults = eval;
				DataModel.getInstance().autoevaluationDone = true;
			}catch (e:Error){
				DataModel.getInstance().autoevaluationDone = false;
				DataModel.getInstance().autoevaluationError = "Autoevaluation not available";
			}
		}
	}
}