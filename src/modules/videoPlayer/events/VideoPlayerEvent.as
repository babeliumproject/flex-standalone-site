package modules.videoPlayer.events
{
	import flash.events.Event;

	public class VideoPlayerEvent extends Event
	{
		
		public static const VIDEO_SOURCE_CHANGED:String = "VideoSourceChanged";
		public static const VIDEO_FINISHED_PLAYING:String = "VideoFinishedPlaying";
		
		public function VideoPlayerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}