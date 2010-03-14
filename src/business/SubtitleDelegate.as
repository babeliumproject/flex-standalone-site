package business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	
	import mx.controls.Alert;
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	import mx.rpc.remoting.RemoteObject;
	import mx.utils.ObjectUtil;
	
	import vo.SubtitleAndSubtitleLinesVO;
	
	public class SubtitleDelegate
	{
		public var responder:IResponder;
		
		
		public function SubtitleDelegate(responder:IResponder)
		{
			this.responder = responder;
		}
		
		public function saveSubtitles(subtitles:SubtitleAndSubtitleLinesVO):void{
			var service:RemoteObject = ServiceLocator.getInstance().getRemoteObject("subrolesRO");
			var pendingCall:AsyncToken = service.saveSubtitles(subtitles);
			pendingCall.addResponder(responder);
		}
		
		public function getExerciseRoles():void{
			
		}
		
		public function getExerciseMetaData():void{
		}
		
		public function getExerciseScore():void{
		}
		
		public function addExerciseScore():void{
		}
		
		public function getExerciseComments():void{
		}
		
		public function addExerciseComment():void{
		}
		
		public function getExerciseLevel():void{
		}
		
		public function addExerciseLevel():void{
		}
		
		public function getExerciseSubtitles():void{
		}
		
		public function getSubtitleLines(subtitle:SubtitleAndSubtitleLinesVO):void{
			var service:RemoteObject = ServiceLocator.getInstance().getRemoteObject("subtitleRO");
			var pendingCall:AsyncToken = service.getSubtitleLines(subtitle.exerciseId,subtitle.language);
			pendingCall.addResponder(responder);
			
			
		}
		
		public function editSubtitle():void{
		}
		
		public function scoreSubtitle():void{
			
		}
		
		public function scoreSubtitleLine():void{
			
		}
	}
}