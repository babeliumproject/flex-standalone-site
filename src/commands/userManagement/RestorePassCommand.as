package commands.userManagement
{
	import business.*;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import events.*;
	
	import model.DataModel;
	
	import mx.controls.Alert;
	import mx.resources.ResourceManager;
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
				CustomAlert.info(ResourceManager.getInstance().getString('myResources','NEW_PASSWORD_SENT'));
			}
			else
			{
				DataModel.getInstance().restorePassErrorMessage = error;	
			}
		}
		
		public function fault(info:Object):void
		{
			var faultEvent:FaultEvent = FaultEvent(info);
			CustomAlert.error(ResourceManager.getInstance().getString('myResources','ERROR_WHILE_RESTORING_PASSWORD'));
			trace(ObjectUtil.toString(info));
		}
		
	}
}