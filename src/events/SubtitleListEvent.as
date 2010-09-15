package events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;
	
	public class SubtitleListEvent extends CairngormEvent
	{
		
		public static const GET_EXERCISES_WITHOUT_SUBTITLES:String = "getExercisesWithoutSubtitles";
		public static const GET_EXERCISES_WITH_SUBTITLES_TO_REVIEW:String = "getExercisesWithSubtitlesToReview";
		
		public var userId:uint;
		
		public function SubtitleListEvent(type:String, userId:uint)
		{
			super(type);
			this.userId = userId;
		}
		
		override public function clone():Event{
			return new SubtitleListEvent(type,userId);
		}
	}
}