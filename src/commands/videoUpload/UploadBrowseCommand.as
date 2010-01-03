package commands.videoUpload
{
	import business.UploadDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import model.DataModel;
	
	import mx.controls.Alert;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
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
			var faultEvent:FaultEvent=FaultEvent(info);
			Alert.show("Error while retrieving user data:" + faultEvent.message);
			trace(ObjectUtil.toString(info));
		}
		
	}
}