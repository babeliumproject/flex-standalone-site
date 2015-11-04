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
	
	public class ExerciseSelectedCommand implements ICommand, IResponder
	{
		
		private var dmodel:DataModel=DataModel.getInstance();
		
		public function execute(event:CairngormEvent):void
		{
			var exercisehash:String = (event as ExerciseEvent).params.exercisecode;
			new ExerciseDelegate(this).watchExercise(exercisehash);
		}
		
		public function result(data:Object):void{
		
			var result:Object=data.result;
			
			if (result)
			{
				dmodel.watchExerciseData=result;
				dmodel.watchExerciseDataRetrieved=!dmodel.watchExerciseDataRetrieved;
			} else {
				//The exercise was not found or you don't have permission to see the requested exercise
			}
			
			
		}
		
		public function fault(info:Object):void{
			var faultEvent:FaultEvent = FaultEvent(info);
			CustomAlert.error(ResourceManager.getInstance().getString('myResources','ERROR_WHILE_RETRIEVING_EXERCISES'));
			trace(ObjectUtil.toString(info));
		}
	}
}