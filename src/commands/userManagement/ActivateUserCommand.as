package commands.userManagement
{
	import business.RegisterUserDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import events.RegisterUserEvent;
	import events.ViewChangeEvent;
	
	import model.DataModel;
	
	import mx.controls.Alert;
	import mx.rpc.IResponder;
	import mx.utils.ObjectUtil;
	
	public class ActivateUserCommand implements ICommand, IResponder
	{
		
		public function execute(event:CairngormEvent):void
		{
			new RegisterUserDelegate(this).activateUser((event as RegisterUserEvent).user);
		}
		
		public function result(data:Object):void
		{
			var successfulUpdate:Boolean = data.result as Boolean;
			if(!successfulUpdate)
				DataModel.getInstance().accountActivationStatus = 0;
			else
				DataModel.getInstance().accountActivationStatus = 1;
			DataModel.getInstance().accountActivationRetrieved = true;
		}
		
		public function fault(info:Object):void
		{
			Alert.show("Error while activating your account.");
			trace(ObjectUtil.toString(info));
		}
	}
}