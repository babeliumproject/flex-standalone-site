package commands.exercises
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import events.ViewChangeEvent;
	
	import model.DataModel;

	public class ViewExerciseModuleCommand implements ICommand
	{

		public function execute(event:CairngormEvent):void
		{
			DataModel.getInstance().viewContentViewStackIndex =
					ViewChangeEvent.VIEWSTACK_EXERCISE_MODULE_INDEX;
		}
		
	}
}