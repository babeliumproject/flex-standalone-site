package modules.exercise.command
{
	import business.ExerciseDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import model.DataModel;
	
	import modules.exercise.event.ExerciseEvent;
	
	import mx.messaging.messages.RemotingMessage;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	
	public class RequestRecordingSlot implements ICommand, IResponder
	{
		private var _model:DataModel=DataModel.getInstance();
		
		public function execute(event:CairngormEvent):void
		{
			var params:Object = (event as ExerciseEvent).params;
			new ExerciseDelegate(this).requestRecordingSlot();
		}
		
		public function result(data:Object):void
		{
			var result:Object=data.result;
			
			_model.recordMediaData=result;
			_model.recordMediaDataRetrieved=!_model.recordMediaDataRetrieved;

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