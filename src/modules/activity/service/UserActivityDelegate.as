package modules.activity.service
{
	import com.adobe.cairngorm.business.ServiceLocator;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	import mx.rpc.remoting.RemoteObject;

	public class UserActivityDelegate
	{
		private var responder:IResponder;
		private static const SERVICE_REMOTE_OBJECT:String = "userRO";
		
		public function UserActivityDelegate(responder:IResponder)
		{
			this.responder=responder;
		}
		
		public function getUserActivity(params:Object=null):void{
			var service:RemoteObject = ServiceLocator.getInstance().getRemoteObject(SERVICE_REMOTE_OBJECT);
			var pendingCall:AsyncToken = service.getUserActivity(params);
			pendingCall.addResponder(responder);
		}
	}
}