package business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	import mx.rpc.remoting.RemoteObject;
	
	import vo.LoginVO;
	
	public class LoginDelegate
	{
		private var responder:IResponder;
		
		public function LoginDelegate(responder:IResponder)
		{
			this.responder = responder;
		}
		
		public function processLogin(user:LoginVO):void{
			var service:RemoteObject = ServiceLocator.getInstance().getRemoteObject("loginRO");
			var pendingCall:AsyncToken = service.processLogin(user);
			pendingCall.addResponder(responder);
		}

	}
}