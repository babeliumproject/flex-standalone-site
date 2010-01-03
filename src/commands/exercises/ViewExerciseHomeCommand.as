package commands.exercises
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import model.DataModel;

	public class ViewExerciseHomeCommand implements ICommand
	{

		public function execute(event:CairngormEvent):void
		{
			DataModel.getInstance().viewExerciseViewStackIndex = 0;
		}
		
	}
}