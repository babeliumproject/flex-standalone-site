package commands.cuepointManager
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import modules.videoPlayer.VideoPlayerBabelia;
	
	import vo.CueObject;

	public class ShowHideSubtitleCommand implements ICommand
	{
		private var VP:VideoPlayerBabelia;
		public var cue:CueObject;
		
		public function ShowHideSubtitleCommand(cue:CueObject, subHolder:VideoPlayerBabelia)
		{
			this.VP = subHolder;
			this.cue = cue;
		}

		public function execute(event:CairngormEvent):void
		{
			if(cue)
				VP.setSubtitle(cue.text);
			else
				VP.setSubtitle('');
		}	
	}
}