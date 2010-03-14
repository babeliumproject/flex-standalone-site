package commands.videoUpload
{
	import business.UploadDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.HTTPStatusEvent;
	
	import model.DataModel;
	
	import mx.controls.Alert;
	import mx.rpc.IResponder;
	import mx.utils.ObjectUtil;

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
				Alert.show("Error while uploading file:\n" + info.status);
			else
				Alert.show("Error while uploading file:\n" + info.text);
			trace(ObjectUtil.toString(info));
		}
		
	}
}