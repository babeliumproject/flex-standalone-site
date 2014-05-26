package modules.course.command
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import model.DataModel;
	
	import modules.course.event.CourseEvent;
	import modules.course.model.CourseModel;
	import modules.course.service.CourseDelegate;
	
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	
	public class ViewCourse implements ICommand, IResponder
	{
		private var _model:DataModel = DataModel.getInstance();
		
		public function ViewCourse()
		{
			
		}
		
		public function execute(event:CairngormEvent):void
		{
			new CourseDelegate(this).viewCourse((event as CourseEvent).query);
		}
		
		public function result(data:Object):void
		{
			var result:Object=data.result;
			var courseModel:CourseModel = _model.moduleMap['course'];
			courseModel.viewCourseData = result;
			courseModel.viewCourseDataChanged = !courseModel.viewCourseDataChanged;
		}
		
		public function fault(info:Object):void
		{
			var faultEvent:FaultEvent=FaultEvent(info);
		}
	}
}