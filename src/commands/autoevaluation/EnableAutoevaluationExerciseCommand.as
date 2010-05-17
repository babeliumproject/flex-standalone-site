package commands.autoevaluation {
	import business.AutoEvaluationDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import events.EvaluationEvent;
	
	import model.DataModel;
	
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ObjectUtil;
	
	import view.common.CustomAlert;

	public class EnableAutoevaluationExerciseCommand implements ICommand, IResponder {

		public function execute(event:CairngormEvent):void {
			new AutoEvaluationDelegate(this).enableTranscriptionToExercise((event as EvaluationEvent).evaluation);
		}

		public function result(data:Object):void {
			var result:Object = data.result;
			if(int(result) <= 0)
				DataModel.instance.enableAutoevalToExerciseError = result as String;
		}

		public function fault(info:Object):void {
			var faultEvent:FaultEvent = FaultEvent(info);
			CustomAlert.error("Error while enabling the autoevaluation on this video.");
			trace(ObjectUtil.toString(info));
		}

	}
}