package modules.course.command
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import model.DataModel;
	
	import modules.course.event.CourseEvent;
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
			var params:Object = (event as CourseEvent).query;
			new CourseDelegate(this).getCourses(params);
		}
		
		public function result(data:Object):void
		{
			var result:Object=data.result;
			var courseCollection:ArrayCollection;
			
			if (result)
			{	
				courseCollection = new ArrayCollection(ArrayUtil.toArray(result));
				if(courseCollection){
					_model.courseList=courseCollection;
				} else {
					_model.courseList=null;
				}
			} else {
				_model.courseList=null;
			}
		
			_model.courseListRetrieved=!_model.courseListRetrieved;
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