package business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	import mx.rpc.remoting.RemoteObject;
	
	import vo.SubtitlesAndRolesVO;
	
	
	public class SubtitlesAndRolesDelegate
	{
		public var responder:IResponder;
		
		
		public function SubtitlesAndRolesDelegate(responder:IResponder)
		{
			this.responder = responder;
		}
				
		public function getInfoSubRoles(info:SubtitlesAndRolesVO):void
		{
			var service:RemoteObject = ServiceLocator.getInstance().getRemoteObject("subrolesRO");
			var pendingCall:AsyncToken = service.getInfoSubRoles(info.exerciseId,info.language);
			pendingCall.addResponder(responder);			
		}		
		
		public function getRoles(info:SubtitlesAndRolesVO):void
		{
			var service:RemoteObject = ServiceLocator.getInstance().getRemoteObject("subrolesRO");
			var pendingCall:AsyncToken = service.getRoles(info.exerciseId);
			pendingCall.addResponder(responder);			
		}
		

	}
}