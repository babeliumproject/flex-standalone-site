package commands.exercises
{
	import business.ResponseDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import events.CreditEvent;
	import events.ResponseEvent;
	
	import model.DataModel;
	
	import mx.controls.Alert;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ObjectUtil;

	public class MakeResponsePublicCommand implements ICommand, IResponder
	{

		public function execute(event:CairngormEvent):void
		{
			new ResponseDelegate(this).makePublic((event as ResponseEvent).response);
		}
		
		public function result(data:Object):void {
			//Process the returned data and call the required events
			var successfulUpdate:Boolean = data.result as Boolean;
			if(!successfulUpdate){
				Alert.show("A problem occurred while trying to update your response");
			} else{
				var userId:int = DataModel.getInstance().loggedUser.id;
				new CreditEvent(CreditEvent.SUB_CREDITS_FOR_EVAL_REQUEST, userId).dispatch();
			}
		}

		public function fault(info:Object):void {
			var faultEvent:FaultEvent = FaultEvent(info);
			Alert.show("Error while making your response publicly available: \n" + faultEvent.message);
			trace(ObjectUtil.toString(info));
		}
		
	}
}