package modules.exercise.event
{
	import business.ExerciseDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import model.DataModel;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.resources.ResourceManager;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ArrayUtil;
	import mx.utils.ObjectUtil;
	
	import view.common.CustomAlert;
	
	import vo.ExerciseVO;

	public class GetExercisesCommand implements ICommand, IResponder
	{

		public function execute(event:CairngormEvent):void
		{
			new ExerciseDelegate(this).getExercises();
		}
		
		public function result(data:Object):void
		{
			var result:Object=data.result;
			var resultCollection:ArrayCollection;

			if (result is Array)
			{
				resultCollection=new ArrayCollection(ArrayUtil.toArray(result));

				if (!(resultCollection[0] is ExerciseVO))
				{
					CustomAlert.error(ResourceManager.getInstance().getString('myResources','ERROR_WHILE_RETRIEVING_EXERCISES'));
				}
				else
				{
					//Set the data to the application's model
					DataModel.getInstance().availableExercises=resultCollection;
					//Reflect the visual changes
					DataModel.getInstance().availableExercisesRetrieved.setItemAt(true, DataModel.SUBMODULE);
					DataModel.getInstance().availableExercisesRetrieved.setItemAt(true, DataModel.RECORDING_MODULE);
				}
			} else {
				DataModel.getInstance().availableExercises.removeAll();
				DataModel.getInstance().availableExercisesRetrieved.setItemAt(true, DataModel.SUBMODULE);
				DataModel.getInstance().availableExercisesRetrieved.setItemAt(true, DataModel.RECORDING_MODULE);
			}
			
			
		}
		
		public function fault(info:Object):void
		{
			var faultEvent:FaultEvent = FaultEvent(info);
			CustomAlert.error(ResourceManager.getInstance().getString('myResources','ERROR_WHILE_RETRIEVING_EXERCISES'));
			trace(ObjectUtil.toString(info));
		}
		
	}
}