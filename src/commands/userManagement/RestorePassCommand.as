package commands.userManagement
{
	import business.*;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import events.*;
	
	import model.DataModel;
	
	import mx.controls.Alert;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ObjectUtil;
	
	import view.common.CustomAlert;

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
				CustomAlert.info("The new password has been sent to your email.");
			}
			else
			{
				DataModel.getInstance().restorePassErrorMessage = error;	
			}
		}
		
		public function fault(info:Object):void
		{
			var faultEvent:FaultEvent = FaultEvent(info);
			CustomAlert.error("Error while trying to restore your password.");
			trace(ObjectUtil.toString(info));
		}
		
	}
}