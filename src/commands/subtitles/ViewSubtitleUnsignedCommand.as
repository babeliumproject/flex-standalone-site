package commands.subtitles
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import model.DataModel;
	
	public class ViewSubtitleUnsignedCommand implements ICommand
	{
		
		public function execute(event:CairngormEvent):void
		{
			DataModel.getInstance().currentSubtitleViewStackIndex = 0;
		}
	}
}