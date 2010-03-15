package commands.main
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import events.ExerciseEvent;
	import events.ViewChangeEvent;
	
	import model.DataModel;
	
	import mx.controls.Alert;
	import mx.utils.ObjectUtil;
	
	import vo.ExerciseVO;

	public class WatchExerciseCommand implements ICommand
	{

		public function execute(event:CairngormEvent):void
		{
			var selectedEx:ExerciseVO = (event as ExerciseEvent).exercise;
			DataModel.getInstance().currentExercise.setItemAt(selectedEx, 0);
			DataModel.getInstance().currentExerciseRetrieved.setItemAt(true, 0);
			new ViewChangeEvent(ViewChangeEvent.VIEW_PLAYER_MODULE).dispatch();
		}
		
	}
}