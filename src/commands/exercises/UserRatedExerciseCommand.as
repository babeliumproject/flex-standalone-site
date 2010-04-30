package commands.exercises
{
	import business.ExerciseDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import events.ExerciseEvent;
	
	import model.DataModel;
	
	import mx.controls.Alert;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ObjectUtil;
	
	public class UserRatedExerciseCommand implements ICommand, IResponder
	{
		
		public function execute(event:CairngormEvent):void
		{
			new ExerciseDelegate(this).userRatedExercise((event as ExerciseEvent).score);
		}
		
		public function result(data:Object):void
		{
			var ratedToday:Boolean=data.result as Boolean;
			
			//If the user has rated the exercise today this will be true and else false.
			DataModel.getInstance().userRatedExercise = ratedToday;
			DataModel.getInstance().userRatedExerciseFlag = !DataModel.getInstance().userRatedExerciseFlag;
		}
		
		public function fault(info:Object):void
		{
			var fault:FaultEvent=FaultEvent(info);
			Alert.show("Error while checking if you've rated this exercise.");
			trace(ObjectUtil.toString(fault));
		}
	}
}