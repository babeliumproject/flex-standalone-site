package commands.exercises
{
	import business.ExerciseDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import events.ExerciseEvent;
	
	import mx.controls.Alert;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ObjectUtil;
	
	public class RateExerciseCommand implements ICommand, IResponder
	{
		
		public function execute(event:CairngormEvent):void
		{
			new ExerciseDelegate(this).addExerciseScore((event as ExerciseEvent).score);
		}
		
		public function result(data:Object):void
		{
			//Should be the id of the added rate
			if (!data.result is int){
				Alert.show("Your score couldn't be saved.");
			} else {
				Alert.show("Your score has been successfully saved. Thank you.");
				//Update the exercise with the new information.
				//Maybe leave it as it is, so that the user doesn't know the weight of his rating.
				
			}
		}
		
		public function fault(info:Object):void
		{
			var faultEvent:FaultEvent=FaultEvent(info);
			Alert.show("Error while rating the exercise.\n");
			trace(ObjectUtil.toString(faultEvent));
		}
	}
}