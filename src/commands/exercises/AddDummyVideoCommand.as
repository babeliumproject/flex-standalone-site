package commands.exercises
{
	import business.ResponseDelegate;

	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;

	import events.ResponseEvent;

	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;

	public class AddDummyVideoCommand implements ICommand, IResponder
	{

		public function execute(event:CairngormEvent):void
		{
			new ResponseDelegate(this).addDummyVideo((event as ResponseEvent).response);
		}

		public function result(data:Object):void
		{
			if (data.result)
			{
				var responseId:String=data.result.toString();
			}
		}

		public function fault(info:Object):void
		{
			//Info is not always a FaultEvent, so cast it just in case
			var faultEvent:FaultEvent=FaultEvent(info);
			trace("ERROR [" + faultEvent.fault.faultCode + "]: " + faultEvent.fault.faultString);
		}
	}
}
