package commands.main
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import events.ViewChangeEvent;
	
	import model.DataModel;

	public class ViewRankingModuleCommand implements ICommand
	{

		public function execute(event:CairngormEvent):void
		{
			//DataModel.getInstance().viewContentViewStackIndex =
			//		ViewChangeEvent.VIEWSTACK_RANKING_MODULE_INDEX;
		}
		
	}
}