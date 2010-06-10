package commands.userManagement
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import model.DataModel;

	public class SignOutCommand implements ICommand
	{

		public function execute(event:CairngormEvent):void
		{
			DataModel.getInstance().loggedUser = null;
			DataModel.getInstance().isLoggedIn = false;
			DataModel.getInstance().isSuccessfullyLogged = false;
			
			DataModel.getInstance().keepAliveTimerInstance.stopKeepAlive();
		}
		
	}
}