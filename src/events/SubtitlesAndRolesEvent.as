package events
{
	
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;
	
	import vo.SubtitlesAndRolesVO;
	
	public class SubtitlesAndRolesEvent extends CairngormEvent
	{
		public static const GET_INFO_SUB_ROLES:String ="getInfoSubRoles";
		public var info:SubtitlesAndRolesVO;
		
		public function SubtitlesAndRolesEvent(type:String, info:SubtitlesAndRolesVO=null)
		{
			super(type);
			this.info = info;
			
		}
		
		override public function clone():Event{
			return new SubtitlesAndRolesEvent(type,info);
		}
		
	}
}