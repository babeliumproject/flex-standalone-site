package commands.home
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import control.BabeliaBrowserManager;
	
	import events.CloseConnectionEvent;
	import events.ViewChangeEvent;
	
	import model.DataModel;

	public class ViewHomeModuleCommand implements ICommand
	{

		public function execute(event:CairngormEvent):void
		{
			var index:Class = ViewChangeEvent.VIEWSTACK_HOME_MODULE_INDEX;
			new CloseConnectionEvent().dispatch();
			if(DataModel.getInstance().appBody.getChildren().length > 0)
				DataModel.getInstance().appBody.removeAllChildren();
			DataModel.getInstance().appBody.addChild(new index());
			
			
			BabeliaBrowserManager.getInstance().updateURL(
				BabeliaBrowserManager.index2fragment(index));
		}
		
	}
}