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
		
		public function play(s:String):void{
			if (s=='video'){
				play_ns.play(DataModel.getInstance().loggedUser.name + "ConfigurationVideo.flv");
			}else{
				play_ns.play(DataModel.getInstance().loggedUser.name + "ConfigurationAudio.flv");
			}
		}
		
		public function publish(s:String):void{
			if (s=='video'){
				rec_ns.publish(DataModel.getInstance().loggedUser.name + "ConfigurationVideo", 'record');
			}else{
				rec_ns.publish(DataModel.getInstance().loggedUser.name + "ConfigurationAudio", 'record');
			}
		}

	}
}