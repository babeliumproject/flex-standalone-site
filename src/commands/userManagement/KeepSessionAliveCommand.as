package commands.userManagement
{
	import business.UserDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import events.UserEvent;
	
	import mx.rpc.IResponder;
	import mx.utils.ObjectUtil;
	
	import view.common.CustomAlert;
	
	public class KeepSessionAliveCommand implements ICommand, IResponder
	{
		
		public function execute(event:CairngormEvent):void
		{
			new UserDelegate(this).keepSessionAlive();
		}
		
		public function result(data:Object):void
		{
			//User is kept alive, do nothing more
		}
		
		public function fault(info:Object):void
		{
			CustomAlert.error("Error while trying to keep the session active");
			trace(ObjectUtil.toString(info));
		}
	}
}