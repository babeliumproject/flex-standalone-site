package events
{
	
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;
	
	import vo.SubtitleLineVO;
	import vo.SubtitleAndSubtitleLinesVO;

	public class SubtitleEvent extends CairngormEvent
	{
		
		public static const SAVE_SUBAND_SUBLINES:String = "saveSubtitle";
		public static const GET_EXERCISE_SUBLINES:String = "getSubtitleLines";
		public static const GET_EXERCISE_SUBTITLES:String = "getExerciseSubtitles";
		public var subtitle:SubtitleAndSubtitleLinesVO;

		
		public function SubtitleEvent(type:String, subtitle:SubtitleAndSubtitleLinesVO = null)
		{
			super(type);
			this.subtitle = subtitle;
		}
		
		override public function clone():Event{
			return new SubtitleEvent(type,subtitle);
		}
		
	}
}