package commands.userManagement
{
	import business.RegisterUserDelegate;
	import business.UserDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import events.ModifyUserEvent;
	import events.RegisterUserEvent;
	
	import model.DataModel;
	
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
				CustomAlert.error("Old password is wrong"); // TODO
			else
			{
				
				CustomAlert.info("Password changed"); // TODO
				DataModel.getInstance().passwordChanged = true;
			}
		}
		
		public function fault(info:Object):void
		{
			CustomAlert.error("Error while changing your password, try again later.");
			trace(ObjectUtil.toString(info));
		}
	}
}