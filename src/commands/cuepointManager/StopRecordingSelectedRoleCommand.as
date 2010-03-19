package commands.cuepointManager
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import modules.videoPlayer.VideoPlayerBabelia;

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
		}	
	}
}