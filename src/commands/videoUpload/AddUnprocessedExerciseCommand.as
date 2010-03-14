package commands.videoUpload
{
	import business.ExerciseDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import events.ExerciseEvent;
	
	import model.DataModel;
	
	import mx.controls.Alert;
	import mx.rpc.IResponder;

	public class AddUnprocessedExerciseCommand implements ICommand, IResponder
	{

		public function execute(event:CairngormEvent):void
		{
			new ExerciseDelegate(this).addUnprocessedExercise((event as ExerciseEvent).exercise);
		}
		
		public function result(data:Object):void
		{
			//Should be the id of the added exercise
			if (!data.result is int){
				Alert.show("Your exercise data could not be saved successfully");
			} else {
				DataModel.getInstance().unprocessedExerciseSaved = true;
			}
		}
		
		public function fault(info:Object):void
		{
		}
		
	}
}