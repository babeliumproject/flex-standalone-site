package commands.evaluation
{
	import business.EvaluationDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import events.EvaluationEvent;
	
	import mx.controls.Alert;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ObjectUtil;
	
	public class GetResponsesWaitingAssessmentCommand implements ICommand, IResponder
	{
		
		public function execute(event:CairngormEvent):void
		{
			new EvaluationDelegate(this).getResponsesWaitingAssessment((event as EvaluationEvent).requestData);
		}
		
		public function result(data:Object):void
		{
		}
		
		public function fault(info:Object):void
		{
			var faultEvent:FaultEvent = FaultEvent(info);
			Alert.show("Error while retrieving responses waiting assessment");
			trace(ObjectUtil.toString(faultEvent));
		}
	}
}