package commands.subtitles
{
	import business.SubtitleDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import events.CreditEvent;
	import events.SubtitlesAndRolesEvent;
	import events.SubtitlesEvent;
	
	import model.DataModel;
	
	import mx.controls.Alert;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ObjectUtil;

	public class SaveSubtitlesCommand implements ICommand, IResponder
	{

		public function execute(event:CairngormEvent):void
		{
			new SubtitleDelegate(this).saveSubtitles((event as SubtitlesEvent).subtitles);
		}
		
		public function result(data:Object):void
		{
			//We check if the insert went well by checking the last_insert_id value
			if (!data.result is int){
				Alert.show("Your subtitles couldn't be saved properly");
			} else {
				// Add some credits to the user to award the colaboration
				var loggedUser:int = DataModel.getInstance().loggedUser.id;
				new CreditEvent(CreditEvent.ADD_CREDITS_FOR_SUBTITLING, loggedUser).dispatch();
				//Notify the listeners that the subtitles have been saved
				DataModel.getInstance().subtitleSaved = true;
			}
		}
		
		public function fault(info:Object):void
		{
			var faultEvent: FaultEvent = FaultEvent(info);
			Alert.show("Error while saving your subtitles: \n"+faultEvent.message);
			trace(ObjectUtil.toString(info));
		}
		
	}
}