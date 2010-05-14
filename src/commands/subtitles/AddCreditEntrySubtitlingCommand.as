package commands.subtitles
{
	import business.CreditsDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import events.UserEvent;
	
	import model.DataModel;
	
	import mx.controls.Alert;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ObjectUtil;
	
	import view.common.CustomAlert;
	
	import vo.CreditHistoryVO;

	public class AddCreditEntrySubtitlingCommand implements ICommand, IResponder
	{

		public function execute(event:CairngormEvent):void
		{
			DataModel.getInstance().subHistoricData.userId=DataModel.getInstance().loggedUser.id;
			DataModel.getInstance().subHistoricData.changeAmount=DataModel.getInstance().prefDic['subtitleAdditionCredits'];
			DataModel.getInstance().subHistoricData.changeDate=new Date().toString();
			DataModel.getInstance().subHistoricData.changeType="subtitling";
			var historicData:CreditHistoryVO=DataModel.getInstance().subHistoricData;
			new CreditsDelegate(this).addEntryToCreditHistory(historicData);
		}

		public function result(data:Object):void
		{
			//We check if the insert went well by checking the last_insert_id value
			if (!data.result > 0)
			{
				CustomAlert.error("Your credit historic record couldn't be properly updated");
			}
			else
			{
				new UserEvent(UserEvent.GET_USER_INFO).dispatch();
			}
		}

		public function fault(info:Object):void
		{
			var faultEvent:FaultEvent=FaultEvent(info);
			CustomAlert.error("Error while modifying credit history.");
			trace(ObjectUtil.toString(info));
		}

	}
}