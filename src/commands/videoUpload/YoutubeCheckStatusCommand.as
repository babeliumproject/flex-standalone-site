package commands.videoUpload
{
	import business.YouTubeDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import events.UploadEvent;
	
	import model.DataModel;
	
	import mx.controls.Alert;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ObjectUtil;
	
	import vo.ExerciseVO;

	public class YoutubeCheckStatusCommand implements ICommand, IResponder
	{

		public function execute(event:CairngormEvent):void
		{
			new YouTubeDelegate(this).checkUploadedVideoStatus((event as UploadEvent).exercise);
		}
		
		public function result(data:Object):void
		{
			var message:String=data.result as String;
			//Video is likely to be live now, change the upload status
			if (message == 'No further status information available yet.')
				DataModel.getInstance().youtubeProcessingComplete = true;
			else {
				DataModel.getInstance().youtubeProcessMessage = message;
				DataModel.getInstance().youtubeProcessUpdate = true;
			}
		}
		
		public function fault(info:Object):void
		{
			var faultEvent:FaultEvent=FaultEvent(info);
			Alert.show("Error while retrieving video status:" + faultEvent.message);
			trace(ObjectUtil.toString(info));
		}
		
	}
}