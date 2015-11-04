package components.videoPlayer.events
{
	import flash.events.Event;

	public class VideoPlayerEvent extends Event
	{
		public static const STREAM_NOT_FOUND:String = "streamNotFound";
		public static const VIDEO_SOURCE_CHANGED:String = "VideoSourceChanged";
		public static const VIDEO_FINISHED_PLAYING:String = "VideoFinishedPlaying";
		public static const VIDEO_STARTED_PLAYING:String = "VideoStartedPlaying";
		public static const METADATA_RETRIEVED:String = "MetadataRetrieved";
		public static const CREATION_COMPLETE:String = "VideoPlayerCreationComplete";
		public static const CONNECTED:String = "VideoConnected";
		
		public static const ON_ERROR:String="onError";
		public static const ON_READY:String="onReady";
		
		public var code:int;
		public var message:String;
		
		public function VideoPlayerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, code:int=0, message:String=null)
		{
			super(type, bubbles, cancelable);
			this.code = code;
			this.message = message;
		}
		
		override public function clone():Event{
			return new VideoPlayerEvent(type,bubbles,cancelable,code,message);
		}
	}
}
