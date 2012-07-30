package business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	
	import mx.controls.Alert;
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	import mx.rpc.remoting.RemoteObject;
	import mx.utils.ObjectUtil;
	
	import vo.CreditHistoryVO;
	
	public class CreditsDelegate
	{
		
		private var responder:IResponder;
		
		public function CreditsDelegate(responder:IResponder)
		{
			this.responder = responder;
		}
		
		public function getCurrentDayCreditHistory():void{
			var service:RemoteObject = ServiceLocator.getInstance().getRemoteObject( "creditRO" );
			var pendingCall:AsyncToken = service.getCurrentDayCreditHistory();
			pendingCall.addResponder(responder);
		}
		
		public function getLastWeekCreditHistory():void{
			var service:RemoteObject = ServiceLocator.getInstance().getRemoteObject( "creditRO" );
			var pendingCall:AsyncToken = service.getLastWeekCreditHistory();
			pendingCall.addResponder(responder);
		}
		
		public function getLastMonthCreditHistory():void{
			var service:RemoteObject = ServiceLocator.getInstance().getRemoteObject( "creditRO" );
			var pendingCall:AsyncToken = service.getLastMonthCreditHistory();
			pendingCall.addResponder(responder);
		}
		
		public function getAllTimeCreditHistory():void{
			var service:RemoteObject = ServiceLocator.getInstance().getRemoteObject( "creditRO" );
			var pendingCall:AsyncToken = service.getAllTimeCreditHistory();
			pendingCall.addResponder(responder);
		}

	}
}