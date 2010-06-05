package modules.configuration
{
	import flash.events.AsyncErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import model.DataModel;
	
	public class OflaDemoRed5Connection
	{
		private var nc:NetConnection;
		public var rec_ns:NetStream;
		public var play_ns:NetStream;
		
		public function OflaDemoRed5Connection()
		{
			nc = new NetConnection();
		}
		
		public function connect():void{
			nc.connect("rtmp://" + DataModel.getInstance().server + ":" + DataModel.getInstance().red5Port + "/oflaDemo");
			nc.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			nc.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrrorHandler);  
		}
		
		private function netStatusHandler(e:NetStatusEvent):void{   
			if(e.info.code == "NetConnection.Connect.Success"){
				rec_ns = new NetStream(nc);
				play_ns = new NetStream(nc); 
				rec_ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR,asyncErrrorHandler);
				play_ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR,asyncErrrorHandler);
			}else   
				//Problemas en la conexion
				trace(e.info.code); 
		}
			
		private function asyncErrrorHandler(e:AsyncErrorEvent):void{
			//No se usa, pero evita que aparezcan errores con flash player debugg version
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