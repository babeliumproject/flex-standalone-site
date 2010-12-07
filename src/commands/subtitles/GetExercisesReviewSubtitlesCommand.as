package commands.subtitles
{
	import business.ExerciseDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import model.DataModel;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ArrayUtil;
	import mx.utils.ObjectUtil;
	
	import view.common.CustomAlert;
	
	import vo.ExerciseVO;
	
	public class GetExercisesReviewSubtitlesCommand implements ICommand, IResponder
	{
		
		private var _dataModel : DataModel = DataModel.getInstance();
		
		public function execute(event:CairngormEvent):void
		{
			new ExerciseDelegate(this).getExercisesToReviewSubtitles();
		}
		
		public function result(data:Object):void
		{
			var result:Object=data.result;
			var resultCollection:ArrayCollection;
			
			if (result is Array && (result as Array).length > 0)
			{
				resultCollection=new ArrayCollection(ArrayUtil.toArray(result));
				
				if (!(resultCollection[0] is ExerciseVO))
				{
					CustomAlert.error("The Result is not a well-formed object.");
				}
				else
				{
					//Set the data to the application's model
					_dataModel.exercisesWithSubtitlesToReview = resultCollection;
					
				}
			} else {
				_dataModel.exercisesWithSubtitlesToReview.removeAll();
			}
			_dataModel.exercisesWithSubtitlesToReviewRetrieved = ! _dataModel.exercisesWithSubtitlesToReviewRetrieved;
		}
		
		public function fault(info:Object):void
		{
			var faultEvent:FaultEvent = FaultEvent(info);
			CustomAlert.error("Error while retrieving exercises with subtitles to review.");
			trace(ObjectUtil.toString(info));
		}
	}
}