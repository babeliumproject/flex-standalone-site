package commands.evaluation
{
	import business.EvaluationDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import events.CreditEvent;
	import events.EvaluationEvent;
	
	import model.DataModel;
	
	import mx.rpc.IResponder;
	import mx.utils.ObjectUtil;
	
	import view.common.CustomAlert;
	
	public class AddAssessmentCommand implements ICommand, IResponder
	{
		private var dataModel:DataModel = DataModel.getInstance();
		
		public function execute(event:CairngormEvent):void
		{
			new EvaluationDelegate(this).addAssessment((event as EvaluationEvent).evaluation);
		}
		
		public function result(data:Object):void
		{
			//We check if the insert went well by checking the last_insert_id value
			if (!data.result is int){
				CustomAlert.error("Your assessment couldn't be properly saved");
			} else {
				CustomAlert.info("Your assessment has been saved. Thanks for your collaboration.");
				dataModel.addAssessmentRetrieved = !dataModel.addAssessmentRetrieved;
			}
		}
		
		public function fault(info:Object):void
		{
			trace(ObjectUtil.toString(info));
			CustomAlert.error("Error while trying to save your assessment.");
		}
	}
}