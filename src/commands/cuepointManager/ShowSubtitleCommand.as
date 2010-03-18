package commands.cuepointManager
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import modules.videoPlayer.VideoPlayerBabelia;

	public class ShowSubtitleCommand implements ICommand
	{
		private var subHolder:VideoPlayerBabelia;
		private var text:String;
		
		public function ShowSubtitleCommand(text:String, subHolder:VideoPlayerBabelia)
		{
			this.subHolder = subHolder;
			this.text = text;
		}

		public function execute(event:CairngormEvent):void
		{
			subHolder.setSubtitle(text);
		}	
	}
}