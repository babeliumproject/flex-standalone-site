package commands.exercises
{
	import business.ExerciseDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import events.ExerciseEvent;
	
	import model.DataModel;
	
	import mx.controls.Alert;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ObjectUtil;
	
	import view.common.CustomAlert;
	
	import vo.ExerciseVO;

	public class RateExerciseCommand implements ICommand, IResponder
	{

		public function execute(event:CairngormEvent):void
		{
			new ExerciseDelegate(this).addExerciseScore((event as ExerciseEvent).score);
		}

		public function result(data:Object):void
		{
			//Should be the id of the added rate
			if (!data.result is ExerciseVO)
			{
				CustomAlert.error("Your score couldn't be saved.");
			}
			else
			{
				CustomAlert.info("Your score has been successfully saved. Thank you.");
				//Update the exercise with the new information.
				DataModel.getInstance().userRatedExercise=true;
				//Retrieve the new avg score and push it in the exercise list
				var exNewData:ExerciseVO=data.result as ExerciseVO;
				for each (var exercise:ExerciseVO in DataModel.getInstance().availableExercises)
				{
					if (exNewData.id == exercise.id)
					{
						//Let the binding propagate the changes until it meets it's destination
						exercise.avgRating=exNewData.avgRating;
						break;
					}
				}
				if (DataModel.getInstance().currentExercise.getItemAt(DataModel.RECORDING_MODULE))
				{
					var currentRec:ExerciseVO=DataModel.getInstance().currentExercise.getItemAt(DataModel.RECORDING_MODULE) as ExerciseVO;
					if (exNewData.id == currentRec.id)
					{
						currentRec.avgRating=exNewData.avgRating;
						DataModel.getInstance().currentExercise.setItemAt(currentRec, DataModel.RECORDING_MODULE);
					}
				}
				if (DataModel.getInstance().currentExercise.getItemAt(DataModel.SUBTITLE_MODULE))
				{
					var currentSub:ExerciseVO=DataModel.getInstance().currentExercise.getItemAt(DataModel.SUBTITLE_MODULE) as ExerciseVO;
					if (exNewData.id == currentSub.id)
					{
						currentSub.avgRating=exNewData.avgRating;
						DataModel.getInstance().currentExercise.setItemAt(currentSub, DataModel.SUBTITLE_MODULE);
					}
				}
			}
		}

		public function fault(info:Object):void
		{
			var faultEvent:FaultEvent=FaultEvent(info);
			CustomAlert.error("Error while rating the exercise.");
			trace(ObjectUtil.toString(faultEvent));
		}
	}
}