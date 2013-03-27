package modules.videoPlayer
{
	import flash.events.AsyncErrorEvent;
	import flash.events.DRMErrorEvent;
	import flash.events.DRMStatusEvent;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NetDataEvent;
	import flash.events.NetStatusEvent;
	import flash.events.StatusEvent;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.NetStreamInfo;
	import flash.utils.ByteArray;
	
	import modules.videoPlayer.events.babelia.VideoPlayerBabeliaEvent;
	
	import mx.utils.ObjectUtil;
	
	//http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/net/NetStream.html

	public class NetStreamClient extends EventDispatcher implements INetStreamCallbacks
	{
		//Consider using a logging api such as as3commons
		public static const DEBUG:int=0x0020;
		public static const ERROR:int=0x0004;
		public static const FATAL:int=0x0002;
		public static const INFO:int=0x0010;
		public static const WARN:int=0x0008;
		
		public static const STREAM_READY:int=0;
		public static const STREAM_STARTED:int=1;
		public static const STREAM_STOPPED:int=2;
		public static const STREAM_FINISHED:int=3;
		public static const STREAM_PAUSED:int=4;
		public static const STREAM_UNPAUSED:int=5;
		public static const STREAM_BUFFERING:int=6;
		
		private var _ns:NetStream;
		private var _nc:NetConnection;
		private var _name:String;
		private var _connected:Boolean;
		private var _streamStatus:uint;
		private var _videoWidth:uint;
		private var _videoHeight:uint;
		private var _duration:Number;
		private var _hasVideo:Boolean;
		private var _hasAudio:Boolean;
		private var _metaData:Object;
		
		/*
		 * Functions
		 */
		public function NetStreamClient(connection:NetConnection, name:String)
		{
			try{
				super();
				_ns = new NetStream(connection);
				_ns.client = this;	
				_ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError);
				_ns.addEventListener(DRMErrorEvent.DRM_ERROR, onDrmError);
				_ns.addEventListener(DRMStatusEvent.DRM_STATUS, onDrmStatus);
				_ns.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
				_ns.addEventListener(NetDataEvent.MEDIA_TYPE_DATA, onMediaTypeData);
				_ns.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
				_ns.addEventListener(StatusEvent.STATUS, onStatus);
			
				_nc = connection;
				_name=name;
				_connected=true;
				
			} catch(e:Error){
				//netconnection is not connected
				_connected=false;
				displayTrace("Error ["+e.name+"] "+e.message);
			}
		}
		
		private function displayTrace(message:String, level:uint=0x0001):void{
			var msg:String = message;
			if(_name)
				msg = "["+_name+"] "+message;
			trace(msg);
		}
		
		public function play(...parameters):void{
			try{
				displayTrace("Play "+parameters);
				_ns.play(parameters);	
			} 
			catch(e:SecurityError){
				displayTrace("SecurityError ["+e.name+"] "+e.message);
			}
			catch(e:ArgumentError){
				displayTrace("ArgumentError ["+e.name+"] "+e.message);
			}
			catch(e:Error){
				displayTrace("Error ["+e.name+"] "+e.message);
				_connected=false;
			}
		}
		
		/*
		 * Getters and setters
		 */
		public function get netStream():NetStream{
			return (_ns && _connected) ? _ns : null;		
		}
		
		public function get hasVideo():Boolean{
			return _hasVideo;
		}
		
		public function get hasAudio():Boolean{
			return _hasAudio;
		}
		
		public function get videoWidth():uint{
			return _videoWidth;
		}
		
		public function get videoHeight():uint{
			return _videoHeight;
		}
		
		public function get duration():Number{
			return _duration;
		}
		
		public function get metaData():Object{
			return _metaData;
		}
		
		/*
		 * Event listeners
		 */
		public function onAsyncError(event:AsyncErrorEvent):void{
			displayTrace("AsyncError "+event.error.name+" "+event.error.message);
		}
		
		public function onDrmError(event:DRMErrorEvent):void{
			displayTrace("DRMError");
		}
		
		public function onDrmStatus(event:DRMStatusEvent):void{
			displayTrace("DRMStatus");
		}
		
		public function onIoError(event:IOErrorEvent):void{
			displayTrace("IOError "+event.target.toString() + " " + event.text);
		}
		
		public function onMediaTypeData(event:NetDataEvent):void{
			displayTrace("MediaTypeData event listener",INFO);
		}
		
		public function onNetStatus(event:NetStatusEvent):void{
			var info:Object=event.info;
			var messageClientId:int=info.clientid?info.clientid:-1;
			var messageCode:String=info.code;
			var messageDescription:String=info.description?info.description:null;
			var messageDetails:String=info.details?info.details:null;
			var messageLevel:String=info.level;
			
			displayTrace("NetStatus ["+messageLevel+"] "+messageCode+" "+messageDescription);
			switch (messageCode)
			{
				case "NetStream.Buffer.Empty":
					if (_streamStatus == STREAM_STOPPED)
					{
						_streamStatus=STREAM_FINISHED;
						this.dispatchEvent(new VideoPlayerBabeliaEvent(VideoPlayerBabeliaEvent.SECONDSTREAM_FINISHED_PLAYING));
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
			displayTrace(ObjectUtil.toString(event));
		}
		
		
		/*
		 * Client object callbacks
		 */
		public function onCuePoint(cuePoint:Object):void{
			displayTrace(ObjectUtil.toString(cuePoint));
		}
		
		public function onImageData(imageData:Object):void{
			var rawData:ByteArray = imageData.data as ByteArray;
			displayTrace("ImageData callback",INFO);
		}
		
		public function onMetaData(metaData:Object):void{
			_metaData=metaData;
			_duration=metaData.duration;
			_videoWidth=metaData.width?metaData.width:0;
			_videoHeight=metaData.height?metaData.height:0;
			_hasVideo=(metaData.videocodecid&&metaData.videocodecid!=-1)?true:false;
			_hasAudio=(metaData.audiocodecid&&metaData.audiocodecid!=-1)?true:false;
			displayTrace("MetaData callback",INFO);
			displayTrace(ObjectUtil.toString(metaData),DEBUG);
		}
		
		public function onPlayStatus(playStatus:Object):void{
			//level, code
			displayTrace(ObjectUtil.toString(playStatus));
		}
		
		public function onSeekPoint(seekPoint:Object):void{
			displayTrace(ObjectUtil.toString(seekPoint));
		}
		
		public function onTextData(textData:Object):void{
			displayTrace(ObjectUtil.toString(textData));
		}
		
		public function onXMPData(xmpData:Object):void{
			//data, a string The string is generated from a top-level UUID box. 
			//(The 128-bit UUID of the top level box is BE7ACFCB-97A9-42E8-9C71-999491E3AFAC.) This top-level UUID box contains exactly one XML document represented as a null-terminated UTF-8 string.
			displayTrace(ObjectUtil.toString(xmpData));
		}
	}
}