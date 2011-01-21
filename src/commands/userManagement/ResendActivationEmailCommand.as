package commands.userManagement
{
	import business.LoginDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import events.LoginEvent;
	
	import model.DataModel;
	
	import mx.resources.ResourceManager;
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
				DataModel.getInstance().activationEmailResent = !DataModel.getInstance().activationEmailResent;
				CustomAlert.info(ResourceManager.getInstance().getString('myResources','ACTIVATION_EMAIL_SENT'));
			} else if (data.result == "user_active_wrong_email"){
				//Error message incorrect data
				DataModel.getInstance().activationEmailResentErrorMessage = ResourceManager.getInstance().getString('myResources','LABEL_ERROR_WRONG_ACTIVATION_RESEND_DATA');
			}
		}
		
		public function fault(info:Object):void
		{
			CustomAlert.error(ResourceManager.getInstance().getString('myResources','ERROR_WHILE_SENDING_ACTIVATION_MAIL'));
			trace(ObjectUtil.toString(info));
		}
	}
}