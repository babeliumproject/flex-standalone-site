package commands.cuepointManager
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import modules.videoPlayer.VideoPlayerBabelia;
	
	import mx.controls.Alert;

	public class StartRecordingSelectedRoleCommand implements ICommand
	{
		private var VP:VideoPlayerBabelia;
		private var text:String;
		private var role:String;
		private var time:Number;
		
		public function StartRecordingSelectedRoleCommand(text:String, role:String, time:Number, VP:VideoPlayerBabelia)
		{
			this.VP = VP;
			this.text = text;
			this.role = role;
			this.time = time;
		}
		
		public function execute(event:CairngormEvent):void
		{
			VP.setSubtitle(text);
			TODO Problems: VP.muteVideo(true);
			VP.muteRecording(false);
			VP.startTalking(role, time);
		}		
	}
}