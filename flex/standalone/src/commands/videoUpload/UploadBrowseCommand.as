package commands.videoUpload
{
	import business.UploadDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	
	import model.DataModel;
	
	import mx.controls.Alert;
	import mx.resources.ResourceManager;
	import mx.rpc.IResponder;
	import mx.utils.ObjectUtil;
	
	import view.common.CustomAlert;

	public class UploadBrowseCommand implements ICommand, IResponder
	{

		public function execute(event:CairngormEvent):void
		{
			new UploadDelegate(this).browse();
		}
		
		public function result(data:Object):void
		{
			DataModel.getInstance().uploadFileSelected = true;
		}
		
		public function fault(info:Object):void
		{
			if (info is HTTPStatusEvent)
				CustomAlert.error(ResourceManager.getInstance().getString('myResources','ERROR_WHILE_UPLOADING_FILE'));
			if(info is IOErrorEvent)
				CustomAlert.error(ResourceManager.getInstance().getString('myResources','MAXIMUM_FILESIZE_EXCEEDED'));
			else
				CustomAlert.error(ResourceManager.getInstance().getString('myResources','ERROR_WHILE_UPLOADING_FILE'));
			trace(ObjectUtil.toString(info));
		}
		
	}
}