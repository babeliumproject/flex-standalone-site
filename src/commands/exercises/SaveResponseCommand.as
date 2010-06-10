package commands.exercises
{
	import business.ResponseDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import events.ResponseEvent;
	import events.ViewChangeEvent;
	
	import model.DataModel;
	
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ObjectUtil;
	
	import view.common.CustomAlert;

	public class SaveResponseCommand implements ICommand, IResponder
	{

		public function execute(event:CairngormEvent):void
		{
			new ResponseDelegate(this).saveResponse((event as ResponseEvent).response);
		}
		
		public function result(data:Object):void
		{
			//Should be the id of the added response
			if (!data.result is int){
				CustomAlert.error("Your response data could not be saved successfully.");
			} else {
				var responseId:int = data.result.toString();
				//The response has been successfully saved, so we must store it's id in the model
				DataModel.getInstance().historicData.videoResponseId = responseId;
				DataModel.getInstance().savedResponseId = responseId;
				DataModel.getInstance().savedResponseRetrieved = !DataModel.getInstance().savedResponseRetrieved;
				
				//Change the exercise viewstack to view the evaluation options
				new ViewChangeEvent(ViewChangeEvent.VIEW_EXERCISE_EVALUATION_OPTIONS).dispatch();
			}
			
		}
		
		public function fault(info:Object):void
		{
			var faultEvent : FaultEvent = FaultEvent(info);
			CustomAlert.error("Error while saving your Response.");
			trace(ObjectUtil.toString(info));
		}
		
	}
}