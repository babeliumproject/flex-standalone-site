package events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;
	
	import vo.UserVideoHistoryVO;
	
	public class UserVideoHistoryEvent extends CairngormEvent
	{
		
		public static const STAT_EXERCISE_WATCH:String = "statExerciseWatch";
		public static const STAT_ATTEMPT_RESPONSE:String = "statAttemptResponse";
		public static const STAT_SAVE_RESPONSE:String = "statSaveResponse";
		
		public var videoHistoryData:UserVideoHistoryVO;
		
		public function UserVideoHistoryEvent(type:String, videoHistoryData:UserVideoHistoryVO)
		{
			super(type);
			this.videoHistoryData = videoHistoryData;
			
		}
		
		override public function clone():Event{
			return new UserVideoHistoryEvent(type,videoHistoryData);
		}
	}
}