package modules.assessment.command
{
	import business.EvaluationDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import control.URLManager;
	
	import events.CreditEvent;
	
	import model.DataModel;
	
	import modules.assessment.event.EvaluationEvent;
	
	import mx.resources.ResourceManager;
	import mx.rpc.IResponder;
	import mx.utils.ObjectUtil;
	
	import view.common.CustomAlert;
	
	import vo.UserVO;

	public class AddAssessmentCommand implements ICommand, IResponder
	{
		private var dataModel:DataModel=DataModel.getInstance();

		public function execute(event:CairngormEvent):void
		{
			new EvaluationDelegate(this).addAssessment((event as EvaluationEvent).evaluation);
		}

		public function result(data:Object):void
		{

			var result:Object=data.result;
			if (!result || !(result is UserVO))
			{
				CustomAlert.error(ResourceManager.getInstance().getString('myResources','YOUR_ASSESSMENT_COULDNT_BE_SAVE'));
			}
			else //Assessment successfully saved, redirect to pending list
			{
				var userData:UserVO=result as UserVO;
				dataModel.loggedUser.creditCount=userData.creditCount;
				CustomAlert.info(ResourceManager.getInstance().getString('myResources','YOUR_ASSESSMENT_HAS_BEEN_SAVED'));
				dataModel.addAssessmentRetrieved=!dataModel.addAssessmentRetrieved;
				dataModel.creditUpdateRetrieved=true;
				URLManager.getInstance().redirect('/assessments/pending');
			}
		}

		public function fault(info:Object):void
		{
			trace(ObjectUtil.toString(info));
			CustomAlert.error(ResourceManager.getInstance().getString('myResources','ERROR_WHILE_SAVING_YOUR_ASSESSMENT'));
		}
	}
}