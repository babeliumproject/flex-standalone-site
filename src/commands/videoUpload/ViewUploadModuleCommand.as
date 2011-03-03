package commands.videoUpload
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import control.BabeliaBrowserManager;
	
	import events.CloseConnectionEvent;
	import events.ViewChangeEvent;
	
	import model.DataModel;
	
	import spark.components.Group;
	import spark.components.SkinnableContainer;

	public class ViewUploadModuleCommand implements ICommand
	{
		public function ViewUploadModuleCommand()
		{
		}

		public function execute(event:CairngormEvent):void
		{
			var index:uint = ViewChangeEvent.VIEWSTACK_UPLOAD_MODULE_INDEX;
			DataModel.getInstance().currentContentViewStackIndex = index;
			
			
			BabeliaBrowserManager.getInstance().updateURL(
				BabeliaBrowserManager.index2fragment(index));
		}
		
	}
}