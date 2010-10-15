package business
{
	import com.adobe.cairngorm.business.ServiceLocator;

	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	import mx.rpc.remoting.RemoteObject;

	public class MessageOfTheDayDelegate
	{

		public var responder:IResponder;

		public function MessageOfTheDayDelegate(responder:IResponder)
		{
			this.responder=responder;
		}

		public function unsignedMessagesOfTheDay(messageLocale:String):void
		{
			var service:RemoteObject=ServiceLocator.getInstance().getRemoteObject("motdRO");
			var pendingCall:AsyncToken=service.unsignedMessagesOfTheDay(messageLocale);
			pendingCall.addResponder(responder);
		}

		public function signedMessagesOfTheDay(messageLocale:String):void
		{
			var service:RemoteObject=ServiceLocator.getInstance().getRemoteObject("motdRO");
			var pendingCall:AsyncToken=service.signedMessagesOfTheDay(messageLocale);
			pendingCall.addResponder(responder);
		}

	}
}