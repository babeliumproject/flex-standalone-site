package commands.userManagement
{
	import business.LoginDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import events.LoginEvent;
	
	import mx.rpc.IResponder;
	import mx.utils.ObjectUtil;
	
	import view.common.CustomAlert;
	
	public class ResendActivationEmailCommand implements ICommand, IResponder
	{
		
		public function execute(event:CairngormEvent):void
		{
			new LoginDelegate(this).resendActivationEmail((event as LoginEvent).activation);
		}
		
		public function result(data:Object):void
		{
			if(data.result as Boolean == true){
				//Activation email successfully resent
			} else if (data.result == "user_active_wrong_email"){
				//Error message incorrect data
			}
		}
		
		public function fault(info:Object):void
		{
			CustomAlert.error("Error while trying to send the activation email.");
			trace(ObjectUtil.toString(info));
		}
	}
}