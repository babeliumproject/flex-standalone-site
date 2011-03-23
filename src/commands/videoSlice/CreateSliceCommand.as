package commands.videoSlice
{
	import business.YouTubeDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import model.DataModel;
	
	import mx.controls.Alert;
	import mx.resources.ResourceManager;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ObjectUtil;
	
	import view.common.CustomAlert;
	
	import vo.ExerciseVO;
	import vo.VideoSliceVO;
	
	public class CreateSliceCommand implements ICommand, IResponder
	{
		
		public function execute(event:CairngormEvent):void
		{
			var tempSlice:VideoSliceVO = DataModel.getInstance().tempVideoSlice;
			var tempEx:ExerciseVO = DataModel.getInstance().tempExercise;
			new YouTubeDelegate(this).insertVideoSlice(tempSlice, tempEx);		
		}
		
		public function result(data:Object):void
		{
			var result:Boolean = data.result as Boolean;
			if (result){
				CustomAlert.info(ResourceManager.getInstance().getString('myResources','SLICEEND_TEXT'));
				DataModel.getInstance().sliceComplete = true;
			}else{
				CustomAlert.error(ResourceManager.getInstance().getString('myResources','SLICEABORT_TEXT'));
				DataModel.getInstance().sliceComplete = true;
			}	
		}
		
		public function fault(info:Object):void
		{
			var faultEvent:FaultEvent=FaultEvent(info);
			Alert.show("Error while retrieving slice:" + faultEvent.message);
			trace(ObjectUtil.toString(info));
		}
		
	}
}