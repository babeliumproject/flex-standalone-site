package commands.userManagement
{
	import business.*;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import control.URLManager;
	
	import events.*;
	
	import model.DataModel;
	
	import modules.signup.view.SignUpForm;
	
	import mx.resources.ResourceManager;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ObjectUtil;
	
	import utils.LocaleUtils;
	
	import view.common.CustomAlert;
	
	import vo.UserLanguageVO;
	import vo.UserVO;

	public class ProcessLoginCommand implements ICommand, IResponder
	{

		public function execute(event:CairngormEvent):void
		{
			new LoginDelegate(this).processLogin((event as LoginEvent).user);
		}

		public function result(data:Object):void
		{
			var result:Object=data.result;
			//If the login is successful it will return the user data
			if (result is UserVO)
			{
				var user:UserVO=result as UserVO;
				
				var ifaceLanguageCode:String = 'none';
				for each(var lang:UserLanguageVO in user.userLanguages){
					if(lang.level == 7){
						ifaceLanguageCode = lang.language;
						break;
					}
				}
				LocaleUtils.arrangeLocaleChain(ifaceLanguageCode);

				DataModel.getInstance().loggedUser=user;
				DataModel.getInstance().isSuccessfullyLogged=true;
				DataModel.getInstance().isLoggedIn=true;
				
				//Initialize the timer that keeps this session alive
				DataModel.getInstance().eventSchedulerInstance.startKeepAlive();
			}
			else
			{
				//Inform about the error in the popup window
				var error:String=result.toString();
				DataModel.getInstance().loginErrorMessage=error;
				DataModel.getInstance().isSuccessfullyLogged=false;
				DataModel.getInstance().isLoggedIn=false;
			}
			trace("Processlogin: "+DataModel.getInstance().isSuccessfullyLogged);
		}

		public function fault(info:Object):void
		{
			var faultEvent:FaultEvent=FaultEvent(info);
			CustomAlert.error(ResourceManager.getInstance().getString('myResources','ERROR_WHILE_LOGGING_IN'));
			trace(ObjectUtil.toString(info));
		}

	}
}