package commands.home
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import control.BabeliaBrowserManager;
	
	import events.ViewChangeEvent;
	
	import model.DataModel;

	public class ViewHomeModuleCommand implements ICommand
	{

		public function execute(event:CairngormEvent):void
		{
			var index:int = ViewChangeEvent.VIEWSTACK_HOME_MODULE_INDEX;
			DataModel.getInstance().currentContentViewStackIndex = index;
			
			
			BabeliaBrowserManager.getInstance().updateURL(
				BabeliaBrowserManager.index2fragment(index));
		}
		
	}
}