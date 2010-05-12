package commands.evaluation
{
	import business.EvaluationDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import events.EvaluationEvent;
	
	import model.DataModel;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.IResponder;
	import mx.utils.ArrayUtil;
	import mx.utils.ObjectUtil;
	
	import view.common.CustomAlert;
	
	public class GetResponsesAssessedToCurrentUserCommand implements ICommand, IResponder
	{
		private var dataModel:DataModel = DataModel.getInstance();
		
		public function execute(event:CairngormEvent):void
		{
			new EvaluationDelegate(this).getResponsesAssessedToCurrentUser((event as EvaluationEvent).userId);
		}
		
		public function result(data:Object):void
		{
			var result:Object=data.result;
			var resultCollection:ArrayCollection;
			
			if (result is Array && (result as Array).length > 0 )
			{
				resultCollection=new ArrayCollection(ArrayUtil.toArray(result));
				//Set the data in the application's model
				dataModel.assessedToCurrentUserData = resultCollection;
			} else {
				dataModel.assessedToCurrentUserData = new ArrayCollection();
			}
			dataModel.assessedToCurrentUserDataRetrieved = !dataModel.assessedToCurrentUserDataRetrieved;
		}
		
		public function fault(info:Object):void
		{
			trace(ObjectUtil.toString(info));
			CustomAlert.error("Error while retrieving your responses that have been assessed by other users.");
		}
	}
}