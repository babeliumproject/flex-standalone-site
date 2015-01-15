package modules.profile.service
{
	import com.adobe.cairngorm.business.ServiceLocator;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	import mx.rpc.remoting.RemoteObject;

	public class ProfileDelegate
	{
		private var responder:IResponder;
		private static const SERVICE_REMOTE_OBJECT:String = "userRO";
		
		public function ProfileDelegate(responder:IResponder)
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