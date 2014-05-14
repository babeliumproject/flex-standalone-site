package commands.videoUpload
{
	import business.ExerciseDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import modules.exercise.event.ExerciseEvent;
	
	import model.DataModel;
	
	import mx.resources.ResourceManager;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ObjectUtil;
	
	import view.common.CustomAlert;
	
	import vo.CreditHistoryVO;

	public class AddUnprocessedExerciseCommand implements ICommand, IResponder
	{

		public function execute(event:CairngormEvent):void
		{
			new ExerciseDelegate(this).addUnprocessedExercise((event as ExerciseEvent).exercise);
		}
		
		public function result(data:Object):void
		{
			//Should be the id of the added exercise
			if (!data.result is int){
				CustomAlert.error(ResourceManager.getInstance().getString('myResources','ERROR_WHILE_SAVING_EXERCISE_DATA'));
			} else {
				CustomAlert.info(ResourceManager.getInstance().getString('myResources','ALERT_SUCCESSFUL_FILE_UPLOAD_RED5'));
				//Add this to the DataModel
				var exerciseId:int = int(data.result);
		
				
				var tempCreditHistory:CreditHistoryVO = new CreditHistoryVO();
				tempCreditHistory.videoExerciseId = exerciseId;
				
				DataModel.getInstance().historicData = tempCreditHistory;
				
				DataModel.getInstance().unprocessedExerciseSaved = true;
			}
		}
		
		public function fault(info:Object):void
		{
			var faultEvent: FaultEvent = FaultEvent(info);
			CustomAlert.error(ResourceManager.getInstance().getString('myResources','ERROR_WHILE_SAVING_EXERCISE_DATA'));
			trace(ObjectUtil.toString(info));
		}
		
	}
}