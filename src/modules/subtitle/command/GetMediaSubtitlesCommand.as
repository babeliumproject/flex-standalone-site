package modules.subtitle.command
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import model.DataModel;
	
	import modules.subtitle.event.SubtitleEvent;
	import modules.subtitle.service.SubtitleDelegate;
	
	import mx.collections.ArrayCollection;
	import mx.resources.ResourceManager;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ArrayUtil;
	import mx.utils.ObjectUtil;
	
	import view.common.CustomAlert;
	
	public class GetMediaSubtitlesCommand implements ICommand, IResponder
	{
		
		public function execute(event:CairngormEvent):void
		{
			new SubtitleDelegate(this).getMediaSubtitles((event as SubtitleEvent).params);
		}
		
		public function result(data:Object):void
		{
			var result:Object=data.result;
			var resultCollection:ArrayCollection;
			trace(ObjectUtil.toString(result));
			if (result is Array && (result as Array).length > 0){
				resultCollection=new ArrayCollection(ArrayUtil.toArray(result));
				DataModel.getInstance().availableSubtitles = resultCollection;
			} else {
				DataModel.getInstance().availableSubtitles = null;
			}
			DataModel.getInstance().availableSubtitlesRetrieved = !DataModel.getInstance().availableSubtitlesRetrieved;
		}
		
		public function fault(info:Object):void
		{
			var faultEvent:FaultEvent=FaultEvent(info);
			CustomAlert.error(ResourceManager.getInstance().getString('myResources','ERROR_WHILE_RETRIEVING_EXERCISE_SUBTITLES'));
			trace(ObjectUtil.toString(info));
		}
	}
}