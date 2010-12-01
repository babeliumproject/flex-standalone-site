package commands.search
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import control.BabeliaBrowserManager;
	
	import events.CloseConnectionEvent;
	import events.ViewChangeEvent;
	
	import model.DataModel;
	
	import modules.search.Search;
	
	import spark.components.Group;
	import spark.components.SkinnableContainer;
	
	public class ViewSearchModuleCommand implements ICommand
	{
		
		public function execute(event:CairngormEvent):void
		{
			var index:uint = ViewChangeEvent.VIEWSTACK_SEARCH_MODULE_INDEX;
			DataModel.getInstance().currentContentViewStackIndex = index;
			
			
			BabeliaBrowserManager.getInstance().updateURL(
				BabeliaBrowserManager.index2fragment(index));
		}

	}
}