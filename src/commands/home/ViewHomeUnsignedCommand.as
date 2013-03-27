package commands.home
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import model.DataModel;
	
	public class ViewHomeUnsignedCommand implements ICommand
	{
		public function ViewHomeUnsignedCommand()
		{
		}
		
		public function execute(event:CairngormEvent):void
		{
			DataModel.getInstance().currentHomeViewStackIndex = 0;
		}
	}
}