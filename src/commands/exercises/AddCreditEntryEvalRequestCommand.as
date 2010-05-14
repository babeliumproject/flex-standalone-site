package commands.exercises
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

	public class AddCreditEntryEvalRequestCommand implements ICommand, IResponder
	{
		public function execute(event:CairngormEvent):void
		{
			
			DataModel.getInstance().historicData.userId = DataModel.getInstance().loggedUser.id;
			DataModel.getInstance().historicData.changeAmount = - DataModel.getInstance().prefDic['evaluationRequestCredits'];
			DataModel.getInstance().historicData.changeDate = new Date().toString();
			DataModel.getInstance().historicData.changeType = "eval_request";
			DataModel.getInstance().historicData.videoEvaluationId = 0;
			var historic:CreditHistoryVO = DataModel.getInstance().historicData;
			new CreditsDelegate(this).addEntryToCreditHistory(historic);
		}
		
		public function result(data:Object):void
		{
			//We check if the insert went well by checking the last_insert_id value
			if (!data.result is int){
				CustomAlert.error("Your credit historic record couldn't be properly updated.");
			} else {
				new UserEvent(UserEvent.GET_USER_INFO).dispatch();
			}
		}
		
		public function fault(info:Object):void
		{
			var faultEvent: FaultEvent = FaultEvent(info);
			CustomAlert.error("Error while adding Credit History Entry.");
			trace(ObjectUtil.toString(info));
		}
		
	}
}