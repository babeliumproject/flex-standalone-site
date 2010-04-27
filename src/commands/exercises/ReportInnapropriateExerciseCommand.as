package commands.exercises
{
	import business.ExerciseDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import events.ExerciseEvent;
	
	import mx.rpc.IResponder;
	
	public class ReportInnapropriateExerciseCommand implements ICommand, IResponder
	{
		
		public function execute(event:CairngormEvent):void
		{
			new ExerciseDelegate(this).reportInnapropriateExercise((event as ExerciseEvent).report);
		}
		
		public function result(data:Object):void
		{
		}
		
		public function fault(info:Object):void
		{
		}
	}
}