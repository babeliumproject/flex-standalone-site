package business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	import mx.rpc.remoting.RemoteObject;
	
	
	import vo.ExerciseVO;


	public class ExerciseDelegate
	{

		public var responder:IResponder;

		public function ExerciseDelegate(responder:IResponder)
		{
			this.responder=responder;
		}

		public function addExercise(local:ExerciseVO, youtube:ExerciseVO):void
		{
			var service:RemoteObject=ServiceLocator.getInstance().getRemoteObject("exerciseRO");
			var pendingCall:AsyncToken=service.addExercise(local, youtube);
			pendingCall.addResponder(responder);
		}
		
		public function getExercises():void{
			var service:RemoteObject=ServiceLocator.getInstance().getRemoteObject("exerciseRO");
			var pendingCall:AsyncToken=service.getExercises();
			pendingCall.addResponder(responder);
		}
		
		public function makePublic(responseID:Number) : void
		{
			var service:RemoteObject=ServiceLocator.getInstance().getRemoteObject("exerciseRO");
			var pendingCall:AsyncToken=service.makePublic(responseID);
			pendingCall.addResponder(responder);
		}

	}
}