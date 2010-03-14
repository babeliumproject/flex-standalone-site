package commands.videoUpload
{
	import business.UploadDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.ProgressEvent;
	
	import model.DataModel;
	
	import mx.controls.Alert;
	import mx.rpc.IResponder;
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
			else if (data is DataEvent){
				var controlMessage:String = (data as DataEvent).data;
				//success, data, data.filepath, data.filemimetype, error
				var messageXML:XML = new XML(controlMessage);
				if(messageXML.success == "true")
					DataModel.getInstance().uploadErrors = '';
				else
					DataModel.getInstance().uploadErrors = messageXML.error;
				DataModel.getInstance().uploadFinishedData = true;
			//Upload finished
			}else if (data is Event)
				DataModel.getInstance().uploadFinished = true;
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