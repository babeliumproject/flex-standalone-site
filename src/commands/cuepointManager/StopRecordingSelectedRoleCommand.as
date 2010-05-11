package commands.cuepointManager
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import model.DataModel;
	
	import modules.videoPlayer.VideoPlayerBabelia;
	import modules.videoPlayer.events.babelia.RecordingEvent;
	
	import mx.controls.Alert;

	public class StopRecordingSelectedRoleCommand implements ICommand
	{
		private var VP:VideoPlayerBabelia;
		
		public function StopRecordingSelectedRoleCommand(VP:VideoPlayerBabelia)
		{
			this.VP = VP;
		}
		
		public function execute(event:CairngormEvent):void
		{
			VP.setSubtitle("");
			VP.muteVideo(false);
			VP.muteRecording(true);
			/*
			if(!DataModel.getInstance().soundDetected &&
				DataModel.getInstance().gapsWithNoSound > DataModel.GAPS_TO_ABORT_RECORDING){
				DataModel.getInstance().gapsWithNoSound = 0;
				VP.dispatchEvent(new RecordingEvent(RecordingEvent.ABORTED));
			}*/
		}	
	}
}