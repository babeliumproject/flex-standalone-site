package commands.userManagement
{
	import business.*;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import events.*;
	
	import model.DataModel;
	
	import mx.resources.ResourceManager;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ObjectUtil;
	
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
				switchLocale(ifaceLanguageCode);

				DataModel.getInstance().loggedUser=user;
				DataModel.getInstance().isSuccessfullyLogged=true;
				DataModel.getInstance().isLoggedIn=true;
				
				//Initialize the timer that keeps this session alive
				DataModel.getInstance().eventSchedulerInstance.startKeepAlive();

				// If user is in register module, redirect to home
				if (DataModel.getInstance().currentContentViewStackIndex == ViewChangeEvent.VIEWSTACK_REGISTER_MODULE_INDEX)
				{
					new ViewChangeEvent(ViewChangeEvent.VIEW_HOME_MODULE).dispatch();
				}
			}
			else
			{
				//Inform about the error in the popup window
				var error:String=result.toString();
				DataModel.getInstance().loginErrorMessage=error;
				DataModel.getInstance().isSuccessfullyLogged=false;
				DataModel.getInstance().isLoggedIn=false;
			}
		}

		public function fault(info:Object):void
		{
			var faultEvent:FaultEvent=FaultEvent(info);
			CustomAlert.error("Error while authenticating you in the system.");
			trace(ObjectUtil.toString(info));
		}

		private function switchLocale(localeCode:String):void
		{
			if (ResourceManager.getInstance().getLocales().indexOf(localeCode) != -1)
			{
				ResourceManager.getInstance().localeChain=[localeCode];
				//Updating changes in DataModel, used in Search.mxml 
				DataModel.getInstance().languageChanged=true;
				DataModel.getInstance().currentlyActiveLocale = localeCode;
			}
		}

	}
}