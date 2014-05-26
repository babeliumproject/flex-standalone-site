package modules.course.command
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import model.DataModel;
	
	import modules.course.event.CourseEvent;
	import modules.course.model.CourseModel;
	import modules.course.service.CourseDelegate;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ArrayUtil;
	
	public class GetCourses implements ICommand, IResponder
	{
		private var _model:DataModel = DataModel.getInstance();
		
		
		public function execute(event:CairngormEvent):void
		{
			new CourseDelegate(this).getCourses((event as CourseEvent).query);
		}
		
		public function result(data:Object):void
		{
			var resultCollection:ArrayCollection;
			var result:Object=data.result;
			var courseModel:CourseModel = _model.moduleMap['course'];
			
			if (result is Array && (result as Array).length > 0 )
			{
				resultCollection=new ArrayCollection(ArrayUtil.toArray(result));
				courseModel.getCoursesData = resultCollection;
			} else {
				courseModel.getCoursesData = new ArrayCollection();
			}
			courseModel.getCoursesDataChanged = !courseModel.getCoursesDataChanged;
		}
		
		public function fault(info:Object):void
		{
			var faultEvent:FaultEvent=FaultEvent(info);
		}
	}
}