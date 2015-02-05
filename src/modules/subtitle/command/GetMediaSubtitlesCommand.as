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
		private var _model:DataModel=DataModel.getInstance();
		
		public function execute(event:CairngormEvent):void
		{
			new SubtitleDelegate(this).getMediaSubtitles((event as SubtitleEvent).params);
		}
		
		public function result(data:Object):void
		{
			var result:Object=data.result;
			var mediaData:Object=null;
			var mediaSubtitles:ArrayCollection=null;
			
			if(result){
				if(result.hasOwnProperty('media')){
					mediaData = result.media;
				}
				if(result.hasOwnProperty('subtitles') && result.subtitles){
					mediaSubtitles=new ArrayCollection(ArrayUtil.toArray(result.subtitles));
				}
			}
			_model.subtitleMedia=mediaData;
			_model.availableSubtitles=mediaSubtitles;
			
			//Set to null until a service call to retrieve subtitle lines changes its value
			_model.availableSubtitleLines=null;
			_model.unmodifiedAvailableSubtitleLines=null;
			_model.availableExerciseRoles=null;
			
			_model.availableSubtitlesRetrieved = !_model.availableSubtitlesRetrieved;
		}
		
		public function fault(info:Object):void
		{
			var faultEvent:FaultEvent=FaultEvent(info);
			CustomAlert.error(ResourceManager.getInstance().getString('myResources','ERROR_WHILE_RETRIEVING_EXERCISE_SUBTITLES'));
			trace(ObjectUtil.toString(info));
		}
	}
}