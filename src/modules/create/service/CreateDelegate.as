package modules.create.service
{
	import com.adobe.cairngorm.business.ServiceLocator;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	import mx.rpc.remoting.RemoteObject;

	public class CreateDelegate
	{
		private var responder:IResponder;
		
		public function CreateDelegate(responder:IResponder)
		{
			this.responder = responder;
		}
		
		public function getExercise(query:Object = null):void{
			var service:RemoteObject = ServiceLocator.getInstance().getRemoteObject("exerciseRO");
			var pendingCall:AsyncToken = service.getExerciseByCode(query.exercisecode);
			pendingCall.addResponder(responder);
		}
		
		public function addExercise(query:Object = null):void{
			var service:RemoteObject = ServiceLocator.getInstance().getRemoteObject( "exerciseRO" );
			var pendingCall:AsyncToken = service.addExercise(query);
			pendingCall.addResponder(responder);
		}
		
		public function updateExercise(query:Object = null):void{
			var service:RemoteObject = ServiceLocator.getInstance().getRemoteObject( "createRO" );
			var pendingCall:AsyncToken = service.saveExerciseData(query);
			pendingCall.addResponder(responder);
		}
		
		public function addExerciseMedia(query:Object = null):void{
			var service:RemoteObject = ServiceLocator.getInstance().getRemoteObject( "createRO" );
			var pendingCall:AsyncToken = service.addExerciseMedia(query);
			pendingCall.addResponder(responder);
		}
		
		public function getCreations(query:Object = null):void{
			var offset:uint = query && query.hasOwnProperty('offset') ? query.offset : 0;
			var rowcount:uint = query && query.hasOwnProperty('rowcount') ? query.rowcount : 0;
			var service:RemoteObject = ServiceLocator.getInstance().getRemoteObject( "createRO" );
			var pendingCall:AsyncToken = service.listUserCreations(offset, rowcount);
			pendingCall.addResponder(responder);
		}
	}
}