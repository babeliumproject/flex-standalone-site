package modules.create.event
{
	import flash.events.Event;

	public class FileUploadEvent extends Event
	{

		public static const FILE_SELECTED:String="fileSelected";
		public static const IO_ERROR:String="ioError";
		public static const SECURITY_ERROR:String="securityError";
		public static const UPLOAD_ERROR:String="uploadError";
		public static const HTTP_STATUS_ERROR:String="httpStatusError";
		public static const UPLOAD_PROGRESS:String="uploadProgress";
		public static const UPLOAD_COMPLETE:String="uploadComplete";
		public static const UPLOAD_COMPLETE_DATA:String="uploadCompleteData";
		
		public var text:String;
		public var data:String;
		public var bytesLoaded:Number;
		public var bytesTotal:Number;

		public function FileUploadEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, text:String="", data:String="", bytesLoaded:Number=0, bytesTotal:Number=0)
		{
			super(type, bubbles, cancelable);
			this.text=text;
			this.data=data;
			this.bytesLoaded=bytesLoaded;
			this.bytesTotal=bytesTotal;
		}
		
		/**
		 *  @private
		 */
		override public function clone():Event
		{
			return new FileUploadEvent(type, bubbles, cancelable, text, data, bytesLoaded, bytesTotal);
		}
	}
}
