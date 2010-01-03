package commands.videoUpload
{
	import business.UploadDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	
	import model.DataModel;
	
	import mx.controls.Alert;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ObjectUtil;

	public class UploadStartCommand implements ICommand, IResponder
	{

		public function execute(event:CairngormEvent):void
		{
			new UploadDelegate(this).upload();
		}
		
		public function result(data:Object):void
		{
			//The event is a progress update
			if (data is ProgressEvent){
				var result:ProgressEvent = data as ProgressEvent;
				DataModel.getInstance().uploadBytesLoaded = result.bytesLoaded;
				DataModel.getInstance().uploadBytesTotal = result.bytesTotal;
				DataModel.getInstance().uploadProgressUpdated = true;
			}
			//Upload finished and sent some data
			else if (data is DataEvent)
				DataModel.getInstance().uploadFinishedData = true;
			//Upload finished
			else if (data is Event)
				DataModel.getInstance().uploadFinished = true;
		}
		
		public function fault(info:Object):void
		{
			var faultEvent:FaultEvent=FaultEvent(info);
			Alert.show("Error while uploading file:" + faultEvent.message);
			trace(ObjectUtil.toString(info));
		}
		
	}
}