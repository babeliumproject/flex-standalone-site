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

	public class CheckAutoevaluationSupportResponseCommand implements ICommand, IResponder {
		public function execute(event:CairngormEvent):void {
			new AutoEvaluationDelegate(this).checkAutoevaluationSupportResponse((event as EvaluationEvent).evaluation);
		}

		public function result(data:Object):void {
			DataModel.getInstance().isAutoevaluable = data.result as Boolean;
		}

		public function fault(info:Object):void {
			DataModel.getInstance().isAutoevaluable = false;
			var faultEvent:FaultEvent = FaultEvent(info);
			CustomAlert.error("Error while checking for autoevaluation support.");
			trace(ObjectUtil.toString(info));
		}

	}
}