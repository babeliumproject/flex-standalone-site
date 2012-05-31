package modules.videoPlayer
{
	import flash.events.AsyncErrorEvent;
	import flash.events.DRMAuthenticateEvent;
	import flash.events.DRMErrorEvent;
	import flash.events.DRMStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.NetDataEvent;
	import flash.events.NetStatusEvent;
	import flash.events.StatusEvent;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.ByteArray;
	
	import modules.videoPlayer.events.babelia.VideoPlayerBabeliaEvent;
	
	import mx.utils.ObjectUtil;
	
	//http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/net/NetStream.html

	public class NetStreamClient implements INetStreamCallbacks extends NetStream
	{
		
		public static const TRACE_INFO:uint = 0x0001;
		public static const TRACE_ERROR:uint = 0x0002;
		
		public static const STREAM_READY:int=0;
		public static const STREAM_STARTED:int=1;
		public static const STREAM_STOPPED:int=2;
		public static const STREAM_FINISHED:int=3;
		public static const STREAM_PAUSED:int=4;
		public static const STREAM_UNPAUSED:int=5;
		public static const STREAM_BUFFERING:int=6;
		
		//private var ns:NetStream;
		private var _nc:NetConnection;
		private var _connected:Boolean;
		private var _streamStatus:uint;
		
		public function NetStreamClient(connection:NetConnection)
		{
			try{
				super(connection);
				_nc = connection;
				this.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError);
				this.addEventListener(DRMAuthenticateEvent.DRM_AUTHENTICATE, onDrmAuthenticate);
				this.addEventListener(DRMErrorEvent.DRM_ERROR, onDrmError);
				this.addEventListener(DRMStatusEvent.DRM_STATUS, onDrmStatus);
				this.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
				this.addEventListener(NetDataEvent.MEDIA_TYPE_DATA, onMediaTypeData);
				this.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
				this.addEventListener(StatusEvent.STATUS, onStatus);
				this.client = this;
				_connected=true;
			} catch(exception:ArgumentError){
				//netconnection is not connected
				_connected=false;
			}
		}
		
		public function setTraceLevel(level:uint):void{
			
		}
		
		override public function play(...parameters):void{
			try{
				super.play(parameters);	
			} 
			catch(e:SecurityError){
				
			}
			catch(e:ArgumentError){
				
			}
			catch(e:Error){
				_connected=false;
			}
		}
		
		/*
		 * Event listeners
		 */
		public function onAsyncError(event:AsyncErrorEvent):void{
			trace(event.error.name+" "+event.error.message);
		}
		
		public function onDrmAuthenticate(event:DRMAuthenticateEvent):void{
			
		}
		
		public function onDrmError(event:DRMErrorEvent):void{
			
		}
		
		public function onDrmStatus(event:DRMStatusEvent):void{
			
		}
		
		public function onIoError(event:IOErrorEvent):void{
			trace(event.target.toString() + " " + event.text);
		}
		
		public function onMediaTypeData(event:NetDataEvent):void{
			
		}
		
		public function onNetStatus(event:NetStatusEvent):void{
			var info:Object=event.info;
			var messageCode:String=info.code;
			var messageLevel:String=info.level;
			
			trace("["+messageLevel+"] "+messageCode);
			switch (messageCode)
			{
				case "NetStream.Buffer.Empty":
					if (_streamStatus == STREAM_STOPPED)
					{
						_streamStatus=STREAM_FINISHED;
						super.dispatchEvent(new VideoPlayerBabeliaEvent(VideoPlayerBabeliaEvent.SECONDSTREAM_FINISHED_PLAYING));
					}
					else
						_streamStatus=STREAM_BUFFERING;
					break;
				case "NetStream.Buffer.Full":
					if (_streamStatus == STREAM_READY)
						_streamStatus=STREAM_STARTED;
					if (_streamStatus == STREAM_BUFFERING)
						_streamStatus=STREAM_STARTED;
					if (_streamStatus == STREAM_UNPAUSED)
						_streamStatus=STREAM_STARTED;
					
					break;
				case "NetStream.Buffer.Flush":
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
					break;
				case "NetStream.Connect.Closed":
					_connected=false;
					break;
				case "NetStream.Connect.Success":
					_connected=true;
					break;
				default:
					break;
			}
			
		}
		
		public function onStatus(event:StatusEvent):void{
			
		}
		
		
		/*
		 * Client object callbacks
		 */
		public function onCuePoint(cuePoint:Object):void{
			trace(ObjectUtil.toString(cuePoint));
		}
		
		public function onImageData(imageData:Object):void{
			//data
			var rawData:ByteArray = imageData.data as ByteArray;
		}
		
		public function onMetaData(metaData:Object):void{
			//height, widht, duration
			trace(ObjectUtil.toString(metaData));
		}
		
		public function onPlayStatus(playStatus:Object):void{
			//level, code
			trace(ObjectUtil.toString(playStatus));
		}
		
		public function onSeekPoint(seekPoint:Object):void{
			trace(ObjectUtil.toString(seekPoint));
		}
		
		public function onTextData(textData:Object):void{
			trace(ObjectUtil.toString(textData));
		}
		
		public function onXMPData(xmpData:Object):void{
			//data, a string The string is generated from a top-level UUID box. 
			//(The 128-bit UUID of the top level box is BE7ACFCB-97A9-42E8-9C71-999491E3AFAC.) This top-level UUID box contains exactly one XML document represented as a null-terminated UTF-8 string.
			trace(ObjectUtil.toString(xmpData));
		}
	}
}