package components.videoPlayer
{
	public interface INetStreamCallbacks
	{	
		function onCuePoint(cuePoint:Object):void;
			
		function onImageData(imageData:Object):void;
		
		function onMetaData(metaData:Object):void;
		
		function onPlayStatus(playStatus:Object):void;
		
		function onSeekPoint(seekPoint:Object):void;
		
		function onTextData(textData:Object):void;
		
		function onXMPData(xmpData:Object):void; 
	}
}