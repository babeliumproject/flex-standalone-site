package commands.userManagement
{
	import business.*;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import control.BabeliaBrowserManager;
	
	import events.*;
	
	import model.DataModel;
	
	import mx.controls.Alert;
	import mx.resources.ResourceManager;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ObjectUtil;
	
	import view.common.CustomAlert;
	
	import vo.UserVO;

	public class RegisterUserCommand implements ICommand, IResponder
	{
		
		private var _dataModel:DataModel = DataModel.getInstance();

		public function execute(event:CairngormEvent):void
		{
			new RegisterUserDelegate(this).processRegister((event as RegisterUserEvent).user);
		}
		
		public function result(data:Object):void
		{
			var result:Object = data.result;
			//If the login is successful it will return the user data
			if(result is UserVO){
				_dataModel.loggedUser = null;
				_dataModel.registrationErrorMessage = null;
				_dataModel.isSuccessfullyLogged = false;
				_dataModel.isLoggedIn = false;
				//new ViewChangeEvent(ViewChangeEvent.VIEW_HOME_MODULE).dispatch();
				BabeliaBrowserManager.getInstance().redirect('/home');
				CustomAlert.info(ResourceManager.getInstance().getString('myResources','ACTIVATION_EMAIL_SENT'));
			} else {
				//Inform about the error
				var error:String = result.toString();
				_dataModel.registrationErrorMessage = error;
				_dataModel.isSuccessfullyLogged = false;
				_dataModel.isLoggedIn = false;
			}
			_dataModel.registrationResponse = !_dataModel.registrationResponse;
		}
		
		public function fault(info:Object):void
		{
			_dataModel.registrationResponse = !_dataModel.registrationResponse;
			var faultEvent:FaultEvent = FaultEvent(info);
			CustomAlert.error(ResourceManager.getInstance().getString('myResources','ERROR_WHILE_REGISTERING'));
			trace(ObjectUtil.toString(info));
		}
		
	}
}