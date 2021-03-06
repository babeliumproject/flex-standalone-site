package commands.autoevaluation {
	import business.AutoEvaluationDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import modules.assessment.event.EvaluationEvent;
	
	import model.DataModel;
	
	import components.autoevaluation.Autoevaluator;
	import components.autoevaluation.AutoevaluatorManager;
	import components.autoevaluation.Evaluation;
	
	import mx.resources.ResourceManager;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ObjectUtil;
	
	import view.common.CustomAlert;
	
	import vo.TranscriptionsVO;

	public class AutoEvaluateCommand implements ICommand, IResponder {

		public function execute(event:CairngormEvent):void {
			new AutoEvaluationDelegate(this).getResponseTranscriptions((event as EvaluationEvent).evaluation);
		}

		public function result(data:Object):void {
			var result:Object = data.result;
			var error:String = "";
			if(result is TranscriptionsVO) {
				var transcriptions:TranscriptionsVO = result as TranscriptionsVO;
				if(transcriptions.exerciseTranscriptionStatus.toLowerCase() != "converted") {
					if(transcriptions.exerciseTranscriptionStatus.toLowerCase() == "pending")
						error = ResourceManager.getInstance().getString('myResources','YOUR_AUTOEVALUATION_REQUEST_IS_PENDING');
					else if(transcriptions.exerciseTranscriptionStatus.toLocaleLowerCase() == "processing")
						error = ResourceManager.getInstance().getString('myResources','YOUR_AUTOEVALUATION_REQUEST_IS_BEING_PROCESSED');
					else
						error = ResourceManager.getInstance().getString('myResources','AUTOEVALUATION_NOT_AVAILABLE');
				} else if(transcriptions.responseTranscriptionStatus.toLocaleLowerCase() != "converted") {
					if(transcriptions.responseTranscriptionStatus.toLowerCase() == "pending")
						error = ResourceManager.getInstance().getString('myResources','YOUR_AUTOEVALUATION_REQUEST_IS_PENDING');
					else if(transcriptions.responseTranscriptionStatus.toLocaleLowerCase() == "processing")
						error = ResourceManager.getInstance().getString('myResources','YOUR_AUTOEVALUATION_REQUEST_IS_BEING_PROCESSED');
					else
						error = ResourceManager.getInstance().getString('myResources','AUTOEVALUATION_NOT_AVAILABLE');
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
			CustomAlert.error(ResourceManager.getInstance().getString('myResources','ERROR_WHILE_PROCESSING_AUTOEVALUATION_REQUEST'));
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
				DataModel.getInstance().autoevaluationError = ResourceManager.getInstance().getString('myResources','AUTOEVALUATION_NOT_AVAILABLE');;
			}
		}
	}
}