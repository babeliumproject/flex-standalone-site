package components.videoPlayer.media
{
	import flash.events.AsyncErrorEvent;
	import flash.events.DRMErrorEvent;
	import flash.events.DRMStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.NetDataEvent;
	import flash.events.NetStatusEvent;
	import flash.events.StatusEvent;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.URLVariables;
	
	import mx.utils.ObjectUtil;

	public class AVideoManager extends AMediaManager
	{
		
		private var _startTime:Number;
		private var _endTime:Number;
		
		
		public function AVideoManager(id:String)
		{
			super(id);
		}
		
		override public function setup(... args):void{
			_startTime=0;
			_endTime=0;
			if(args.length){
				//URL should be previously parsed with a general purpose HTTP regexp
				var url:String = (args[0] is String) ? args[0] : '';
				var urlParts:Array = url.split('?');
				_streamUrl = urlParts[0];
				//Url has query string
				if(urlParts.length > 1){
					var queryString:String = urlParts[1];
					var params:Object = parseQueryString(queryString);
					_startTime = params.hasOwnProperty('start') ? params.start : 0;
					_endTime = params.hasOwnProperty('end') ? params.end : 0;
					logger.debug("URL contains query string: start={0}, end={1}", [_startTime, _endTime]);
				}
			}
			this.addEventListener(StreamingEvent.CONNECTED_CHANGE, onConnectionStatusChange);
			connect();
		}
			
		private function parseQueryString(queryStr:String):Object{
			var params:Object = new Object();
			var allParams:Array = queryStr.split('&');
			for(var i:int=0, index:int=-1; i < allParams.length; i++)
			{
				var keyValuePair:String = allParams[i];
				if((index = keyValuePair.indexOf("=")) > 0)
				{
					var paramKey:String = keyValuePair.substring(0,index);
					var paramValue:String = keyValuePair.substring(index+1);
					params[paramKey] = paramValue;
				}
			}
			return params;
		}
		
		private function connect():void{
			
			_nc = new NetConnection();
			_nc.client=this;
			_nc.connect(null);
			_connected=true;
			dispatchEvent(new StreamingEvent(StreamingEvent.CONNECTED_CHANGE));
		}
		
		override public function play(/*params:Object*/):void
		{
			try
			{
				var qs:URLVariables = new  URLVariables();
				if(_startTime) qs.start = _startTime;
				//if(_endTime) qs.end = _endTime;
				var queryString:String = unescape(qs.toString());
				var playUrl:String = queryString.length ? _streamUrl + '?' + queryString : _streamUrl;
				logger.info("[{0}] Play {1}", [_id, playUrl]);
				_ns.play(playUrl);
			}
			catch (e:Error)
			{
				logger.error("[{0}] Play Error [{1}] {2}", [_id, e.name, e.message]);
			}
		}
		
		override public function seek(seconds:Number):void{
			if(!isNaN(seconds) && seconds >= 0 && seconds < duration){
				var realseconds:Number = seconds - _startTime;
				var reqFraction:Number = realseconds/_duration;
				//The user seeked to a time that is not cached. Try to load the media file from that point onwards (Pseudo-Streaming/Apache Mod h.264)
				if(loadedFraction < reqFraction || realseconds < 0){
					//Set the new start time
					_startTime = Math.abs(realseconds);
					play();
				} else {
					_ns.seek(seconds);
				}
			}
		}
		
		override public function get duration():Number
		{
			return _connected ? (_startTime + _duration) : 0;
		}
		
		override public function get currentTime():Number
		{
			return _connected ? (_startTime + _ns.time) : 0;
		}
		
		override public function get startBytes():Number{
			return _ns && _duration ? Math.round(_startTime * (_ns.bytesTotal / _duration)) : 0;
		}
		
		override public function get bytesTotal():Number{
			//Make a calculus to get an estimate of the total bytes when the video starts playing from a point that is not the beginning
			return _ns ? startBytes + _ns.bytesTotal : 0;
		}
		
		override protected function onNetStatus(event:NetStatusEvent):void{
			super.onNetStatus(event);
			
			switch (_netStatusCode)
			{
				case "NetStream.Buffer.Empty":
					if (_streamStatus == STREAM_STOPPED)
					{
						_streamStatus=STREAM_FINISHED;
					}
					else
						_streamStatus=STREAM_BUFFERING;
					break;
				case "NetStream.Buffer.Full":			
					if (_streamStatus == STREAM_READY)
					{
						_streamStatus=STREAM_STARTED;
						dispatchEvent(new NetStreamClientEvent(NetStreamClientEvent.PLAYBACK_STARTED, _id));
					}
					if (_streamStatus == STREAM_BUFFERING)
						_streamStatus=STREAM_STARTED;
					if (_streamStatus == STREAM_UNPAUSED)
						_streamStatus=STREAM_STARTED;
					if (_streamStatus == STREAM_SEEKING_START)
						_streamStatus = STREAM_STARTED;
					
					break;
				case "NetStream.Buffer.Flush":
					break;
				case "NetStream.Play.Start":
					_streamStatus=STREAM_READY;
					break;
				case "NetStream.Play.Stop":
					_streamStatus=STREAM_STOPPED;
					break;
				case "NetStream.Play.Reset":
					break;
				case "NetStream.Play.Failed":
					break;
				case "NetStream.Play.FileStructureInvalid":
					break;
				case "NetStream.Play.InsufficientBW":
					break;
				case "NetStream.Play.NoSupportedTrackFound":
					break;
				case "NetStream.Play.StreamNotFound":
					dispatchEvent(new NetStreamClientEvent(NetStreamClientEvent.NETSTREAM_ERROR, _id, -1, "ERROR_STREAM_NOT_FOUND"));
					break;
				case "NetStream.Play.Transition":
					break;
				case "NetStream.Pause.Notify":
					_streamStatus=STREAM_PAUSED;
					break;
				case "NetStream.Unpause.Notify":
					if(_streamStatus==STREAM_PAUSED)
						_streamStatus=STREAM_STARTED;
					break;
				case "NetStream.Seek.Notify":
					_streamStatus=STREAM_SEEKING_START;
					break;
				case "NetStream.SeekStart.Notify":
					_streamStatus=STREAM_SEEKING_START;
					break;
				default:
					break;
			}
			dispatchEvent(new NetStreamClientEvent(NetStreamClientEvent.STATE_CHANGED, _id, _streamStatus));
		}
	}
}