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
	
	import utils.LocaleUtils;
	
	import view.common.CustomAlert;
	
	public class ActivateUserCommand implements ICommand, IResponder
	{
		
		public function execute(event:CairngormEvent):void
		{
			var params:Object = (event as RegisterUserEvent).user;
			new RegisterUserDelegate(this).activateUser(params);
		}
		
		public function result(data:Object):void
		{
			
			if(!data.result)
				DataModel.getInstance().accountActivationStatus = 0;
			else
			{
				var localeCode:String = String(data.result);
				DataModel.getInstance().accountActivationStatus = 1;
				LocaleUtils.arrangeLocaleChain(localeCode);
			}
			
			DataModel.getInstance().accountActivationRetrieved = !DataModel.getInstance().accountActivationRetrieved;
		}
		
		public function fault(info:Object):void
		{
			CustomAlert.error(ResourceManager.getInstance().getString('myResources','ERROR_WHILE_ACTIVATING_ACCOUNT'));
			trace(ObjectUtil.toString(info));
		}
	}
}