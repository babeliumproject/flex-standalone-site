package commands.configuration
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import events.ViewChangeEvent;
	
	import model.DataModel;

	public class ViewConfigurationModuleCommand implements ICommand
	{

		public function execute(event:CairngormEvent):void
		{
			DataModel.getInstance().viewContentViewStackIndex =
					ViewChangeEvent.VIEWSTACK_CONFIGURATION_MODULE_INDEX;
		}
		
	}
}