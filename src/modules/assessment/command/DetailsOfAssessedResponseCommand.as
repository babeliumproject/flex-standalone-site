package modules.assessment.command
{
	import business.EvaluationDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import modules.assessment.event.EvaluationEvent;
	
	import model.DataModel;
	
	import mx.collections.ArrayCollection;
	import mx.resources.ResourceManager;
	import mx.rpc.IResponder;
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
			trace(ObjectUtil.toString(info));
			CustomAlert.error(ResourceManager.getInstance().getString('myResources','ERROR_WHILE_RETRIEVING_RESPONSES_ASSESSMENTS'))
		}
	}
}