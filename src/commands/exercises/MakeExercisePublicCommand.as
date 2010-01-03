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

	public class MakeExercisePublicCommand implements ICommand, IResponder
	{

		public function execute(event:CairngormEvent):void
		{
			new ExerciseDelegate(this).makePublic((event as ExerciseEvent).exercise.id);
		}
		
		public function result(data:Object):void {

		}

		public function fault(info:Object):void {
			var faultEvent:FaultEvent = FaultEvent(info);
			Alert.show("Error: " + faultEvent.message);
			trace(ObjectUtil.toString(info));
		}
		
	}
}