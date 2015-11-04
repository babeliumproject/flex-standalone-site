package modules.create.command
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import model.DataModel;
	
	import modules.create.event.CreateEvent;
	import modules.create.service.CreateDelegate;
	
	import mx.collections.ArrayCollection;
	import mx.messaging.messages.RemotingMessage;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ArrayUtil;
	
	public class SaveExerciseMedia implements ICommand, IResponder
	{	
		public function execute(event:CairngormEvent):void
		{
			new CreateDelegate(this).saveExerciseMedia((event as CreateEvent).params);
		}
		
		public function result(data:Object):void
		{
			var result:Object=data.result;
			var resultList:ArrayCollection;
			
			if((result is Array) && (result as Array).length){
				resultList=new ArrayCollection(ArrayUtil.toArray(result));
				DataModel.getInstance().exerciseMedia = resultList;
			} else {
				DataModel.getInstance().exerciseMedia = null;
			}
			DataModel.getInstance().exerciseMediaRetrieved = !DataModel.getInstance().exerciseMediaRetrieved;
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