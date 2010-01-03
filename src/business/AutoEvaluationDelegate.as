package business {
	import com.adobe.cairngorm.business.ServiceLocator;
	
	import mx.controls.Alert;
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	import mx.rpc.remoting.RemoteObject;

	public class AutoEvaluationDelegate {
		private var responder:IResponder

		public function AutoEvaluationDelegate(responder:IResponder) {
			this.responder = responder;
		}

		public function getResponseTranscriptions(responseID:int):void {
			var service:RemoteObject = ServiceLocator.getInstance().getRemoteObject("autoevaluationRO");
			var pendingCall:AsyncToken = service.getResponseTranscriptions(responseID);
			pendingCall.addResponder(responder);
		}
		
		public function enableTranscriptionToExercise(exerciseID:int, transcriptionSystem:String):void {
			var service:RemoteObject = ServiceLocator.getInstance().getRemoteObject("autoevaluationRO");
			var pendingCall:AsyncToken = service.enableTranscriptionToExercise(exerciseID, transcriptionSystem.toLowerCase());
			pendingCall.addResponder(responder);
		}
		
		public function enableTranscriptionToResponse(responseID:int, transcriptionSystem:String):void {
			var service:RemoteObject = ServiceLocator.getInstance().getRemoteObject("autoevaluationRO");
			var pendingCall:AsyncToken = service.enableTranscriptionToResponse(responseID, transcriptionSystem.toLowerCase());
			pendingCall.addResponder(responder);
		}
		
		public function checkAutoevaluationSupportResponse(responseID:int, transcriptionSystem:String):void {
			var service:RemoteObject = ServiceLocator.getInstance().getRemoteObject("autoevaluationRO");
			var pendingCall:AsyncToken = service.checkAutoevaluationSupportResponse(responseID, transcriptionSystem.toLowerCase());
			pendingCall.addResponder(responder);
		}
		
		public function checkAutoevaluationSupportExercise(exerciseID:int, transcriptionSystem:String):void{
			var service:RemoteObject = ServiceLocator.getInstance().getRemoteObject("autoevaluationRO");
			var pendingCall:AsyncToken = service.checkAutoevaluationSupportExercise(exerciseID, transcriptionSystem.toLowerCase());
			pendingCall.addResponder(responder);
		}

	}
}