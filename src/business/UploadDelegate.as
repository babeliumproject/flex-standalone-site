package business
{
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import model.DataModel;
	
	import mx.rpc.IResponder;

	public class UploadDelegate
	{

		private var responder:IResponder;
		private var uploadReference:FileReference=DataModel.getInstance().uploadFileReference;
		private var uploadURL:String=DataModel.getInstance().uploadURL;

		public function UploadDelegate(responder:IResponder)
		{
			if(DataModel.getInstance().uploadFileReference == null)
				DataModel.getInstance().uploadFileReference = new FileReference();
			this.responder=responder;
		}
		
		public function browse():void{
			uploadReference=DataModel.getInstance().uploadFileReference;
			uploadReference.addEventListener(Event.SELECT, onSelectFile);
			uploadReference.browse();
		}				

		public function upload():void
		{
			uploadReference=DataModel.getInstance().uploadFileReference;
			var sendVars:URLVariables=new URLVariables();
			sendVars.action="upload";

			var request:URLRequest=new URLRequest();
			request.data=sendVars;
			request.url=uploadURL;
			request.method=URLRequestMethod.POST;

			uploadReference.addEventListener(ProgressEvent.PROGRESS, onUploadProgress);
			uploadReference.addEventListener(Event.COMPLETE, onUploadComplete);
			uploadReference.addEventListener(IOErrorEvent.IO_ERROR, onUploadIoError);
			uploadReference.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onUploadSecurityError);
			uploadReference.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, onUploadCompleteData);
			uploadReference.upload(request, "file", false);
		}
		
		public function cancel():void{
			uploadReference=DataModel.getInstance().uploadFileReference;
			uploadReference.removeEventListener(ProgressEvent.PROGRESS, onUploadProgress);
			uploadReference.removeEventListener(Event.COMPLETE, onUploadComplete);
			uploadReference.removeEventListener(IOErrorEvent.IO_ERROR, onUploadIoError);
			uploadReference.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onUploadSecurityError);
			uploadReference.cancel();
		}

		private function onSelectFile(event:Event):void{
			//Pass Event to UploadBrowseCommand
			this.responder.result(event);
		}

		private function onUploadProgress(event:ProgressEvent):void
		{
			//Pass ProgressEvent to UploadOngoingCommand
			this.responder.result(event);
		}

		private function onUploadComplete(event:Event):void
		{
			//Pass Event to UploadOngoingCommand
			this.responder.result(event);
		}

		private function onUploadCompleteData(event:DataEvent):void
		{
			//Pass DataEvent to UploadOngoingCommand
			this.responder.result(event);
		}

		private function onUploadIoError(event:IOErrorEvent):void
		{
			//Cancel the operation
			this.cancel();
			//Pass IOErrorEvent to UploadOngoingCommand
			this.responder.fault(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, true, "IOError - "+event.text));
		}

		private function onUploadSecurityError(event:SecurityErrorEvent):void
		{
			//Cancel the operation
			this.cancel();
			//Pass SecurityErrorEvent to UploadOngoingCommand
			this.responder.fault(new SecurityErrorEvent(SecurityErrorEvent.SECURITY_ERROR,false,true, "Upload Security Error -"+event.text));
		}

		

	}
}