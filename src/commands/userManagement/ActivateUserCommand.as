package commands.userManagement
{
	import business.RegisterUserDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import events.RegisterUserEvent;
	
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
			if(!successfulUpdate){
				Alert.show("A problem occurred while trying to activate your account");
			} else{
				Alert.show("Your account has been successfully activated");
			}
		}
		
		public function fault(info:Object):void
		{
			Alert.show("Error while activating your account.");
			trace(ObjectUtil.toString(info));
		}
	}
}