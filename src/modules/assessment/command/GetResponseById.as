package modules.assessment.command
{
	import business.EvaluationDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import model.DataModel;
	
	import modules.assessment.event.EvaluationEvent;
	
	import mx.messaging.messages.RemotingMessage;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	
	public class GetResponseById implements ICommand, IResponder
	{
		private var _model:DataModel=DataModel.getInstance();
		
		public function execute(event:CairngormEvent):void
		{
			var responseid:int = (event as EvaluationEvent).responseId;
			new EvaluationDelegate(this).getResponseById(responseid);
		}
		
		public function result(data:Object):void
		{
			var result:Object=data.result;
		}
		
		public function fault(info:Object):void
		{
			var faultEvent:FaultEvent=FaultEvent(info);
			var rm:RemotingMessage = faultEvent.token.message as RemotingMessage;
			if(rm){
				var faultString:String = faultEvent.fault.faultString;
				var faultDetail:String = faultEvent.fault.faultDetail;
				trace("[Error] "+rm.source+"."+rm.operation+": " + faultString);
			}
		}
	}
}