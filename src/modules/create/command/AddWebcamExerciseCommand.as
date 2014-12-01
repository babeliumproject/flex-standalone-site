package modules.create.command
{
	import business.ExerciseDelegate;

	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;

	import events.CreditEvent;
	import modules.exercise.event.ExerciseEvent;

	import model.DataModel;

	import mx.resources.ResourceManager;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;

	import view.common.CustomAlert;

	import vo.UserVO;

	public class AddWebcamExerciseCommand implements ICommand, IResponder
	{

		public function execute(event:CairngormEvent):void
		{
			new ExerciseDelegate(this).addWebcamExercise((event as ExerciseEvent).exercise);
		}

		public function result(data:Object):void
		{
			var result:Object=data.result;
			if (!result is UserVO)
			{
				CustomAlert.error(ResourceManager.getInstance().getString('myResources','ERROR_WHILE_SAVING_EXERCISE_DATA'));
			}
			else
			{
				CustomAlert.info(ResourceManager.getInstance().getString('myResources', 'ALERT_SUCCESSFUL_WEBCAM_UPLOAD_RED5'));
				var userData:UserVO=result as UserVO;
				DataModel.getInstance().loggedUser.creditCount=userData.creditCount;
				DataModel.getInstance().unprocessedExerciseSaved=true;
				DataModel.getInstance().creditUpdateRetrieved=true;
			}
		}

		public function fault(info:Object):void
		{
			var faultEvent:FaultEvent=FaultEvent(info);
			CustomAlert.error(ResourceManager.getInstance().getString('myResources','ERROR_WHILE_SAVING_EXERCISE_DATA'));
			trace(faultEvent.toString());
		}
	}
}