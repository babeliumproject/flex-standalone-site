package modules.exercise.command
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import modules.exercise.event.ExerciseEvent;
	
	import model.DataModel;
	import vo.ExerciseVO;

	public class ExerciseSelectedCommand implements ICommand
	{

		public function execute(event:CairngormEvent):void
		{
			var selectedEx:ExerciseVO = (event as ExerciseEvent).exercise;
			DataModel.getInstance().currentExercise.setItemAt(selectedEx, 1);
			DataModel.getInstance().currentExerciseRetrieved.setItemAt(true, 1);
		}
		
	}
}