package events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;
	
	import vo.ExerciseVO;

	public class UploadEvent extends CairngormEvent
	{
		
		public static const UPLOAD_BROWSE:String = "uploadBrowse";
		public static const UPLOAD_START:String = "uploadStart";
		public static const UPLOAD_CANCEL:String = "uploadCancel";
		
		public static const YOUTUBE_UPLOAD:String = "youtubeUpload";
		public static const YOUTUBE_CHECK_VIDEO_STATUS:String = "youtubeCheckVideoStatus";
		
		public var exercise:ExerciseVO;
		
		
		public function UploadEvent(type:String, exercise:ExerciseVO = null)
		{
			super(type);
			this.exercise = exercise;
		}
		
		override public function clone():Event{
			return new UploadEvent(type,exercise);
		}
		
	}
}