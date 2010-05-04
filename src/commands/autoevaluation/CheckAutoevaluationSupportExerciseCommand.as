package commands.autoevaluation {
	import business.AutoEvaluationDelegate;

	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;

	import events.EvaluationEvent;

	import model.DataModel;

	import mx.controls.Alert;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ObjectUtil;

	public class CheckAutoevaluationSupportExerciseCommand implements ICommand, IResponder {
		public function execute(event:CairngormEvent):void {
			new AutoEvaluationDelegate(this).checkAutoevaluationSupportExercise((event as EvaluationEvent).requestData);
		}

		public function result(data:Object):void {
			DataModel.getInstance().isAutoevaluable = data.result as Boolean;
		}

		public function fault(info:Object):void {
			DataModel.getInstance().isAutoevaluable = false;
			var faultEvent:FaultEvent = FaultEvent(info);
			Alert.show("Error: " + faultEvent.message);
			trace(ObjectUtil.toString(info));
		}

	}
}