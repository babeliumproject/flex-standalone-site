package commands.videoUpload
{
	import business.ExerciseDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import events.CreditEvent;
	import events.ExerciseEvent;
	
	import model.DataModel;
	
	import mx.resources.ResourceManager;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	
	import view.common.CustomAlert;
	
	public class AddWebcamExerciseCommand implements ICommand, IResponder
	{
		
		public function execute(event:CairngormEvent):void
		{
			new ExerciseDelegate(this).addWebcamExercise((event as ExerciseEvent).exercise);
		}
		
		public function result(data:Object):void
		{
			//Should be the id of the added exercise
			if (!data.result is int){
				CustomAlert.error("Your exercise data could not be saved successfully.");
			} else {
				CustomAlert.info(ResourceManager.getInstance().getString('myResources','ALERT_SUCCESSFUL_WEBCAM_UPLOAD_RED5'));
				var userId:int = DataModel.getInstance().loggedUser.id;
				DataModel.getInstance().historicData.videoExerciseId = data.result;
				new CreditEvent(CreditEvent.ADD_CREDITS_FOR_UPLOADING, userId).dispatch();
				DataModel.getInstance().unprocessedExerciseSaved = true;
			}
		}
		
		public function fault(info:Object):void
		{
			var faultEvent:FaultEvent = FaultEvent(info);
			CustomAlert.error("Error while saving your exercise.");
			trace(faultEvent.toString());
		}
	}
}