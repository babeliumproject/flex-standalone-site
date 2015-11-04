package components.videoPlayer.media
{
	/**
	 * Callbacks of the client object from the NetConnection class
	 * 
	 * @author inko
	 * 
	 */	
	public interface INetConnectionCallbacks
	{
		function onBWCheck(info:Object=null):void;
		
		function onBWDone(info:Object=null):void;
	}
}