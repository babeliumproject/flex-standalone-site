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
	
	import vo.ExerciseReportVO;

	public class UserReportedExerciseCommand implements ICommand, IResponder
	{

		public function execute(event:CairngormEvent):void
		{
			var report:ExerciseReportVO=(event as ExerciseEvent).params as ExerciseReportVO;
			new ExerciseDelegate(this).userReportedExercise(report);
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
			CustomAlert.error(ResourceManager.getInstance().getString('myResources','ERROR_WHILE_CHECKING_ALREADY_REPORTED'));
			trace(ObjectUtil.toString(fault));
		}
	}
}