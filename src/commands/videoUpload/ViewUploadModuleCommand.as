package commands.videoUpload
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import events.ViewChangeEvent;
	
	import model.DataModel;

	public class ViewUploadModuleCommand implements ICommand
	{
		public function ViewUploadModuleCommand()
		{
		}

		public function execute(event:CairngormEvent):void
		{
			DataModel.getInstance().viewContentViewStackIndex =
					ViewChangeEvent.VIEWSTACK_UPLOAD_MODULE_INDEX;
		}
		
	}
}