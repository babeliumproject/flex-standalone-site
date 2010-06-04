package commands.userManagement
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import control.BabeliaBrowserManager;
	
	import events.ViewChangeEvent;
	
	import model.DataModel;

	public class ViewRegisterModuleCommand implements ICommand
	{
		public function ViewRegisterModuleCommand()
		{
		}

		public function execute(event:CairngormEvent):void
		{
			var index:int = ViewChangeEvent.VIEWSTACK_REGISTER_MODULE_INDEX;
			DataModel.getInstance().currentContentViewStackIndex = index;
			
			
			BabeliaBrowserManager.getInstance().updateURL(
				BabeliaBrowserManager.index2fragment(index));
			
			DataModel.getInstance().registrationErrorMessage = "";
		}
		
	}
}