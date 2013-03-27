package business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	import mx.rpc.remoting.RemoteObject;
	
	public class PreferencesDelegate
	{
		private var responder:IResponder;
		
		public function PreferencesDelegate(responder:IResponder)
		{
			this.responder = responder;
		}
		
		public function getAppPreferences():void{
			//First let's define the RemoteObject used for this request
			var service:RemoteObject = ServiceLocator.getInstance().getRemoteObject( "prefRO" );
			
			//Last, we make the remote call and add a responder to receive the results
			var pendingCall:AsyncToken = service.getAppPreferences();
			pendingCall.addResponder(responder);
		}

	}
}