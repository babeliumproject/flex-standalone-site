package business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	
	import mx.controls.Alert;
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	import mx.rpc.remoting.RemoteObject;
	import mx.utils.ObjectUtil;
	
	import vo.ExerciseVO;
	import vo.VideoSliceVO;
	
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
		
		public function retrieveVideo(data:String):void{
			var service:RemoteObject = ServiceLocator.getInstance().getRemoteObject("youtubeRO");
			var pendingCall:AsyncToken = service.retrieveVideo(data);
			pendingCall.addResponder(responder);
		}
		
		public function retrieveUserVideo(data:String):void{
			var service:RemoteObject = ServiceLocator.getInstance().getRemoteObject("youtubeRO");
			var pendingCall:AsyncToken = service.retrieveUserVideo(data);
			pendingCall.addResponder(responder);
		}
		
		public function createSlice(data:VideoSliceVO):void{
			var service:RemoteObject = ServiceLocator.getInstance().getRemoteObject("youtubeRO");
			var pendingCall:AsyncToken = service.createSlice(data);
			pendingCall.addResponder(responder);
		}
		
		public function insertVideoSlice(data:VideoSliceVO, data2:ExerciseVO):void{
			var service:RemoteObject = ServiceLocator.getInstance().getRemoteObject("youtubeRO");
			var pendingCall:AsyncToken = service.insertVideoSlice(data, data2);
			pendingCall.addResponder(responder);
		}

	}
}