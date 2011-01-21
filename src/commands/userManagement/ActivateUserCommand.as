package commands.userManagement
{
	import business.RegisterUserDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import events.RegisterUserEvent;
	
	import model.DataModel;
	
	import mx.controls.Alert;
	import mx.resources.ResourceManager;
	import mx.rpc.IResponder;
	import mx.utils.ObjectUtil;
	
	import view.common.CustomAlert;
	
	public class ActivateUserCommand implements ICommand, IResponder
	{
		
		public function execute(event:CairngormEvent):void
		{
			new RegisterUserDelegate(this).activateUser((event as RegisterUserEvent).user);
		}
		
		public function result(data:Object):void
		{
			var localeCode:Object = data.result;
			if(data.result == null)
				DataModel.getInstance().accountActivationStatus = 0;
			else
			{
				DataModel.getInstance().accountActivationStatus = 1;
				ResourceManager.getInstance().localeChain=[localeCode];
				//Updating changes in DataModel, used in Search.mxml 
				DataModel.getInstance().languageChanged=true;
			}
			
			DataModel.getInstance().accountActivationRetrieved = true;
		}
		
		public function fault(info:Object):void
		{
			CustomAlert.error(ResourceManager.getInstance().getString('myResources','ERROR_WHILE_ACTIVATING_ACCOUNT'));
			trace(ObjectUtil.toString(info));
		}
	}
}