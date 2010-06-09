package commands.exercises
{
	import business.VideoHistoryDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import events.UserVideoHistoryEvent;
	
	import mx.rpc.IResponder;
	
	import view.common.CustomAlert;
	
	public class VideoHistorySaveCommand implements ICommand, IResponder
	{	
		public function execute(event:CairngormEvent):void
		{
			new VideoHistoryDelegate(this).exerciseSaveResponse((event as UserVideoHistoryEvent).videoHistoryData;
		}
		
		public function result(data:Object):void
		{
			//Do nothing, for now
		}
		
		public function fault(info:Object):void
		{
			CustomAlert.error("Error while adding item to your video history.");
			trace(ObjectUtil.toString(info));
		}
	}
}