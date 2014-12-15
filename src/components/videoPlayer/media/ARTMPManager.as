package components.videoPlayer.media
{	
	import flash.errors.IOError;
	import flash.events.AsyncErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.NetConnection;
	import flash.net.ObjectEncoding;
	
	import mx.utils.ObjectUtil;

	public class ARTMPManager extends AMediaManager
	{
		
		/*
		 * Allowed values are -2, -1, 0, or a positive number. 
		 * The default value is -2, which looks for a live stream, then a recorded stream, and if it finds neither, opens a live stream. You cannot use -2 with MP3 files. 
		 * If -1, plays only a live stream. 
		 * If 0 or a positive number, plays a recorded stream, beginning start seconds in.
		 */
		private const PLAY_MODE_WAIT_LIVE:int=-2;
		private const PLAY_MODE_ONLY_LIVE:int=-1;
		private const PLAY_MODE_ONLY_RECORDED:int=0;
		
		private var _defaultPlayMode:int = PLAY_MODE_ONLY_RECORDED;
			
		private var _streamFinishBuffer:Object = {"NetStream.Buffer.Empty": 0, "NetStream.Buffer.Flush": 0, "NetStream.Play.Stop": 0};

		private var _encoding:uint;
		private var _proxy:String;

		private var _streamingServerUrl:String;

		private var _netConnectOngoingAttempt:Boolean;

		public function ARTMPManager(id:String)
		{
			super(id);
		}
		
		override public function play(/*params:Object*/):void
		{
			try
			{		
				//Spec says if flv "folder/streamname" without extension. If mp3 "mp3:folder/streamname". If mp4 "mp4:folder/streamname"
				var formattedStreamUrl:String = _streamUrl;
				if(_streamUrl.search(/\.flv$/) !=-1)
					formattedStreamUrl = _streamUrl.substr(0,-4);
				if(_streamUrl.search(/\.mp3$/) !=-1)
					formattedStreamUrl = "mp3:" + _streamUrl.substr(0,-4);
				if(_streamUrl.search(/\.mp4$/) != -1 || _streamUrl.search(/\.f4v$/) != -1 || _streamUrl.search(/\.mov$/) != -1)
					formattedStreamUrl = "mp4:" + _streamUrl.substr(0,-4);
				logger.info("[{0}] Play {1}", [_id, formattedStreamUrl]);
				_ns.play(formattedStreamUrl,_defaultPlayMode);
			}
			catch (e:Error)
			{
				logger.error("[{0}] Play Error [{1}] {2}", [_id, e.name, e.message]);
			}
		}
		
		override public function stop():void{
			logger.debug("Stop was called");
			_ns.close();
		}
		
		override public function publish(mode:String='record'):void{
			_ns.publish(_streamUrl, mode);
		}
		
		override public function setup(... args):void{
			if(args && args.length){
				_streamingServerUrl = (args[0] is String) ? args[0] : null;
				_streamUrl = (args[1] is String) ? args[1] : null;
			}
			//logger.debug("Streaming server: {0} stream name: {1}" [_serverUrl, _streamUrl]);
			this.addEventListener(StreamingEvent.CONNECTED_CHANGE, onConnectionStatusChange);
			connect(_streamingServerUrl);
		}

		private function connect(... args):void
		{
			if (args.length >= 1)
			{
				var rtmpServerUrl:String=(args[0] is String) ? args[0] : '';
				_proxy= args[1] ? args[1] as String : 'none';
				_encoding= args[2] ? args[2] as uint : ObjectEncoding.DEFAULT;
			}

			if (!rtmpServerUrl)
			{
				logger.error("No streaming url was provided");
				_connected=false;
				dispatchEvent(new StreamingEvent(StreamingEvent.CONNECTED_CHANGE));
			}

			//We check if another connect attempt is still ongoing
			if (!_netConnectOngoingAttempt)
			{
				_netConnectOngoingAttempt=true;

				_nc=new NetConnection();
				_nc.client=this;
				_nc.objectEncoding=_encoding;
				_nc.proxyType=_proxy;
		
				// Setup the NetConnection and listen for NetStatusEvent and SecurityErrorEvent events.
				_nc.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
				_nc.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError);
				_nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
				_nc.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
				// connect to server
				try
				{
					logger.info("Connecting to {0}", [_streamingServerUrl]);
					// Create connection with the server.
					_nc.connect(_streamingServerUrl);
				}
				catch (e:ArgumentError)
				{
					// Invalid parameters.
					switch (e.errorID)
					{
						case 2004:
							logger.error("Invalid server location: {0}", [_streamingServerUrl]);
							_netConnectOngoingAttempt=false;
							_connected=false;
							dispatchEvent(new StreamingEvent(StreamingEvent.CONNECTED_CHANGE));
							break;
						default:
							logger.error("Undetermined problem while connecting with: {0}", [_streamingServerUrl]);
							_netConnectOngoingAttempt=false;
							_connected=false;
							dispatchEvent(new StreamingEvent(StreamingEvent.CONNECTED_CHANGE));
							break;
					}
				}
				catch (e:IOError)
				{
					logger.error("IO error while connecting to: {0}", [_streamingServerUrl]);
					_netConnectOngoingAttempt=false;
					_connected=false;
					dispatchEvent(new StreamingEvent(StreamingEvent.CONNECTED_CHANGE));
				}
				catch (e:SecurityError)
				{
					logger.error("Security error while connecting to: {0}", [_streamingServerUrl]);
					_netConnectOngoingAttempt=false;
					_connected=false;
					dispatchEvent(new StreamingEvent(StreamingEvent.CONNECTED_CHANGE));
				}
				catch (e:Error)
				{
					logger.error("Unidentified error while connecting to: {0}", [_streamingServerUrl]);
					_netConnectOngoingAttempt=false;
					_connected=false;
					dispatchEvent(new StreamingEvent(StreamingEvent.CONNECTED_CHANGE));
				}
			}
		}

		protected function onSecurityError(event:SecurityErrorEvent):void
		{
			_netConnectOngoingAttempt=false;
			logger.error("[{0}] SecurityError {1} {2}", [_id, event.errorID, event.text]);
		}


		override protected function onIoError(event:IOErrorEvent):void
		{
			super.onIoError(event);
			_netConnectOngoingAttempt=false;
		}

		override protected function onAsyncError(event:AsyncErrorEvent):void
		{
			super.onAsyncError(event);
			_netConnectOngoingAttempt=false;
		}

		override protected function onNetStatus(event:NetStatusEvent):void
		{

			super.onNetStatus(event);
			if (event.currentTarget is NetConnection)
			{
				switch (_netStatusCode)
				{
					case "NetConnection.Connect.Success":
						_connected=true;
						if (event.target.connectedProxyType == "HTTPS" || event.target.usingTLS)
							logger.info("Connected to secure server");
						else
							logger.info("Connected to server");
						dispatchEvent(new StreamingEvent(StreamingEvent.CONNECTED_CHANGE));
						break;
					case "NetConnection.Connect.Failed":
						logger.info("Connection to server failed");
						_connected=false;
						dispatchEvent(new StreamingEvent(StreamingEvent.CONNECTED_CHANGE));
						break;

					case "NetConnection.Connect.Closed":
						logger.info("Connection to server closed");
						_connected=false;
						dispatchEvent(new StreamingEvent(StreamingEvent.CONNECTED_CHANGE));
						break;

					case "NetConnection.Connect.InvalidApp":
						logger.info("Application not found on server");
						_connected=false;
						dispatchEvent(new StreamingEvent(StreamingEvent.CONNECTED_CHANGE));
						break;

					case "NetConnection.Connect.AppShutDown":
						logger.info("Application has been shutdown");
						_connected=false;
						dispatchEvent(new StreamingEvent(StreamingEvent.CONNECTED_CHANGE));
						break;

					case "NetConnection.Connect.Rejected":
						logger.info("No permissions to connect to the application");
						_connected=false;
						dispatchEvent(new StreamingEvent(StreamingEvent.CONNECTED_CHANGE));
						break;
					default:
						break;
				}
			}
			else
			{
				switch (_netStatusCode)
				{
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
						if (_streamStatus == STREAM_SEEKING_END)
							_streamStatus=STREAM_STARTED;
						break;
					case "NetStream.Buffer.Empty":
						//if (_streamStatus != STREAM_STOPPED && _streamStatus != STREAM_FINISHED)
							_streamStatus=STREAM_BUFFERING;
						break;
					case "NetStream.Buffer.Flush":
						//if (_streamStatus == STREAM_STOPPED)
						//	_streamStatus=STREAM_FINISHED;
						break;
					case "NetStream.Publish.Start":
						break;
					case "NetStream.Publish.Idle":
						break;
					case "NetStream.Unpublish.Success":
						break;
					case "NetStream.Play.Start":
						_streamStatus=STREAM_READY;
						break;
					case "NetStream.Play.Stop":
						_streamStatus=STREAM_STOPPED;
						break;
					case "NetStream.Play.Reset":
						break;
					case "NetStream.Play.PublishNotify":
						break;
					case "NetStream.Play.UnpublishNotify":
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
						_streamStatus=STREAM_UNPAUSED;
						break;
					case "NetStream.Record.Start":
						break;
					case "NetStream.Record.Stop":
						break;
					case "NetStream.Seek.Notify":
						_streamStatus=STREAM_SEEKING_START;
						break;
					case "NetStream.SeekStart.Notify":
						_streamStatus=STREAM_SEEKING_START;
						break;
					case "NetStream.Seek.Complete":
						_streamStatus=STREAM_SEEKING_END;
						break;
					default:
						break;
				}
				if(checkEndingBuffer(_netStatusCode))
					_streamStatus=STREAM_FINISHED;
				dispatchEvent(new NetStreamClientEvent(NetStreamClientEvent.STATE_CHANGED, _id, _streamStatus));
			}
		}
		
		private function checkEndingBuffer(currentNetStatus:String):uint{
			if(_streamFinishBuffer.hasOwnProperty(currentNetStatus)){
				_streamFinishBuffer[currentNetStatus] = 1;
			} else {
				for(var k:String in _streamFinishBuffer){
					_streamFinishBuffer[k]=0;
				}
			}
			var result:uint=1;
			for each(var val:int in _streamFinishBuffer){
				result &= val;
			}
			return result;
		}

	}
}
