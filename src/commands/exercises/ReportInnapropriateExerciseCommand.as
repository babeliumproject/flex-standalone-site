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
	
	public class ReportInnapropriateExerciseCommand implements ICommand, IResponder
	{
		
		public function execute(event:CairngormEvent):void
		{
			new ExerciseDelegate(this).addInnapropriateExerciseReport((event as ExerciseEvent).report);
		}
		
		public function result(data:Object):void
		{
			//Should be the id of the added report
			if (!data.result is int){
				Alert.show("Your report has been successfully noted. Thank you.");
			} else {
				
			}
		}
		
		public function fault(info:Object):void
		{
			var faultEvent:FaultEvent=FaultEvent(info);
			Alert.show("Error while reporting innapropriate exercise.\n");
			trace(ObjectUtil.toString(faultEvent));
		}
	}
}