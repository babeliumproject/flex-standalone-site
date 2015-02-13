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
		
		public var params:Object;
		
		public function UserVideoHistoryEvent(type:String, params:Object)
		{
			super(type);
			this.params = params;
			
		}
		
		override public function clone():Event{
			return new UserVideoHistoryEvent(type,params);
		}
	}
}