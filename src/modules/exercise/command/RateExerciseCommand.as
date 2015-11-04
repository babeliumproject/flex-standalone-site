package modules.exercise.command
{
	import business.ExerciseDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import model.DataModel;
	
	import modules.exercise.event.ExerciseEvent;
	
	import mx.controls.Alert;
	import mx.resources.ResourceManager;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ObjectUtil;
	
	import view.common.CustomAlert;
	
	import vo.ExerciseScoreVO;
	import vo.ExerciseVO;

	public class RateExerciseCommand implements ICommand, IResponder
	{

		public function execute(event:CairngormEvent):void
		{
			var score:ExerciseScoreVO=(event as ExerciseEvent).params as ExerciseScoreVO;
			new ExerciseDelegate(this).addExerciseScore(score);
		}

		public function result(data:Object):void
		{
			//Should be the id of the added rate
			if (!data.result)
			{
				CustomAlert.error(ResourceManager.getInstance().getString('myResources','ERROR_SCORE_COULDNT_BE_SAVED'));
			}
			else
			{
				CustomAlert.info(ResourceManager.getInstance().getString('myResources','INFO_SCORE_SUCCESSFULLY_SAVED'));
				//Update the exercise with the new information.
				DataModel.getInstance().userRatedExercise=true;
				//Retrieve the new avg score and push it in the exercise list
				var exNewData:ExerciseVO=data.result as ExerciseVO;
				for each (var exercise:ExerciseVO in DataModel.getInstance().availableExercises)
				{
					if (exNewData.id == exercise.id)
					{
						//Let the binding propagate the changes until it meets it's destination
						exercise.likes=exNewData.likes;
						exercise.dislikes=exNewData.dislikes;
						break;
					}
				}
				if (DataModel.getInstance().currentExercise.getItemAt(DataModel.RECORDING_MODULE))
				{
					var currentRec:ExerciseVO=DataModel.getInstance().currentExercise.getItemAt(DataModel.RECORDING_MODULE) as ExerciseVO;
					if (exNewData.id == currentRec.id)
					{
						currentRec.likes=exNewData.likes;
						currentRec.dislikes=exNewData.dislikes;
						DataModel.getInstance().currentExercise.setItemAt(currentRec, DataModel.RECORDING_MODULE);
					}
				}
				if (DataModel.getInstance().currentExercise.getItemAt(DataModel.SUBMODULE))
				{
					var currentSub:ExerciseVO=DataModel.getInstance().currentExercise.getItemAt(DataModel.SUBMODULE) as ExerciseVO;
					if (exNewData.id == currentSub.id)
					{
						currentSub.likes=exNewData.likes;
						currentSub.dislikes=exNewData.dislikes;
						DataModel.getInstance().currentExercise.setItemAt(currentSub, DataModel.SUBMODULE);
					}
				}
			}
		}

		public function fault(info:Object):void
		{
			var faultEvent:FaultEvent=FaultEvent(info);
			CustomAlert.error(ResourceManager.getInstance().getString('myResources','ERROR_WHILE_RATING'));
			trace(ObjectUtil.toString(faultEvent));
		}
	}
}