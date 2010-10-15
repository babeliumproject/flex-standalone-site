package commands.subtitles
{
	import business.SubtitleDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import events.SubtitleEvent;
	
	import model.DataModel;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ArrayUtil;
	import mx.utils.ObjectUtil;
	
	import view.common.CustomAlert;
	
	public class GetExerciseSubtitlesCommand implements ICommand, IResponder
	{
		
		public function execute(event:CairngormEvent):void
		{
			new SubtitleDelegate(this).getExerciseSubtitles((event as SubtitleEvent).subtitle);
		}
		
		public function result(data:Object):void
		{
			var result:Object=data.result;
			var resultCollection:ArrayCollection;
			
			if (result is Array && (result as Array).length > 0){
				resultCollection=new ArrayCollection(ArrayUtil.toArray(result));
				DataModel.getInstance().availableSubtitles = resultCollection;
			} else {
				DataModel.getInstance().availableSubtitles = new ArrayCollection();
			}
			DataModel.getInstance().availableSubtitlesRetrieved = !DataModel.getInstance().availableSubtitlesRetrieved;
		}
		
		public function fault(info:Object):void
		{
			var faultEvent:FaultEvent=FaultEvent(info);
			CustomAlert.error("Error while retrieving this exercise's subtitles.");
			trace(ObjectUtil.toString(info));
		}
	}
}