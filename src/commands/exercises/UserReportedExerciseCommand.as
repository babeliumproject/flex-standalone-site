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

	public class UserReportedExerciseCommand implements ICommand, IResponder
	{

		public function execute(event:CairngormEvent):void
		{
			new ExerciseDelegate(this).userReportedExercise((event as ExerciseEvent).report);
		}

		public function result(data:Object):void
		{
			var reported:Boolean=data.result as Boolean;
			
			DataModel.getInstance().userReportedExercise = reported;
			DataModel.getInstance().userReportedExerciseFlag = !DataModel.getInstance().userReportedExerciseFlag;
		}

		public function fault(info:Object):void
		{
			var fault:FaultEvent=FaultEvent(info);
			Alert.show("Error while checking if you've reported this exercise.");
			trace(ObjectUtil.toString(fault));
		}
	}
}