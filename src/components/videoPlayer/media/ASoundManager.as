package components.videoPlayer.media
{	
	import flash.events.IOErrorEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;

	public class ASoundManager extends AMediaManager
	{
		
		private var _snd:Sound;
		private var _channel:SoundChannel;
		
		private var _currentTime:Number;
		
		public function ASoundManager(url:String, id:String)
		{
			super(url, id);
		}
		
		public function connect():void{
			_snd = new Sound();
			
			var request:URLRequest = new URLRequest(_streamUrl);
			
			_snd.load();
			_snd.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
		}
		
		public function play():void{
			_channel = _snd.play();
		}
		
		public function stop():void{
			_channel.stop();
			_snd.close();
		}
		
		public function pause():void{
			_currentTime = _channel.position;
			_channel.stop();
		}
		
		public function resume():void{
			_snd.play(_currentTime);
		}
		
		public function seek(seconds:Number):void{
			_snd.play(seconds);
		}
		
		override public function get duration():Number
		{
			return _snd.length / 1000;
		}	
		
		public function get loadedFraction():Number
		{
			return _snd.bytesLoaded / _snd.bytesTotal;
		}
		
		public function get currentTime():Number
		{
			return _channel.position / 1000;
		}
	}
}