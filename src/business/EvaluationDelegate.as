package business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	import mx.rpc.remoting.RemoteObject;
	
	import vo.EvaluationVO;

	public class EvaluationDelegate
	{
		
		public var responder:IResponder;
		
		public function EvaluationDelegate(responder:IResponder)
		{
			this.responder = responder;
		}
		
		public function getResponsesWaitingAssessment(userId:int):void
		{
			var service:RemoteObject=ServiceLocator.getInstance().getRemoteObject("evaluationRO");
			var pendingCall:AsyncToken=service.baloratuGabekoak(userId);
			pendingCall.addResponder(responder);
		}
		
		public function getResponsesAssessedToCurrentUser(userId:int):void{
			var service:RemoteObject=ServiceLocator.getInstance().getRemoteObject("evaluationRO");
			var pendingCall:AsyncToken=service.norberariEpaitutakoak(userId);
			pendingCall.addResponder(responder);
		}
		
		public function getResponsesAssessedByCurrentUser(userId:int):void{
			var service:RemoteObject=ServiceLocator.getInstance().getRemoteObject("evaluationRO");
			var pendingCall:AsyncToken=service.nikEpaitutakoak(userId);
			pendingCall.addResponder(responder);
		}
		
		public function addAssessment(assessment:EvaluationVO):void{
			var service:RemoteObject=ServiceLocator.getInstance().getRemoteObject("evaluationRO");
			var pendingCall:AsyncToken=service.insertEpaiketa(assessment);
			pendingCall.addResponder(responder);
		}
		
		public function addVideoAssessment(assessment:EvaluationVO):void{
			var service:RemoteObject=ServiceLocator.getInstance().getRemoteObject("evaluationRO");
			var pendingCall:AsyncToken=service.insertVideoEpaiketa(assessment);
			pendingCall.addResponder(responder);
		}
		
		public function detailsOfAssessedResponse(responseId:int):void{
			var service:RemoteObject=ServiceLocator.getInstance().getRemoteObject("evaluationRO");
			var pendingCall:AsyncToken=service.epaitutakoGrabaketa(responseId);
			pendingCall.addResponder(responder);
		}
		
		public function updateResponseRatingAmount():void{
			var service:RemoteObject=ServiceLocator.getInstance().getRemoteObject("evaluationRO");
			var pendingCall:AsyncToken=service.updateGrabaketa();
			pendingCall.addResponder(responder);
		}
	}
}