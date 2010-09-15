package commands.main
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import events.ExerciseEvent;
	import events.ViewChangeEvent;
	
	import model.DataModel;
	
	import mx.collections.ArrayCollection;
	
	import vo.ExerciseVO;

	public class WatchExerciseCommand implements ICommand
	{

		public function execute(event:CairngormEvent):void
		{
			var selectedEx:ExerciseVO = (event as ExerciseEvent).exercise;
			var recModuleCurrentExerciseRetr:Boolean = DataModel.getInstance().currentExerciseRetrieved.getItemAt(DataModel.RECORDING_MODULE);
			DataModel.getInstance().currentExercise.setItemAt(selectedEx, 0);
			DataModel.getInstance().currentExerciseRetrieved = new ArrayCollection(new Array(true, recModuleCurrentExerciseRetr));
			new ViewChangeEvent(ViewChangeEvent.VIEW_SUBTITLE_MODULE).dispatch();
		}
		
	}
}