package modules.account.command
{
	import business.RegisterUserDelegate;
	import business.UserDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import events.ModifyUserEvent;
	import events.RegisterUserEvent;
	
	import model.DataModel;
	
	import mx.resources.ResourceManager;
	import mx.rpc.IResponder;
	import mx.utils.ObjectUtil;
	
	import view.common.CustomAlert;
	
	public class ChangePassCommand implements ICommand, IResponder
	{
		
		public function execute(event:CairngormEvent):void
		{
			new UserDelegate(this).changePass((event as ModifyUserEvent).user);
		}
		
		public function result(data:Object):void
		{
			var successfulUpdate:Boolean = data.result as Boolean;
			if(!successfulUpdate)
				CustomAlert.error(ResourceManager.getInstance().getString('myResources','OLD_PASSWORD_WRONG')); // TODO
			else
			{
				
				CustomAlert.info(ResourceManager.getInstance().getString('myResources','PASSWORD_SUCCESSFULLY_CHANGED')); // TODO
				DataModel.getInstance().passwordChanged = true;
			}
		}
		
		public function fault(info:Object):void
		{
			CustomAlert.error(ResourceManager.getInstance().getString('myResources','ERROR_WHILE_CHANGING_PASSWORD'));
			trace(ObjectUtil.toString(info));
		}
	}
}