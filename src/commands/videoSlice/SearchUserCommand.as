package commands.videoSlice
{
	import business.YouTubeDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.HTTPStatusEvent;
	
	import model.DataModel;
	
	import mx.controls.Alert;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ObjectUtil;

	public class SearchUserCommand implements ICommand, IResponder
	{
		
		public function execute(event:CairngormEvent):void
		{
			new YouTubeDelegate(this).retrieveUserVideo(DataModel.getInstance().userSearch);
		}
		
		public function result(data:Object):void
		{
			var ytVideoId:String = data.result as String;
			DataModel.getInstance().tempVideoSlice.name = ytVideoId;
			DataModel.getInstance().retrieveUserVideoComplete = true;
			
		}
		
		public function fault(info:Object):void
		{
			var faultEvent:FaultEvent=FaultEvent(info);
			Alert.show("Error while retrieving video:" + faultEvent.message);
			trace(ObjectUtil.toString(info));
		}
		
	}
}