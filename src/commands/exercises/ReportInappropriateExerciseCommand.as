package commands.exercises
{
	import business.ExerciseDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import events.ExerciseEvent;
	
	import model.DataModel;
	
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ObjectUtil;
	
	import view.common.CustomAlert;
	
	public class ReportInappropriateExerciseCommand implements ICommand, IResponder
	{
		
		public function execute(event:CairngormEvent):void
		{
			new ExerciseDelegate(this).addInappropriateExerciseReport((event as ExerciseEvent).report);
		}
		
		public function result(data:Object):void
		{
			//Should be the id of the added rate
			if (!data.result is int){
				CustomAlert.error("Error while reporting inappropriate exercise.");
			} else if (data.result > 0){
				CustomAlert.info("Your report has been successfully saved. Thank you.");
				//Update the exercise with the new information.
				DataModel.getInstance().userReportedExercise = true;
			} else {
				CustomAlert.error("You already reported about this exercise.");
			}
		}
		
		public function fault(info:Object):void
		{
			var faultEvent:FaultEvent=FaultEvent(info);
			CustomAlert.error("Error while reporting inappropriate exercise.");
			trace(ObjectUtil.toString(faultEvent));
		}
	}
}