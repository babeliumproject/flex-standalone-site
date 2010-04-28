package business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	import mx.rpc.remoting.RemoteObject;
	
	import vo.ExerciseReportVO;
	import vo.ExerciseScoreVO;
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
		
		public function addUnprocessedExercise(exercise:ExerciseVO):void{
			var service:RemoteObject=ServiceLocator.getInstance().getRemoteObject("exerciseRO");
			var pendingCall:AsyncToken=service.addUnprocessedExercise(exercise);
			pendingCall.addResponder(responder);
		}
		
		public function getExercises():void{
			var service:RemoteObject=ServiceLocator.getInstance().getRemoteObject("exerciseRO");
			var pendingCall:AsyncToken=service.getExercises();
			pendingCall.addResponder(responder);
		}

		public function getExerciseLocales(exercise:ExerciseVO):void{
			var service:RemoteObject=ServiceLocator.getInstance().getRemoteObject("exerciseRO");
			var pendingCall:AsyncToken=service.getExerciseLocales(exercise.id);
			pendingCall.addResponder(responder);
		}
		
		public function getExerciseRoles(exercise:ExerciseVO) : void{
			var service:RemoteObject=ServiceLocator.getInstance().getRemoteObject("exerciseRO");
			var pendingCall:AsyncToken=service.getExerciseRoles(exercise.id);
			pendingCall.addResponder(responder);
		}
		
		public function addInnapropriateExerciseReport(report:ExerciseReportVO):void{
			var service:RemoteObject=ServiceLocator.getInstance().getRemoteObject("exerciseRO");
			var pendingCall:AsyncToken=service.addInnapropriateExerciseReport(report);
			pendingCall.addResponder(responder);
		}
		
		public function addExerciseScore(score:ExerciseScoreVO):void{
			var service:RemoteObject=ServiceLocator.getInstance().getRemoteObject("exerciseRO");
			var pendingCall:AsyncToken=service.addExerciseScore(score);
			pendingCall.addResponder(responder);
		}
		
	}
}