package modules.assessment.command
{
	import business.EvaluationDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import model.DataModel;
	
	import modules.assessment.event.EvaluationEvent;
	
	import mx.collections.ArrayCollection;
	import mx.messaging.messages.RemotingMessage;
	import mx.resources.ResourceManager;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ArrayUtil;
	import mx.utils.ObjectUtil;
	
	import view.common.CustomAlert;
	
	public class DetailsOfAssessedResponseCommand implements ICommand, IResponder
	{
		private var dataModel:DataModel = DataModel.getInstance();
		private var cgEvent:CairngormEvent;
		
		public function execute(event:CairngormEvent):void
		{
			cgEvent = event;
			new EvaluationDelegate(this).detailsOfAssessedResponse((event as EvaluationEvent).responseId);
		}
		
		public function result(data:Object):void
		{
			var result:Object=data.result;
			
			if (result)
			{
				dataModel.responseAssessmentData = result;
			} else {
				dataModel.responseAssessmentData = null;
			}
			dataModel.responseAssessmentDataRetrieved = !dataModel.responseAssessmentDataRetrieved;
		}
		
		public function fault(info:Object):void
		{
			//Raised when attempting to call the service without an active session
			var faultEvent:FaultEvent=FaultEvent(info);
			var rm:RemotingMessage = faultEvent.token.message as RemotingMessage;
			if(rm){
				var faultString:String = faultEvent.fault.faultString;
				var faultDetail:String = faultEvent.fault.faultDetail;
				trace("[Error] "+rm.source+"."+rm.operation+": " + faultString);
			}
			//trace(ObjectUtil.toString(info));
			//CustomAlert.error(ResourceManager.getInstance().getString('myResources','ERROR_WHILE_RETRIEVING_RESPONSES_ASSESSMENTS'))
		}
	}
}