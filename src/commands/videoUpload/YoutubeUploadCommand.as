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

	public class YoutubeUploadCommand implements ICommand, IResponder
	{

		public function execute(event:CairngormEvent):void
		{
			new YouTubeDelegate(this).directClientLoginUpload((event as UploadEvent).exercise);
		}
		
		public function result(data:Object):void
		{
			//The video was sucessfully transferred to Youtube.
			//Youtube's web service returns the video's unique
			//identifier, so that we can reference it later on.
			var videoId:String = data.result as String;
			
			//Create new exercise object to store the videoId 
			var tempEx:ExerciseVO = new ExerciseVO();
			tempEx.name = videoId;
			tempEx.thumbnailUri = DataModel.getInstance().youtubeThumbnailsUrl + videoId + "/1.jpg";
			DataModel.getInstance().newYoutubeData = tempEx;
			
			//Tell DataModel youtubeId has arrived, so that the
			//view can start the timed video status check
			DataModel.getInstance().youtubeTransferComplete = true;
			
		}
		
		public function fault(info:Object):void
		{
			var faultEvent:FaultEvent=FaultEvent(info);
			Alert.show("Error while transferring data to youtube:" + faultEvent.message);
			trace(ObjectUtil.toString(info));
		}
		
	}
}