package commands.userManagement
{
	import business.*;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import events.*;
	
	import mx.controls.Alert;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ObjectUtil;
	
	import model.DataModel;

	public class RestorePassCommand implements ICommand, IResponder
	{

		public function execute(event:CairngormEvent):void
		{
			new UserDelegate(this).restorePass((event as LoginEvent).user);
		}
		
		public function result(data:Object):void
		{
			var error:String = data.result.toString();
			
			if ( error == "Done" )
			{
				DataModel.getInstance().passRecoveryDone = !DataModel.getInstance().passRecoveryDone;
				new ViewChangeEvent(ViewChangeEvent.VIEW_HOME_MODULE).dispatch();
				Alert.show("New password has been sent to account's email");
			}
			else
			{
				DataModel.getInstance().restorePassErrorMessage = error;	
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