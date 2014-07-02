package modules.create.command
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import model.DataModel;
	
	import modules.create.event.CreateEvent;
	import modules.create.service.CreateDelegate;
	
	import mx.messaging.messages.RemotingMessage;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ObjectUtil;
	
	import vo.ExerciseVO;
	
	public class EditCreation implements ICommand, IResponder
	{
		public function EditCreation()
		{
		}
		
		public function execute(event:CairngormEvent):void
		{
			var params:Object = (event as CreateEvent).exercisedata;
			new CreateDelegate(this).getExercise(params);
		}
		
		public function result(data:Object):void
		{
			var result:Object=data.result;
			if(result){
				DataModel.getInstance().exerciseData = result as ExerciseVO;
			} else {
				DataModel.getInstance().exerciseData = null;
			}
			DataModel.getInstance().exerciseDataRetrieved = !DataModel.getInstance().exerciseDataRetrieved;
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