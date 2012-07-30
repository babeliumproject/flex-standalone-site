package commands.userManagement
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import model.DataModel;

	public class ViewAccountSignedCommand implements ICommand
	{
		public function execute(event:CairngormEvent):void
		{
			DataModel.getInstance().currentAccountViewStackIndex = 1;
		}
	}
}