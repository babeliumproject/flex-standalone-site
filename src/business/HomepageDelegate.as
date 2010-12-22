package business
{
	import com.adobe.cairngorm.business.ServiceLocator;

	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	import mx.rpc.remoting.RemoteObject;

	public class HomepageDelegate
	{

		public var responder:IResponder;

		public function HomepageDelegate(responder:IResponder)
		{
			this.responder=responder;
		}

		public function unsignedMessagesOfTheDay(messageLocale:String):void
		{
			var service:RemoteObject=ServiceLocator.getInstance().getRemoteObject("homepageRO");
			var pendingCall:AsyncToken=service.unsignedMessagesOfTheDay(messageLocale);
			pendingCall.addResponder(responder);
		}

		public function signedMessagesOfTheDay(messageLocale:String):void
		{
			var service:RemoteObject=ServiceLocator.getInstance().getRemoteObject("homepageRO");
			var pendingCall:AsyncToken=service.signedMessagesOfTheDay(messageLocale);
			pendingCall.addResponder(responder);
		}
		
		public function usersLatestReceivedAssessments():void{
			
		}
		
		public function usersLatestGivenAssessments():void{
			
		}
		
		public function usersLatestUploadedVideos():void{
			
		}
		
		public function topScoreMostViewedVideos():void{
			
		}
		
		public function latestAvailableVideos():void{
			
		}

	}
}