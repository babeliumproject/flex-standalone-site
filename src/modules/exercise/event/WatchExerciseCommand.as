package modules.exercise.event
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import control.URLManager;
	
	import model.DataModel;
	
	import mx.collections.ArrayCollection;

	public class WatchExerciseCommand implements ICommand
	{

		public function execute(event:CairngormEvent):void
		{
			var selectedEx:Object = (event as ExerciseEvent).params;
			var recModuleCurrentExerciseRetr:Boolean = DataModel.getInstance().currentExerciseRetrieved.getItemAt(DataModel.RECORDING_MODULE);
			DataModel.getInstance().currentExercise.setItemAt(selectedEx, 0);
			DataModel.getInstance().currentExerciseRetrieved = new ArrayCollection(new Array(true, recModuleCurrentExerciseRetr));
			//new ViewChangeEvent(ViewChangeEvent.VIEW_SUBEDITOR).dispatch();
			URLManager.getInstance().redirect('/subtitle/view/'+selectedEx.exercisecode);
		}
		
	}
}