package modules.create.view
{
	import flash.errors.IllegalOperationError;
	import flash.errors.MemoryError;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import modules.create.event.FileUploadEvent;
	
	[Event(name="fileSelected", type="modules.create.event.FileUploadEvent")]
	[Event(name="ioError", type="modules.create.event.FileUploadEvent")]
	[Event(name="securityError", type="modules.create.event.FileUploadEvent")]
	[Event(name="uploadError", type="modules.create.event.FileUploadEvent")]
	[Event(name="httpStatusError", type="modules.create.event.FileUploadEvent")]
	[Event(name="uploadProgress", type="modules.create.event.FileUploadEvent")]
	[Event(name="uploadComplete", type="modules.create.event.FileUploadEvent")]
	[Event(name="uploadCompleteData", type="modules.create.event.FileUploadEvent")]
	
	public class FileUpload extends EventDispatcher
	{
		private var uploadReference:FileReference;
		private var uploadURL:String;
		private var maxSizeBytes:int;
		
		private var _fileSize:int;
		private var _fileName:String;
		private var _fileSelected:Boolean;
		
		public function FileUpload(maxSize:int, serviceUrl:String = '/upload.php')
		{
			uploadReference=new FileReference();
			uploadURL=serviceUrl;
			maxSizeBytes=maxSize;
		}
		
		public function browse(filterDescription:String=null, filterExtension:String=null):void
		{
			if(!uploadReference) 
				uploadReference = new FileReference();
			uploadReference.addEventListener(Event.SELECT, onSelectFile, false, 0, true);
			uploadReference.addEventListener(IOErrorEvent.IO_ERROR, onUploadIoError, false, 0, true);
			
			if(filterDescription && filterExtension){
				var extensionFilter:FileFilter=new FileFilter(filterDescription, filterExtension);
				uploadReference.browse([extensionFilter]);
			} else {
				uploadReference.browse();
			}
		}
		
		public function upload():void
		{
			if(!_fileSelected) return;
			
			var sendVars:URLVariables=new URLVariables();
			sendVars.action="upload";
			
			var request:URLRequest=new URLRequest();
			request.data=sendVars;
			request.url=uploadURL;
			request.method=URLRequestMethod.POST;
			uploadReference.addEventListener(ProgressEvent.PROGRESS, onUploadProgress, false, 0, true);
			uploadReference.addEventListener(Event.COMPLETE, onUploadComplete, false, 0, true);
			uploadReference.addEventListener(IOErrorEvent.IO_ERROR, onUploadIoError, false, 0, true);
			uploadReference.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onUploadSecurityError, false, 0, true);
			uploadReference.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, onUploadCompleteData, false, 0, true);
			uploadReference.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatusError, false, 0, true);
			try
			{
				uploadReference.upload(request, "file", false);
			}
			catch (secErr:SecurityError)
			{
				dispatchEvent(new FileUploadEvent(FileUploadEvent.UPLOAD_ERROR, false, false, "Security Error: " + secErr.message));
			}
			catch (ilOpErr:IllegalOperationError)
			{
				dispatchEvent(new FileUploadEvent(FileUploadEvent.UPLOAD_ERROR, false, false, "Illegal Operation Error: " + ilOpErr.message));
			}
			catch (argErr:ArgumentError)
			{
				dispatchEvent(new FileUploadEvent(FileUploadEvent.UPLOAD_ERROR, false, false, "Argument Error: " + argErr.message));
			}
			catch (memErr:MemoryError)
			{
				dispatchEvent(new FileUploadEvent(FileUploadEvent.UPLOAD_ERROR, false, false, "Memory Error: " + memErr.message));
			}
			catch (err:Error)
			{
				dispatchEvent(new FileUploadEvent(FileUploadEvent.UPLOAD_ERROR, false, false, "Unknown Error: " + err.message));
			}
		}
		
		public function cancel():void
		{
			uploadReference.removeEventListener(ProgressEvent.PROGRESS, onUploadProgress);
			uploadReference.removeEventListener(Event.COMPLETE, onUploadComplete);
			uploadReference.removeEventListener(IOErrorEvent.IO_ERROR, onUploadIoError);
			uploadReference.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onUploadSecurityError);
			uploadReference.removeEventListener(DataEvent.UPLOAD_COMPLETE_DATA, onUploadCompleteData);
			uploadReference.removeEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatusError);
			uploadReference.cancel();
		}
		
		public function fileSize():int{
			return _fileSize ? _fileSize : 0;
		}
		
		public function fileName():String{
			return _fileName ? _fileName : null;
		}
		
		private function onSelectFile(event:Event):void
		{
			if (uploadReference.size < maxSizeBytes)
			{
				_fileSelected=true;
				_fileSize=uploadReference.size;
				_fileName=uploadReference.name;
				dispatchEvent(new FileUploadEvent(FileUploadEvent.FILE_SELECTED));
			}
			else
			{
				uploadReference.cancel();
				uploadReference = null;
				dispatchEvent(new FileUploadEvent(FileUploadEvent.IO_ERROR, false, false, "IOError - Your file is greater than the allowed maximum file size"));
			}
		}
		
		private function onUploadProgress(event:ProgressEvent):void
		{
			dispatchEvent(new FileUploadEvent(FileUploadEvent.UPLOAD_PROGRESS, false, false, "", "", event.bytesLoaded, event.bytesTotal));
		}
		
		private function onUploadComplete(event:Event):void
		{
			uploadReference.removeEventListener(Event.COMPLETE, onUploadComplete);
			dispatchEvent(new FileUploadEvent(FileUploadEvent.UPLOAD_COMPLETE));
		}
		
		private function onUploadCompleteData(event:DataEvent):void
		{
			uploadReference.removeEventListener(DataEvent.UPLOAD_COMPLETE_DATA, onUploadCompleteData);
			dispatchEvent(new FileUploadEvent(FileUploadEvent.UPLOAD_COMPLETE_DATA, false, false, event.text, event.data));
		}
		
		private function onUploadIoError(event:IOErrorEvent):void
		{
			this.cancel();
			dispatchEvent(new FileUploadEvent(FileUploadEvent.IO_ERROR, false, false, "IOError - " + event.text));
		}
		
		private function onUploadSecurityError(event:SecurityErrorEvent):void
		{
			this.cancel();
			dispatchEvent(new FileUploadEvent(FileUploadEvent.SECURITY_ERROR, false, false, "Upload Security Error -" + event.text));
		}
		
		public function onHttpStatusError(event:HTTPStatusEvent):void
		{
			this.cancel();
			dispatchEvent(new FileUploadEvent(FileUploadEvent.HTTP_STATUS_ERROR, false, false, "HTTP Status Error" + event.status));
		}
		
	}
}