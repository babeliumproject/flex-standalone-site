package commands.videoUpload
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
	
	import view.common.CustomAlert;

	public class AddCreditsForUploadingCommand implements ICommand, IResponder
	{

		public function execute(event:CairngormEvent):void
		{
			//Commands delegate service calls to a Delegate
			new CreditsDelegate(this).addCreditsForUploading((event as CreditEvent).userId);
		}
		
		//These are the service callback methods
		public function result(data:Object):void
		{
			//Process the returned data and call the required events
			var successfulUpdate:Boolean = data.result as Boolean;
			if(!successfulUpdate){
				CustomAlert.error("A problem occurred while trying to update your credits.");
			} else{
				var userId:int = DataModel.getInstance().loggedUser.id;
				new CreditEvent(CreditEvent.ADD_CREDIT_ENTRY_UPLOADING, userId).dispatch();
			}
		}
		
		public function fault(info:Object):void
		{
			var faultEvent:FaultEvent = FaultEvent(info);
			CustomAlert.error("Error occurred while updating your credit count.");
			trace(ObjectUtil.toString(info));
		}
		
	}
}