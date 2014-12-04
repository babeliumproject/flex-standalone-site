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
			var param:String = query ? query.exercisecode : null;
			var pendingCall:AsyncToken = service.getExerciseByCode(param);
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
		
		public function saveExerciseMedia(query:Object = null):void{
			var service:RemoteObject = ServiceLocator.getInstance().getRemoteObject( "createRO" );
			var pendingCall:AsyncToken = service.saveExerciseMedia(query);
			pendingCall.addResponder(responder);
		}
		
		public function getExerciseMedia(query:Object = null):void{
			var service:RemoteObject = ServiceLocator.getInstance().getRemoteObject( "createRO" );
			var pendingCall:AsyncToken = service.getExerciseMedia(query.exercisecode);
			pendingCall.addResponder(responder);	
		}
		
		public function getCreations(query:Object = null):void{
			var offset:uint = query && query.hasOwnProperty('offset') ? query.offset : 0;
			var rowcount:uint = query && query.hasOwnProperty('rowcount') ? query.rowcount : 0;
			var service:RemoteObject = ServiceLocator.getInstance().getRemoteObject( "createRO" );
			var pendingCall:AsyncToken = service.listUserCreations(offset, rowcount);
			pendingCall.addResponder(responder);
		}
		
		public function setDefaultThumbnail(query:Object = null):void{
			var service:RemoteObject = ServiceLocator.getInstance().getRemoteObject( "createRO" );
			var pendingCall:AsyncToken = service.setDefaultThumbnail(query);
			pendingCall.addResponder(responder);
		}
		
		public function deleteExerciseMedia(query:Object = null):void{
			var service:RemoteObject = ServiceLocator.getInstance().getRemoteObject( "createRO" );
			var pendingCall:AsyncToken = service.deleteExerciseMedia(query);
			pendingCall.addResponder(responder);
		}
	}
}