package commands.userManagement
{
	import business.LoginDelegate;

	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;

	import model.DataModel;

	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ObjectUtil;

	import view.common.CustomAlert;

	public class SignOutCommand implements ICommand, IResponder
	{

		public function execute(event:CairngormEvent):void
		{
			new LoginDelegate(this).doLogout();
		}

		public function result(data:Object):void
		{
			DataModel.getInstance().loggedUser=null;
			DataModel.getInstance().isLoggedIn=false;
			DataModel.getInstance().isSuccessfullyLogged=false;

			DataModel.getInstance().eventSchedulerInstance.stopKeepAlive();
		}

		public function fault(info:Object):void
		{
			var faultEvent:FaultEvent=FaultEvent(info);
			CustomAlert.error("Error while logging you out.");
			trace(ObjectUtil.toString(info));
		}
	}
}