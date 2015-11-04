package modules.subtitle.event
{
	
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;
	
	import vo.SubtitleLineVO;
	import vo.SubtitleAndSubtitleLinesVO;

	public class SubtitleEvent extends CairngormEvent
	{
		
		public static const SAVE_SUBAND_SUBLINES:String = "saveSubtitle";
		public static const GET_EXERCISE_SUBLINES:String = "getSubtitleLines";
		
		public static const GET_MEDIA_SUBTITLES:String = "getMediaSubtitles";
		
		public var params:Object;

		
		public function SubtitleEvent(type:String, params:Object = null)
		{
			super(type);
			this.params = params;
		}
		
		override public function clone():Event{
			return new SubtitleEvent(type,params);
		}
		
	}
}