package commands.evaluation
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import control.BabeliaBrowserManager;
	
	import events.CloseConnectionEvent;
	import events.ViewChangeEvent;
	
	import flash.display.DisplayObject;
	
	import model.DataModel;
	
	import modules.evaluation.EvaluationContainer;

	public class ViewEvaluationModuleCommand implements ICommand
	{

		public function execute(event:CairngormEvent):void
		{
			var index:Class = ViewChangeEvent.VIEWSTACK_EVALUATION_MODULE_INDEX;
			new CloseConnectionEvent().dispatch();
			if(DataModel.getInstance().appBody.getChildren().length > 0)
				DataModel.getInstance().appBody.removeAllChildren();
			DataModel.getInstance().appBody.addChild(new index());
			
			
			BabeliaBrowserManager.getInstance().updateURL(
				BabeliaBrowserManager.index2fragment(index));
		}
		
	}
}