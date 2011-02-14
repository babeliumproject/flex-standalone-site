package business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	
	import mx.controls.Alert;
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	import mx.rpc.remoting.RemoteObject;
	import mx.utils.ObjectUtil;
	
	import vo.ExerciseVO;
	
	public class YouTubeDelegate
	{
		
		private var responder:IResponder;
		
		public function YouTubeDelegate(responder:IResponder)
		{
			this.responder = responder;
		}

		public function directClientLoginUpload(data:ExerciseVO):void{
			var service:RemoteObject = ServiceLocator.getInstance().getRemoteObject("youtubeRO");
			var pendingCall:AsyncToken = service.directClientLoginUpload(data);
			pendingCall.addResponder(responder);
		}
		
		public function checkUploadedVideoStatus(data:ExerciseVO):void{
			var service:RemoteObject = ServiceLocator.getInstance().getRemoteObject("youtubeRO");
			var pendingCall:AsyncToken = service.checkUploadedVideoStatus(data.name);
			pendingCall.addResponder(responder);
		}

	}
}