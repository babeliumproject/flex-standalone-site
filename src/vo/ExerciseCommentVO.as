package vo
{
	[RemoteClass(alias="ExerciseCommentVO")]
	[Bindable]
	public class ExerciseCommentVO
	{
		
		public var id:int;
		public var exerciseId:int;
		public var userId:int;
		public var comment:String;
		public var commentDate:String;

	}
}