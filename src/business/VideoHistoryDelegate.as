package business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	import mx.rpc.remoting.RemoteObject;
	
	import vo.UserVideoHistoryVO;

	public class VideoHistoryDelegate
	{
		
		private var responder:IResponder;
		
		public function VideoHistoryDelegate(responder:IResponder)
		{
			this.responder = responder;
		}
		
		public function exerciseWatched(videoHistoryData:UserVideoHistoryVO):void{
			var service:RemoteObject = ServiceLocator.getInstance().getRemoteObject("videoHistoryRO");
			var pendingCall:AsyncToken = service.exerciseWatched(videoHistoryData);
			pendingCall.addResponder(responder);
		}
		
		public function exerciseAttemptResponse(videoHistoryData:UserVideoHistoryVO):void{
			var service:RemoteObject = ServiceLocator.getInstance().getRemoteObject("videoHistoryRO");
			var pendingCall:AsyncToken = service.exerciseAttemptResponse(videoHistoryData);
			pendingCall.addResponder(responder);	
		}
		
		public function exerciseSaveResponse(videoHistoryData:UserVideoHistoryVO):void{
			var service:RemoteObject = ServiceLocator.getInstance().getRemoteObject("videoHistoryRO");
			var pendingCall:AsyncToken = service.exerciseSaveResponse(videoHistoryData);
			pendingCall.addResponder(responder);	
		}
		
	}
}