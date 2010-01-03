package business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	import mx.rpc.remoting.RemoteObject;
	
	import vo.CreditHistoryVO;
	
	public class CreditsDelegate
	{
		
		private var responder:IResponder;
		
		public function CreditsDelegate(responder:IResponder)
		{
			this.responder = responder;
		}
		
		//This is used to make a request to the server through amfphp		
		public function subCreditsForEvalRequest(userId:int):void{
			var service:RemoteObject = ServiceLocator.getInstance().getRemoteObject( "creditRO" );
			var pendingCall:AsyncToken = service.subCreditsForEvalRequest(userId);
			pendingCall.addResponder(responder);
		}
		
		public function addCreditsForSubtitling(userId:int):void{
			var service:RemoteObject = ServiceLocator.getInstance().getRemoteObject( "creditRO" );
			var pendingCall:AsyncToken = service.addCreditsForSubtitling(userId);
			pendingCall.addResponder(responder);
		}
		
		public function addCreditsForEvaluating(userId:int):void{
			var service:RemoteObject = ServiceLocator.getInstance().getRemoteObject( "creditRO" );
			var pendingCall:AsyncToken = service.addCreditsForEvaluating(userId);
			pendingCall.addResponder(responder);
		}
		
		public function addCreditsForExerciseAdvising(userId:int):void{
			var service:RemoteObject = ServiceLocator.getInstance().getRemoteObject( "creditRO" );
			var pendingCall:AsyncToken = service.addCreditsForExerciseAdvising(userId);
			pendingCall.addResponder(responder);
		}
		
		public function addCreditsForUploading(userId:int):void{
			var service:RemoteObject = ServiceLocator.getInstance().getRemoteObject( "creditRO" );
			var pendingCall:AsyncToken = service.addCreditsForUploading(userId);
			pendingCall.addResponder(responder);
		}
		
		public function addEntryToCreditHistory(credit:CreditHistoryVO):void{
			var service:RemoteObject = ServiceLocator.getInstance().getRemoteObject( "creditRO" );
			var pendingCall:AsyncToken = service.addEntryToCreditHistory(credit);
			pendingCall.addResponder(responder);
		}
		
		public function getCurrentDayCreditHistory(userId:int):void{
			var service:RemoteObject = ServiceLocator.getInstance().getRemoteObject( "creditRO" );
			var pendingCall:AsyncToken = service.getCurrentDayCreditHistory(userId);
			pendingCall.addResponder(responder);
		}
		
		public function getLastWeekCreditHistory(userId:int):void{
			var service:RemoteObject = ServiceLocator.getInstance().getRemoteObject( "creditRO" );
			var pendingCall:AsyncToken = service.getLastWeekCreditHistory(userId);
			pendingCall.addResponder(responder);
		}
		
		public function getLastMonthCreditHistory(userId:int):void{
			var service:RemoteObject = ServiceLocator.getInstance().getRemoteObject( "creditRO" );
			var pendingCall:AsyncToken = service.getLastMonthCreditHistory(userId);
			pendingCall.addResponder(responder);
		}
		
		public function getAllTimeCreditHistory(userId:int):void{
			var service:RemoteObject = ServiceLocator.getInstance().getRemoteObject( "creditRO" );
			var pendingCall:AsyncToken = service.getAllTimeCreditHistory(userId);
			pendingCall.addResponder(responder);
		}

	}
}