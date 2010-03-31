package commands.evaluation
{
	import business.CreditsDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import events.CreditEvent;
	
	import model.DataModel;
	
	import mx.controls.Alert;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ObjectUtil;

	public class AddCreditsForEvaluatingCommand implements ICommand, IResponder
	{

		public function execute(event:CairngormEvent):void
		{
			new CreditsDelegate(this).addCreditsForEvaluating((event as CreditEvent).userId);
		}
		
		public function result(data:Object):void
		{
			//Process the returned data and call the required events
			var successfulUpdate:Boolean = data.result as Boolean;
			if(!successfulUpdate){
				Alert.show("A problem occurred while trying to update your credits");
			} else{
				var userId:int = DataModel.getInstance().loggedUser.id;
				new CreditEvent(CreditEvent.ADD_CREDIT_ENTRY_EVALUATING, userId).dispatch();
			}
		}
		
		public function fault(info:Object):void
		{
			var faultEvent:FaultEvent = FaultEvent(info);
			Alert.show("Error: "+faultEvent.message);
			trace(ObjectUtil.toString(info));
		}
		
	}
}