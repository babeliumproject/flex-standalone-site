package modules.course.service
{
	import com.adobe.cairngorm.business.ServiceLocator;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	import mx.rpc.remoting.RemoteObject;

	public class CourseDelegate
	{
		private var responder:IResponder;
		
		public function CourseDelegate(responder:IResponder)
		{
			this.responder = responder;
		}
		
		public function getCourses(query:Object = null):void{
			var service:RemoteObject = ServiceLocator.getInstance().getRemoteObject( "courseRO" );
			var pendingCall:AsyncToken = service.getCourses(query);
			pendingCall.addResponder(responder);
		}
		
		public function viewCourse(query:Object = null):void{
			var service:RemoteObject = ServiceLocator.getInstance().getRemoteObject( "courseRO" );
			var pendingCall:AsyncToken = service.viewCourse(query);
			pendingCall.addResponder(responder);
		}
	}
}