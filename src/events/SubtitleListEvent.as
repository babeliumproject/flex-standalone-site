package events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	public class SubtitleListEvent extends CairngormEvent
	{
		
		public const GET_EXERCISES_WITHOUT_SUBTITLES:String = "getExercisesWithoutSubtitles";
		public const GET_EXERCISES_WITH_SUBTITLES_TO_REVIEW:String = "getExercisesWithSubtitlesToReview";
		
		public userId:uint;
		
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