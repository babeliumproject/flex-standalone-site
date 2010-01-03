package commands.exercises
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import model.DataModel;

	public class ViewExerciseEvaluationOptionsCommand implements ICommand
	{

		public function execute(event:CairngormEvent):void
		{
			DataModel.getInstance().viewExerciseViewStackIndex = 1;
		}
		
	}
}