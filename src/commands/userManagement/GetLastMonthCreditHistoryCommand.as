package commands.userManagement
{
	import business.CreditsDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import events.CreditEvent;
	
	import model.DataModel;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.formatters.DateFormatter;
	import mx.resources.ResourceManager;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ArrayUtil;
	import mx.utils.ObjectUtil;
	
	import view.common.CustomAlert;
	
	import vo.CreditHistoryVO;

	public class GetLastMonthCreditHistoryCommand implements ICommand, IResponder
	{

		public static const MILLISECONDS_IN_A_DAY:int = 86400000;

		private var resultCollection:ArrayCollection;
		private var processedData:ArrayCollection;
		private var dateFormatter:DateFormatter;


		public function execute(event:CairngormEvent):void
		{
			new CreditsDelegate(this).getLastMonthCreditHistory();
		}

		public function result(data:Object):void
		{
			var result:Object=data.result;

			if (result is Array)
			{
				resultCollection=new ArrayCollection(ArrayUtil.toArray(result));

				if (!(resultCollection[0] is CreditHistoryVO))
				{
					CustomAlert.error(ResourceManager.getInstance().getString('myResources','ERROR_WHILE_RETRIEVING_CREDIT_HISTORY'));
				}
				else
				{
					//Set the data to the application's model
					DataModel.getInstance().creditHistory=resultCollection;
					//Process received data
					processDataForCharting();
					//Reflect the visual changes
					DataModel.getInstance().isCreditHistoryRetrieved=true;
					DataModel.getInstance().isChartDataRetrieved=true;
				}
			} else {
				DataModel.getInstance().creditHistory.removeAll();
				DataModel.getInstance().isCreditHistoryRetrieved = true;
				noChangesFill();
			}
		}

		public function fault(info:Object):void
		{
			var faultEvent:FaultEvent=FaultEvent(info);
			CustomAlert.error(ResourceManager.getInstance().getString('myResources','ERROR_WHILE_RETRIEVING_CREDIT_HISTORY'));
			trace(ObjectUtil.toString(info));
		}

		public function processDataForCharting():void
		{
			var dataProcessor:Array = new Array();
			
			var credits:int=DataModel.getInstance().loggedUser.creditCount;
			var chartDate:String="";
			dateFormatter=new DateFormatter();
			if (resultCollection.length > 0)
			{
				var firstItem:Boolean=true;
				for each (var ch:CreditHistoryVO in resultCollection)
				{
					var line:Object;
					//Display hour and minute of the incidence
					dateFormatter.formatString="YYYY/MM/DD JJ:NN:SS";
					chartDate=dateFormatter.format(ch.changeDate);
					if (firstItem)
					{
						firstItem=false;
					}
					else
					{
						credits=credits - ch.changeAmount;
					}
					line={Date: chartDate, Credits: credits};
					dataProcessor.push(line);
				}
				dataProcessor.reverse();
				processedData = new ArrayCollection(ArrayUtil.toArray(dataProcessor));
				fillMissingData();
				DataModel.getInstance().creditChartData=processedData;
			}
		}
		
		private function fillMissingData():void{
			var currentDate:Date = new Date();
			var checkDate:Date = new Date();
			var previousMonth:Date = new Date(checkDate.setMonth(checkDate.month - 1));
			var firstItem:Object = processedData.getItemAt(0);
			var lastItem:Object = processedData.getItemAt(processedData.length-1);
			var firstEntry:Date = new Date(firstItem.Date);
			var lastEntry:Date = new Date(lastItem.Date);
			if (ObjectUtil.dateCompare(previousMonth, firstEntry) == -1){
				var lFirst:Object = {Date: dateFormatter.format(previousMonth), Credits: firstItem.Credits};
				processedData.addItem(lFirst);
			}
			if (ObjectUtil.dateCompare(lastEntry, currentDate) == -1){
				var lEnd:Object = {Date: dateFormatter.format(currentDate), Credits: lastItem.Credits};
				processedData.addItem(lEnd);
			}
		}
		
		private function noChangesFill():void{
			dateFormatter=new DateFormatter();
			dateFormatter.formatString="YYYY/MM/DD JJ:NN:SS";
			var credits:int = DataModel.getInstance().loggedUser.creditCount;
			var currentDate:Date = new Date();
			var checkDate:Date = new Date();
			var previousMonth:Date = new Date(checkDate.setMonth(checkDate.month - 1));
			var emptyArray:Array = new Array();
			var firstItem:Object = {Date: dateFormatter.format(previousMonth), Credits: credits};
			var lastItem:Object = {Date: dateFormatter.format(currentDate), Credits: credits};
			emptyArray.push(firstItem);
			emptyArray.push(lastItem);
			processedData = new ArrayCollection(ArrayUtil.toArray(emptyArray));
			DataModel.getInstance().creditChartData=processedData;
			DataModel.getInstance().isChartDataRetrieved = true;
		}

	}
}