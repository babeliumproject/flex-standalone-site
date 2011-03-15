package modules.configuration
{
	import events.StartConnectionEvent;
	
	import flash.events.AsyncErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import model.DataModel;
	
	import mx.binding.utils.BindingUtils;
	
	public class OflaDemoRed5Sentences
	{
		
		public var rec_ns:NetStream;
		public var play_ns:NetStream;
		public var nc:NetConnection;
		
		public var audioFilename:String;
		public var videoFilename:String;
		
		private const CONFIG_FOLDER:String=DataModel.getInstance().configStreamsFolder;
		
		public function OflaDemoRed5Sentences()
		{
			BindingUtils.bindSetter(netStatusHandler, DataModel.getInstance(), "netConnected");
		}
		
		public function connect():void{
			if (DataModel.getInstance().netConnection.connected == false)
				new StartConnectionEvent(DataModel.getInstance().streamingResourcesPath).dispatch();
			else
				netStatusHandler(false);
		}
		
		private function netStatusHandler(value:Boolean):void{   
			if (DataModel.getInstance().netConnected == true)
			{
				nc = DataModel.getInstance().netConnection;
				rec_ns = new NetStream(nc);
				play_ns = new NetStream(nc); 
				rec_ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR,asyncErrrorHandler);
				play_ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR,asyncErrrorHandler);
			} else {
				//Streaming server connection = false;
			}
		}
			
		private function asyncErrrorHandler(e:AsyncErrorEvent):void{
			//Not used but avoids error display in flash debugger version
		}
		
		public function closeNetStreamObjects():void{
			rec_ns.close();
			play_ns.close();
		}
		
		public function play(mediaType:String):void{
			if (mediaType=='video')
				play_ns.play(videoFilename);
			else
				play_ns.play(audioFilename);
		}
		
		public function publish(mediaType:String):void{
			
			var d:Date=new Date();
			var fileName:String;
			
			if(mediaType == 'video') {
				fileName = "conf-video-" + d.getTime().toString();
				videoFilename=CONFIG_FOLDER + "/" + fileName;
				rec_ns.publish(videoFilename, 'record');
			} else {
				fileName = "conf-audio-" + d.getTime().toString();
				audioFilename=CONFIG_FOLDER + "/" + fileName;
				rec_ns.publish(audioFilename, 'record');
			}
		}

	}
}