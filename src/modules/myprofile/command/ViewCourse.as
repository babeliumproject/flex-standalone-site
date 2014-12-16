package modules.myprofile.command
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import model.DataModel;
	
	import modules.myprofile.event.CourseEvent;
	import modules.myprofile.model.CourseModel;
	import modules.myprofile.service.CourseDelegate;
	
	import mx.messaging.messages.RemotingMessage;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	
	public class ViewCourse implements ICommand, IResponder
	{
		private var _model:DataModel = DataModel.getInstance();
		
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
			var rm:RemotingMessage = faultEvent.token.message as RemotingMessage;
			if(rm){
				var faultString:String = faultEvent.fault.faultString;
				var faultDetail:String = faultEvent.fault.faultDetail;
				trace("[Error] "+rm.source+"."+rm.operation+": " + faultString);
			}
		}
	}
}