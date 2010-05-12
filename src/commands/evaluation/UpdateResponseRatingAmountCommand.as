package commands.evaluation
{
	import business.EvaluationDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import events.EvaluationEvent;
	
	import mx.rpc.IResponder;
	import mx.utils.ObjectUtil;
	
	import view.common.CustomAlert;
	
	public class UpdateResponseRatingAmountCommand implements ICommand, IResponder
	{
		
		public function execute(event:CairngormEvent):void
		{
			new EvaluationDelegate(this).updateResponseRatingAmount((event as EvaluationEvent).responseId);
		}
		
		public function result(data:Object):void
		{
			//Process the returned data and call the required events
			var successfulUpdate:Boolean = data.result as Boolean;
			if(!successfulUpdate){
				CustomAlert.error("A problem occurred while trying to update the assessment count of this response.");
			} else{
				//Do something if it's required
			}
		}
		
		public function fault(info:Object):void
		{
			trace(ObjectUtil.toString(info));
			CustomAlert.error("Error while updating the assessment count of this response.");
		}
	}
}