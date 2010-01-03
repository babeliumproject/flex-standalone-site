package vo
{	
	[RemoteClass(alias="SubtitleVO")];
	[Bindable]
	public class SubtitleVO
	{
		public var id:int;
		public var exerciseId:int;
		public var userId:int;
		public var language:String;
		public var translation:Boolean;
		public var addingDate:String;

	}
}