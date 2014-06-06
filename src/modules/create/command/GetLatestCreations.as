package modules.create.command
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import modules.create.service.CreateDelegate;
	
	import mx.rpc.IResponder;
	
	public class GetLatestCreations implements ICommand, IResponder
	{	
		public function execute(event:CairngormEvent):void
		{
			var params:Object = Object(event).exercisedata;
			new CreateDelegate(this).getLatestCreations();
		}
		
		public function result(data:Object):void
		{
		}
		
		public function fault(info:Object):void
		{
		}
	}
}