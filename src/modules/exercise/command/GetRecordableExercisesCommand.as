package modules.exercise.command
{
	import business.ExerciseDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import model.DataModel;
	
	import modules.exercise.event.ExerciseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.resources.ResourceManager;
	import mx.rpc.IResponder;
	import mx.utils.ArrayUtil;
	import mx.utils.ObjectUtil;
	
	import view.common.CustomAlert;
	
	import vo.ExerciseVO;
	
	public class GetRecordableExercisesCommand implements ICommand, IResponder
	{
		private var dataModel:DataModel = DataModel.getInstance();
		
		public function execute(event:CairngormEvent):void
		{
			var params:Object=(event as ExerciseEvent).params;
			new ExerciseDelegate(this).getRecordableExercises(params);
		}
		
		public function result(data:Object):void
		{
			var result:Object=data.result;
			var resultCollection:ArrayCollection;
			
			if (result is Array)
			{
				resultCollection=new ArrayCollection(ArrayUtil.toArray(result));
				//Set the data to the application's model
				dataModel.availableRecordableExercises=resultCollection;
				//Reflect the visual changes
			} else {
				dataModel.availableRecordableExercises.removeAll();
			}
			//dataModel.availableExercisesRetrieved.setItemAt(!dataModel.availableExercisesRetrieved.getItemAt(DataModel.RECORDING_MODULE), DataModel.RECORDING_MODULE);
			dataModel.availableRecordableExercisesRetrieved = !dataModel.availableRecordableExercisesRetrieved;
		}
		
		public function fault(info:Object):void
		{
			CustomAlert.error(ResourceManager.getInstance().getString('myResources','ERROR_WHILE_RETRIEVING_EXERCISES'));
			trace(ObjectUtil.toString(info));
		}
	}
}