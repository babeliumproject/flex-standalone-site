package components.videoPlayer.events
{
	import flash.events.Event;
	
	public class MediaStatusEvent extends Event
	{
		
		public static const STREAM_SUCCESS:String="streamSuccess";
		public static const STREAM_FAILURE:String="streamFailure";
		
		public static const PLAYBACK_STARTED:String="playbackStarted";
		public static const PLAYBACK_FINISHED:String="playbackFinished";
		public static const METADATA_RETRIEVED:String="metadataRetrieved";
		public static const RECORDING_STARTED:String="recordingStarted";
		public static const RECORDING_FINISHED:String="recordingFinished";
		
		public static const STATE_CHANGED:String="stateChanged";
		
		public var streamid:String;
		public var state:int;
		public var message:String;
		
		
		public function MediaStatusEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, streamid:String=null, state:int=0, message:String=null)
		{
			super(type, bubbles, cancelable);
			this.streamid=streamid;
			this.state=state;
			this.message=message;
		}
		
		override public function clone():Event{
			return new MediaStatusEvent(type,bubbles,cancelable,streamid,state,message);
		}
	}
}