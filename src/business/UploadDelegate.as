package business
{
	import flash.errors.IllegalOperationError;
	import flash.errors.MemoryError;
	import flash.events.DataEvent;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import model.DataModel;
	
	import mx.rpc.IResponder;

	public class UploadDelegate
	{

		private var responder:IResponder;
		private var uploadReference:FileReference;
		private var uploadURL:String;

		private var _dataModel:DataModel=DataModel.getInstance();

		public function UploadDelegate(responder:IResponder)
		{
			if (_dataModel.uploadFileReference == null)
				_dataModel.uploadFileReference=new FileReference();
			this.responder=responder;
		}

		public function browse():void
		{
			var videosFilter:FileFilter=new FileFilter("Videos (.avi, .flv, .mp4)", "*.avi;*.flv;*.mp4");
			uploadReference=_dataModel.uploadFileReference;
			uploadReference.addEventListener(Event.SELECT, onSelectFile);
			uploadReference.addEventListener(IOErrorEvent.IO_ERROR, onUploadIoError);
			uploadReference.browse([videosFilter]);
		}

		public function upload():void
		{
			uploadReference=_dataModel.uploadFileReference;
			var sendVars:URLVariables=new URLVariables();
			sendVars.action="upload";

			uploadURL=_dataModel.uploadURL;

			var request:URLRequest=new URLRequest();
			request.data=sendVars;
			request.url=uploadURL;
			request.method=URLRequestMethod.POST;
			uploadReference.addEventListener(ProgressEvent.PROGRESS, onUploadProgress);
			uploadReference.addEventListener(Event.COMPLETE, onUploadComplete);
			uploadReference.addEventListener(IOErrorEvent.IO_ERROR, onUploadIoError);
			uploadReference.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onUploadSecurityError);
			uploadReference.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, onUploadCompleteData);
			uploadReference.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatusError);
			try
			{
				uploadReference.upload(request, "file", false);
			}
			catch (secErr:SecurityError)
			{
				trace("Security Error: " + secErr.message);
			}
			catch (ilOpErr:IllegalOperationError)
			{
				trace("Illegal Operation Error: " + ilOpErr.message);
			}
			catch (argErr:ArgumentError)
			{
				trace("Argument Error: " + argErr.message);
			}
			catch (memErr:MemoryError)
			{
				trace("Memory Error: " + memErr.message);
			}
			catch (err:Error)
			{
				trace("Unknown Error: " + err.message);
			}
		}

		public function cancel():void
		{
			uploadReference=_dataModel.uploadFileReference;
			uploadReference.removeEventListener(ProgressEvent.PROGRESS, onUploadProgress);
			uploadReference.removeEventListener(Event.COMPLETE, onUploadComplete);
			uploadReference.removeEventListener(IOErrorEvent.IO_ERROR, onUploadIoError);
			uploadReference.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onUploadSecurityError);
			uploadReference.removeEventListener(DataEvent.UPLOAD_COMPLETE_DATA, onUploadCompleteData);
			uploadReference.removeEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatusError);
			uploadReference.cancel();
		}

		private function onSelectFile(event:Event):void
		{
			//Check if the video file weights less than the maximum file size
			if (uploadReference.size < DataModel.getInstance().maxFileSize)
			{
				//Pass Event to UploadBrowseCommand
				this.responder.result(event);
			}
			else
			{
				uploadReference.cancel();
				uploadReference = null;
				this.responder.fault(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, true, "IOError - Your file is greater than the allowed maximum file size"));
			}
		}

		private function onUploadProgress(event:ProgressEvent):void
		{
			//Pass ProgressEvent to UploadOngoingCommand
			this.responder.result(event);
		}

		private function onUploadComplete(event:Event):void
		{
			//Pass Event to UploadOngoingCommand
			uploadReference.removeEventListener(Event.COMPLETE, onUploadComplete);
			this.responder.result(event);
		}

		private function onUploadCompleteData(event:DataEvent):void
		{
			//Pass DataEvent to UploadOngoingCommand
			uploadReference.removeEventListener(DataEvent.UPLOAD_COMPLETE_DATA, onUploadCompleteData);
			this.responder.result(event);
		}

		private function onUploadIoError(event:IOErrorEvent):void
		{
			//Cancel the operation
			this.cancel();
			//Pass IOErrorEvent to UploadOngoingCommand
			this.responder.fault(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, true, "IOError - " + event.text));
		}

		private function onUploadSecurityError(event:SecurityErrorEvent):void
		{
			//Cancel the operation
			this.cancel();
			//Pass SecurityErrorEvent to UploadOngoingCommand
			this.responder.fault(new SecurityErrorEvent(SecurityErrorEvent.SECURITY_ERROR, false, true, "Upload Security Error -" + event.text));
		}

		public function onHttpStatusError(event:HTTPStatusEvent):void
		{
			//Cancel the operation
			this.cancel();
			//Pass HTTPStatusEvent to UploadOngoingCommand
			this.responder.fault(new HTTPStatusEvent(HTTPStatusEvent.HTTP_STATUS, false, true, event.status));
		}

	}
}