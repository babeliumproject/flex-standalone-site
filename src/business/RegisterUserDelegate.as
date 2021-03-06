package business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	import mx.rpc.remoting.RemoteObject;
	
	import vo.NewUserVO;
	
	public class RegisterUserDelegate
	{
		private var responder:IResponder;
		
		public function RegisterUserDelegate(responder:IResponder)
		{
			this.responder = responder;
		}
		
		public function processRegister(user:Object):void{
			var service:RemoteObject = ServiceLocator.getInstance().getRemoteObject("registerRO");
			var pendingCall:AsyncToken = service.register(user);
			pendingCall.addResponder(responder);
		}
		
		public function activateUser(user:Object):void{
			var service:RemoteObject = ServiceLocator.getInstance().getRemoteObject("registerRO");
			var pendingCall:AsyncToken = service.activate(user);
			pendingCall.addResponder(responder);
		}

	}
}