package modules.videoPlayer
{
	public interface INetStreamCallbacks
	{	
		public function onCuePoint(cuePoint:Object):void;
			
		public function onImageData(imageData:Object):void;
		
		public function onMetaData(metaData:Object):void;
		
		public function onPlayStatus(playStatus:Object):void;
		
		public function onSeekPoint(seekPoint:Object):void;
		
		public function onTextData(textData:Object):void;
		
		public function onXMPData(xmpData:Object):void; 
	}
}