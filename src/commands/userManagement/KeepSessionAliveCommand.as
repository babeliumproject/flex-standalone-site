package commands.userManagement
{
	import business.UserDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import events.UserEvent;
	
	import mx.messaging.messages.RemotingMessage;
	import mx.resources.ResourceManager;
	import mx.rpc.Fault;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
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
			var faultEvent:FaultEvent=FaultEvent(info);
			trace("[ERROR] operation: "+(faultEvent.token.message as RemotingMessage).operation+", code: "+faultEvent.fault.faultCode+", name: "+faultEvent.fault.faultString+", detail: "+faultEvent.fault.faultDetail);
			//trace(ObjectUtil.toString(info));
			//CustomAlert.error(ResourceManager.getInstance().getString('myResources','ERROR_WHILE_KEEPING_SESSION'));
		}
	}
}