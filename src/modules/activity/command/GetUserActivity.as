package modules.activity.command
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import model.DataModel;
	
	import modules.activity.event.UserActivityEvent;
	import modules.activity.service.UserActivityDelegate;
	
	import mx.messaging.messages.RemotingMessage;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	
	public class GetUserActivity implements ICommand, IResponder
	{
		private var _model:DataModel=DataModel.getInstance();
		
		public function execute(event:CairngormEvent):void
		{
			var params:Object = (event as UserActivityEvent).params;
			new UserActivityDelegate(this).getUserActivity(params);
		}
		
		public function result(data:Object):void
		{
			var result:Object=data.result;
			_model.userActivityData=result;
			_model.userActivityDataRetrieved=!_model.userActivityDataRetrieved;
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