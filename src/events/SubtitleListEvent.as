package events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;
	
	public class SubtitleListEvent extends CairngormEvent
	{
		
		public static const GET_EXERCISES_WITHOUT_SUBTITLES:String = "getExercisesWithoutSubtitles";
		public static const GET_EXERCISES_WITH_SUBTITLES_TO_REVIEW:String = "getExercisesWithSubtitlesToReview";
		
		public function SubtitleListEvent(type:String)
		{
			super(type);
		}
		
		override public function clone():Event{
			return new SubtitleListEvent(type);
		}
	}
}