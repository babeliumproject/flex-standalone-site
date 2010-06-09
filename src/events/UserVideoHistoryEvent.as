package events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import vo.UserVideoHistoryVO;
	
	public class UserVideoHistoryEvent extends CairngormEvent
	{
		
		public static const EXERCISE_WATCH:String = "exerciseWatch";
		public static const ATTEMPT_RESPONSE:String = "attemptResponse";
		public static const SAVE_RESPONSE:String = "saveResponse";
		
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