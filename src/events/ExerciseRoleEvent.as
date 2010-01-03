package events
{	
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;
	
	import vo.ExerciseRoleVO;

	public class ExerciseRoleEvent extends CairngormEvent
	{
		
		public static const GET_EXERCISE_ROLES:String = "getExerciseRoles";
		public static const DELETE_SINGLE_EXERCISE_ROL:String = "deleteSingleExerciseRol";
		public static const DELETE_ALL_EXERCISE_ROLES:String = "deleteAllExerciseRoles";
		public static const SAVE_EXERCISE_ROLES:String = "saveExerciseRoles";
		
		public var rol:ExerciseRoleVO;
		public var roles:Array;

		
		public function ExerciseRoleEvent(type:String, rol:ExerciseRoleVO = null, roles:Array = null)
		{
			super(type);
			this.rol   = rol ;
			this.roles = roles ;
		}
		
		override public function clone():Event{
			return new ExerciseRoleEvent(type,rol,roles);
		}
		
	}
}