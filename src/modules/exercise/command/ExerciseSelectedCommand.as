package modules.exercise.command
{
	import business.ExerciseDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import model.DataModel;
	
	import modules.exercise.event.ExerciseEvent;
	
	import mx.resources.ResourceManager;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ObjectUtil;
	
	import view.common.CustomAlert;
	
	import vo.ExerciseVO;

	public class ExerciseSelectedCommand implements ICommand, IResponder
	{
		
		public function execute(event:CairngormEvent):void
		{
			var exercisehash:String = (event as ExerciseEvent).exercise.name;
			new ExerciseDelegate(this).watchExercise(exercisehash);
		}
		
		public function result(data:Object):void{
		
			var result:Object=data.result;
			
			if (result)
			{
				DataModel.getInstance().currentExercise.setItemAt(result, 1);
				DataModel.getInstance().currentExerciseRetrieved.setItemAt(true,1);
				trace(ObjectUtil.toString(result));
				//DataModel.getInstance().currentExercise.setItemAt(selectedEx, 1);
				//DataModel.getInstance().currentExerciseRetrieved.setItemAt(true, 1);
			} else {
				//The exercise was not found or you don't have permission to see the requested exercise
			}
			
			
		}
		
		public function fault(info:Object):void{
			var faultEvent:FaultEvent = FaultEvent(info);
			CustomAlert.error(ResourceManager.getInstance().getString('myResources','ERROR_WHILE_RETRIEVING_EXERCISES'));
			trace(ObjectUtil.toString(info));
		}

		//public function execute(event:CairngormEvent):void
		//{
		//	var selectedEx:ExerciseVO = (event as ExerciseEvent).exercise;
		//	
		//}
		
	}
}