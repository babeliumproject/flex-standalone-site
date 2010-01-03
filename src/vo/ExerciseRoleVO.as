package vo
{

	[RemoteClass(alias="ExerciseRoleVO")]
	[Bindable]
	public class ExerciseRoleVO
	{
		public var id:int;
		public var exerciseId:int;
		public var userId:int;

		public var characterName:String;
	}
}