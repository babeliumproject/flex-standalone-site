package modules.subtitle.event
{
	
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;
	
	import vo.SubtitleLineVO;
	import vo.SubtitleAndSubtitleLinesVO;

	public class SubtitlesEvent extends CairngormEvent
	{
		
		public static const SAVE_SUBTITLES:String = "saveSubtitles";
		public var subtitles:SubtitleAndSubtitleLinesVO;
		
		public function SubtitlesEvent(type:String, subtitles:SubtitleAndSubtitleLinesVO = null)
		{
			super(type);
			this.subtitles = subtitles;
		}
		
		override public function clone():Event{
			return new SubtitlesEvent(type,subtitles);
		}
		
	}
}