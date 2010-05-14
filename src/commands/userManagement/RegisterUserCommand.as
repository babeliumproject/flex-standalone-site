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
	
	import vo.UserVO;

	public class RegisterUserCommand implements ICommand, IResponder
	{

		public function execute(event:CairngormEvent):void
		{
			new RegisterUserDelegate(this).processRegister((event as RegisterUserEvent).user);
		}
		
		public function result(data:Object):void
		{
			var result:Object = data.result;
			//If the login is successful it will return the user data
			if(result is UserVO){
				DataModel.getInstance().loggedUser = null;
				DataModel.getInstance().isSuccessfullyLogged = false;
				DataModel.getInstance().isLoggedIn = false;
				new ViewChangeEvent(ViewChangeEvent.VIEW_HOME_MODULE).dispatch();
				CustomAlert.info("An activation email has been sent to the email you specified.");
			} else {
				//Inform about the error
				var error:String = result.toString();
				DataModel.getInstance().registrationErrorMessage = error;
				DataModel.getInstance().isSuccessfullyLogged = false;
				DataModel.getInstance().isLoggedIn = false;
			}
		}
		
		public function fault(info:Object):void
		{
			var faultEvent:FaultEvent = FaultEvent(info);
			CustomAlert.error("Error while registering.");
			trace(ObjectUtil.toString(info));
		}
		
	}
}