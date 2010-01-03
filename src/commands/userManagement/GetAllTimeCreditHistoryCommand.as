package commands.userManagement
{
	import business.CreditsDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import events.CreditEvent;
	
	import flash.events.Event;
	
	import model.DataModel;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ArrayUtil;
	import mx.utils.ObjectUtil;
	
	import vo.CreditHistoryVO;

	public class GetAllTimeCreditHistoryCommand implements ICommand, IResponder
	{

		public function execute(event:CairngormEvent):void
		{
			new CreditsDelegate(this).getAllTimeCreditHistory((event as CreditEvent).userId);
		}
		
		public function result(data:Object):void
		{
			var result:Object = data.result;
			
			if(result is Array){
				var resultCollection:ArrayCollection = new ArrayCollection(ArrayUtil.toArray(result));
			
				if(!(resultCollection[0] is CreditHistoryVO)){
					Alert.show("The Result is not a well-formed object");
				} else {
					//Set the data to the application's model
					DataModel.getInstance().creditHistory = resultCollection;
					DataModel.getInstance().isCreditHistoryRetrieved = true;
					//Reflect the visual changes
				}
			}
		}
		
		public function fault(info:Object):void
		{
			DataModel.getInstance().isCreditHistoryRetrieved = false;
			var faultEvent: FaultEvent = FaultEvent(info);
			Alert.show("Error: "+faultEvent.message);
			trace(ObjectUtil.toString(info));
		}
		
	}
}