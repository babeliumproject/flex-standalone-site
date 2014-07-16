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
	import mx.resources.ResourceManager;
	import mx.rpc.IResponder;
	import mx.utils.ObjectUtil;
	
	import view.common.CustomAlert;

	public class UploadStartCommand implements ICommand, IResponder
	{

		private var _dataModel:DataModel=DataModel.getInstance();

		public function execute(event:CairngormEvent):void
		{
			new UploadDelegate(this).upload();
		}

		public function result(data:Object):void
		{
			//The event is a progress update
			if (data is ProgressEvent)
			{
				var result:ProgressEvent=data as ProgressEvent;
				_dataModel.uploadBytesLoaded=result.bytesLoaded;
				_dataModel.uploadBytesTotal=result.bytesTotal;
				_dataModel.uploadProgressUpdated=!_dataModel.uploadProgressUpdated;
			}
			//Upload finished and sent some data
			else if (data is DataEvent)
			{
				var controlMessage:String=(data as DataEvent).data;
				//success, data, data.filename, data.filemimetype, error
				var messageXML:XML=new XML(controlMessage);
				if (messageXML.status == "success"){
					_dataModel.uploadErrors='';
					_dataModel.uploadFileName = messageXML.response.filename;
				}
				else{
					//_dataModel.uploadErrors=messageXML.response.code;
					_dataModel.uploadErrors=messageXML.response.message;
					_dataModel.uploadFileName = '';
				}
				_dataModel.uploadFinishedData=!_dataModel.uploadFinishedData;
			}
		}

		public function fault(info:Object):void
		{
			if (info is HTTPStatusEvent)
				CustomAlert.error(ResourceManager.getInstance().getString('myResources','ERROR_WHILE_UPLOADING_FILE'));
			else
				CustomAlert.error(ResourceManager.getInstance().getString('myResources','ERROR_WHILE_UPLOADING_FILE'));
			trace(ObjectUtil.toString(info));
		}

	}
}