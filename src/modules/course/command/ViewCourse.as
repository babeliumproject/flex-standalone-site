package modules.course.command
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import model.DataModel;
	
	import modules.course.event.CourseEvent;
	import modules.course.service.CourseDelegate;
	
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
			_model.courseOverviewData = result;
			_model.courseOverviewDataRetrieved = !_model.courseOverviewDataRetrieved;
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