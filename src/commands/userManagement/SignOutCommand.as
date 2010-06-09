package commands.userManagement
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import model.DataModel;
	
	import modules.userManagement.KeepAliveTimer;

	public class SignOutCommand implements ICommand
	{

		public function execute(event:CairngormEvent):void
		{
			DataModel.getInstance().loggedUser = null;
			DataModel.getInstance().isLoggedIn = false;
			DataModel.getInstance().isSuccessfullyLogged = false;
			
			KeepAliveTimer.stopKeepAlive();
		}
		
	}
}