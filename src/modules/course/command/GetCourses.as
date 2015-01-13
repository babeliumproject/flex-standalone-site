package modules.course.command
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import model.DataModel;
	
	import modules.course.event.CourseEvent;
	import modules.course.model.CourseModel;
	import modules.course.service.CourseDelegate;
	
	import mx.collections.ArrayCollection;
	import mx.messaging.messages.RemotingMessage;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ArrayUtil;
	import mx.utils.ObjectUtil;
	import mx.utils.object_proxy;
	
	public class GetCourses implements ICommand, IResponder
	{
		private var _model:DataModel = DataModel.getInstance();
		
		
		public function execute(event:CairngormEvent):void
		{
			new CourseDelegate(this).getCourses((event as CourseEvent).query);
		}
		
		public function result(data:Object):void
		{
			
			var result:Object=data.result;
			var courseModel:CourseModel = _model.moduleMap['course'];
			
			if (result)
			{
				if(result.hasOwnProperty('mycourses')){
					var courseCollection:ArrayCollection;
					courseCollection = new ArrayCollection(ArrayUtil.toArray(result.mycourses));
					courseModel.myCoursesData = courseCollection;
				} else {
					courseModel.myCoursesData = new ArrayCollection();
				}
				if(result.hasOwnProperty('myexercises')){
					var exerciseCollection:ArrayCollection;
					exerciseCollection = new ArrayCollection(ArrayUtil.toArray(result.myexercises));
					courseModel.myExercisesData = exerciseCollection;
				} else {
					courseModel.myExercisesData = new ArrayCollection();
				}
			} else {
				courseModel.myCoursesData = new ArrayCollection();
				courseModel.myExercisesData = new ArrayCollection();
			}
			
			courseModel.getCoursesDataChanged = !courseModel.getCoursesDataChanged;
		}
		
		public function fault(info:Object):void
		{
			var faultEvent:FaultEvent=FaultEvent(info);
			var rm:RemotingMessage = faultEvent.token.message as RemotingMessage;
			if(rm){
				var faultString:String = faultEvent.fault.faultString;
				var faultDetail:String = faultEvent.fault.faultDetail;
				trace("[Error] "+rm.source+"."+rm.operation+": " + faultString);
			}
		}
	}
}