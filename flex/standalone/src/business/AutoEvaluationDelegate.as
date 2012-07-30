package business {
	import com.adobe.cairngorm.business.ServiceLocator;
	
	import mx.controls.Alert;
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	import mx.rpc.remoting.RemoteObject;
	
	import vo.EvaluationVO;

	public class AutoEvaluationDelegate {
		private var responder:IResponder

		public function AutoEvaluationDelegate(responder:IResponder) {
			this.responder = responder;
		}

		public function getResponseTranscriptions(requestData:EvaluationVO):void {
			var responseId:int = requestData.responseId;
			var service:RemoteObject = ServiceLocator.getInstance().getRemoteObject("autoevaluationRO");
			var pendingCall:AsyncToken = service.getResponseTranscriptions(responseId);
			pendingCall.addResponder(responder);
		}
		
		public function enableTranscriptionToExercise(requestData:EvaluationVO):void {
			var exerciseId:int = requestData.exerciseId;
			var transcriptionSystem:String = requestData.transcriptionSystem;
			var service:RemoteObject = ServiceLocator.getInstance().getRemoteObject("autoevaluationRO");
			var pendingCall:AsyncToken = service.enableTranscriptionToExercise(exerciseId, transcriptionSystem.toLowerCase());
			pendingCall.addResponder(responder);
		}
		
		public function enableTranscriptionToResponse(requestData:EvaluationVO):void {
			var responseId:int = requestData.responseId;
			var transcriptionSystem:String = requestData.transcriptionSystem;
			var service:RemoteObject = ServiceLocator.getInstance().getRemoteObject("autoevaluationRO");
			var pendingCall:AsyncToken = service.enableTranscriptionToResponse(responseId, transcriptionSystem.toLowerCase());
			pendingCall.addResponder(responder);
		}
		
		public function checkAutoevaluationSupportResponse(requestData:EvaluationVO):void {
			var responseId:int = requestData.responseId;
			var transcriptionSystem:String = requestData.transcriptionSystem;
			var service:RemoteObject = ServiceLocator.getInstance().getRemoteObject("autoevaluationRO");
			var pendingCall:AsyncToken = service.checkAutoevaluationSupportResponse(responseId, transcriptionSystem.toLowerCase());
			pendingCall.addResponder(responder);
		}
		
		public function checkAutoevaluationSupportExercise(requestData:EvaluationVO):void{
			var exerciseId:int = requestData.exerciseId;
			var transcriptionSystem:String = requestData.transcriptionSystem;
			var service:RemoteObject = ServiceLocator.getInstance().getRemoteObject("autoevaluationRO");
			var pendingCall:AsyncToken = service.checkAutoevaluationSupportExercise(exerciseId, transcriptionSystem.toLowerCase());
			pendingCall.addResponder(responder);
		}

	}
}