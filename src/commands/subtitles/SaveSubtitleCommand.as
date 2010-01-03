package commands.subtitles
{
	import business.SubtitleDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import events.SubtitleEvent;
	
	import model.DataModel;
	
	import mx.controls.Alert;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ObjectUtil;

	public class SaveSubtitleCommand implements ICommand, IResponder
	{

		public function execute(event:CairngormEvent):void
		{
			new SubtitleDelegate(this).saveSubtitle((event as SubtitleEvent).subtitle);
		}
		
		public function result(data:Object):void
		{
			//We check if the insert went well by checking the last_insert_id value
			if (!data.result is int){
				Alert.show("Your subtitle couldn't be saved properly");
			} else {
				DataModel.getInstance().subtileSaveId = int(data.result);
				DataModel.getInstance().subtitleSaved = true;
			}
		}
		
		public function fault(info:Object):void
		{
			var faultEvent: FaultEvent = FaultEvent(info);
			Alert.show("Error while saving your subtitles: "+faultEvent.message);
			trace(ObjectUtil.toString(info));
		}
		
	}
}