package modules.configuration
{
	import flash.errors.IOError;
	import flash.events.AsyncErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.NetConnection;

	public class Red5Connection
	{
		import model.DataModel;

		private var nc:NetConnection;
		private var uri:String;

		public function Red5Connection(app:String)
		{
			nc=new NetConnection();
			//nc.addEventListener(NetStatusEvent.NET_STATUS, netStatus);
			nc.addEventListener(AsyncErrorEvent.ASYNC_ERROR, netASyncError);
			nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, netSecurityError);
			nc.addEventListener(IOErrorEvent.IO_ERROR, netIOError);
			try
			{
				uri = "rtmp://" + DataModel.getInstance().server + ":" + DataModel.getInstance().streamingPort + "/" + app;
				nc.connect(uri);
			}
			catch (e:ArgumentError)
			{
				trace("["+e.name+"] "+e.errorID +" "+ e.message);
			}
			catch (e:IOError)
			{
				trace("["+e.name+"] "+e.errorID +" "+ e.message);
			}
			catch (e:SecurityError)
			{
				trace("["+e.name+"] "+e.errorID +" "+ e.message);
			}
			catch (e:Error)
			{
				trace("["+e.name+"] "+e.errorID +" "+ e.message);
			}
		}
		
		protected function netSecurityError(event:SecurityErrorEvent):void
		{
			trace("["+event.type+"] "+event.text);
		}
		
		protected function netIOError(event:IOErrorEvent):void
		{
			trace("["+event.type+"] "+event.text);
		}
		
		protected function netASyncError(event:AsyncErrorEvent):void
		{
			trace("["+event.type+"] "+event.text);
		}

		public function getNetConnection():NetConnection
		{
			return nc;
		}

	}
}