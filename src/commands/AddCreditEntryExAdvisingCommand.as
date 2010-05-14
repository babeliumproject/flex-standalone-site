package commands
{
	import business.CreditsDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import model.DataModel;
	
	import mx.controls.Alert;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ObjectUtil;
	
	import view.common.CustomAlert;
	
	import vo.CreditHistoryVO;

	public class AddCreditEntryExAdvisingCommand implements ICommand, IResponder
	{

		public function execute(event:CairngormEvent):void
		{
			DataModel.getInstance().historicData.userId = DataModel.getInstance().loggedUser.id;
			DataModel.getInstance().historicData.changeAmount = DataModel.getInstance().prefDic['subtitleAdditionCredits'];
			DataModel.getInstance().historicData.changeDate = new Date().toString();
			DataModel.getInstance().historicData.changeType = "ex_advise";
			var historicData:CreditHistoryVO = DataModel.getInstance().historicData;
			new CreditsDelegate(this).addEntryToCreditHistory(historicData);
		}
		
		public function result(data:Object):void
		{
			//We check if the insert went well by checking the last_insert_id value
			if (!data.result > 0)
				CustomAlert.error("Your credit historic record couldn't be properly updated.");
		}
		
		public function fault(info:Object):void
		{
			var faultEvent:FaultEvent = FaultEvent(info);
			CustomAlert.error("Error while modifying credit history.");
			trace(ObjectUtil.toString(info));
		}
		
	}
}