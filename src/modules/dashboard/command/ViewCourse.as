package modules.dashboard.command
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import model.DataModel;
	
	import modules.dashboard.event.CourseEvent;
	import modules.dashboard.model.CourseModel;
	import modules.dashboard.service.CourseDelegate;
	
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