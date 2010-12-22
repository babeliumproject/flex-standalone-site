package commands.home
{
	
	import business.HomepageDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import events.MessageOfTheDayEvent;
	
	import model.DataModel;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.rpc.IResponder;
	import mx.utils.ArrayUtil;
	import mx.utils.ObjectUtil;
	
	import view.common.CustomAlert;
	
	public class UnsignedMessageOfTheDayCommand implements ICommand, IResponder
	{
		
		private var dataModel:DataModel = DataModel.getInstance();
		
		public function execute(event:CairngormEvent):void
		{
			new HomepageDelegate(this).unsignedMessagesOfTheDay((event as MessageOfTheDayEvent).messageLocale);
		}
		
		public function result(data:Object):void
		{
			var result:Object=data.result;
			var resultCollection:ArrayCollection;
			
			if (result is Array && (result as Array).length > 0 )
			{
				resultCollection=new ArrayCollection(ArrayUtil.toArray(result));
				//Set the data in the application's model
				dataModel.messagesOfTheDayData = resultCollection;
			} else {
				dataModel.messagesOfTheDayData = new ArrayCollection();
			}
			dataModel.messagesOfTheDayRetrieved = !dataModel.messagesOfTheDayRetrieved;
		}
		
		public function fault(info:Object):void
		{
			trace(ObjectUtil.toString(info));
			CustomAlert.error("Error while retrieving the messages of the day.");
		}
	}
}