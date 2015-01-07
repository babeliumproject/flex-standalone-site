package commands.cuepointManager
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import components.videoPlayer.VideoRecorder;
	
	import mx.controls.DataGrid;
	
	import vo.CueObject;

	public class ShowHideSubtitleCommand implements ICommand
	{
		private var VP:VideoRecorder;
		private var dg:DataGrid;
		public var cue:CueObject;

		public function ShowHideSubtitleCommand(cue:CueObject, subHolder:VideoRecorder, dg:DataGrid=null)
		{
			this.VP=subHolder;
			this.dg=dg;
			this.cue=cue;
		}

		public function execute(event:CairngormEvent):void
		{
			if (cue)
			{
				VP.showCaption({'text':cue.text,'color':cue.textColor});
				var index:int = (dg as Object).getCueIndex(cue);
				if(dg != null && dg.rowCount > index)
					dg.selectedIndex = index;
			}
			else
			{
				VP.hideCaption();
			}
		}
	}
}