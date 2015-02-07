package modules.create.command
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import control.URLManager;
	
	import model.DataModel;
	
	import modules.create.event.CreateEvent;
	import modules.create.service.CreateDelegate;
	
	import mx.messaging.messages.RemotingMessage;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	
	public class PublishExercise implements ICommand, IResponder
	{
		private var _model:DataModel=DataModel.getInstance();
		
		public function execute(event:CairngormEvent):void
		{
			var params:Object=(event as CreateEvent).params;
			new CreateDelegate(this).publishExercise(params);
		}
		
		public function result(data:Object):void
		{
			var result:Object=data.result;
			URLManager.getInstance().redirect('/create');
		}
		
		public function fault(info:Object):void
		{
			var faultEvent:FaultEvent=FaultEvent(info);
			var rm:RemotingMessage=faultEvent.token.message as RemotingMessage;
			if (rm)
			{
				var faultString:String=faultEvent.fault.faultString;
				var faultDetail:String=faultEvent.fault.faultDetail;
				trace("[Error] " + rm.source + "." + rm.operation + ": " + faultString);
			}
		}
	}
}