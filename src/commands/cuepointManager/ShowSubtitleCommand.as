package commands.cuepointManager
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import mx.controls.Text;
	
	import vo.CueObject;

	public class ShowSubtitleCommand implements ICommand
	{
		private var subHolder:Text;
		private var text:String;
		
		public function ShowSubtitleCommand(text:String, subHolder:Text)
		{
			this.subHolder = subHolder;
			this.text = text;
		}

		public function execute(event:CairngormEvent):void
		{
			subHolder.text = text;
		}	
	}
}