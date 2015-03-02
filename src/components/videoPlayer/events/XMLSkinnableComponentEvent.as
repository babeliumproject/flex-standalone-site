package components.videoPlayer.events
{
	import flash.events.Event;
	
	public class XMLSkinnableComponentEvent extends Event
	{		
		public static const SKIN_FILE_URL_CHANGED:String="skinFileUrlChanged";
		public static const SKIN_FILE_LOADED:String="skinFileLoaded";
		
		public function XMLSkinnableComponentEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}