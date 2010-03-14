package events
{
	
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;
	
	import vo.SubtitleLineVO;
	import vo.SubtitleAndSubtitleLinesVO;

	public class SubtitleEvent extends CairngormEvent
	{
		
		public static const SAVE_SUBTITLE:String = "saveSubtitle";
		public static const SAVE_SUBTITLE_LINES:String = "saveSubtitleLines";
		public static const GET_SUBTITLE_LINES:String = "getSubtitleLines";
		public var subtitle:SubtitleAndSubtitleLinesVO;
		public var lines:SubtitleLineVO;

		
		public function SubtitleEvent(type:String, subtitle:SubtitleAndSubtitleLinesVO = null, lines:SubtitleLineVO = null)
		{
			super(type);
			this.subtitle = subtitle;
			this.lines = lines;
		}
		
		override public function clone():Event{
			return new SubtitleEvent(type,subtitle,lines);
		}
		
	}
}