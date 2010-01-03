package commands.subtitles
{
	import business.SubtitleDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import events.SubtitleEvent;
	
	import mx.controls.Alert;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ObjectUtil;

	public class SaveSubtitleLinesCommand implements ICommand, IResponder
	{

		public function execute(event:CairngormEvent):void
		{
			new SubtitleDelegate(this).saveSubtitleLines((event as SubtitleEvent).subtitle);
	
		}
		
		public function result(data:Object):void
		{
			if (!data.result is int){
				Alert.show("Your subtitle lines couldn't be saved properly");
			} else {
				//Fire credit adding functions.
			}
		}
		
		public function fault(info:Object):void
		{
			var faultEvent: FaultEvent = FaultEvent(info);
			Alert.show("Error while saving your subtitle lines: "+faultEvent.message);
			trace(ObjectUtil.toString(info));
		}
		
	}
}