package business{
	
	import com.adobe.cairngorm.business.ServiceLocator;
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	import mx.rpc.remoting.RemoteObject;	
	
	public class TagCloudDelegate{
		
		public var responder:IResponder;

		public function TagCloudDelegate(responder:IResponder){
			this.responder=responder;
		}
		
		public function getTagCloud():void{
			var service:RemoteObject=ServiceLocator.getInstance().getRemoteObject("tagCloudRO");
			var pendingCall:AsyncToken=service.getTagCloud();
			pendingCall.addResponder(responder);
		}
	}
}