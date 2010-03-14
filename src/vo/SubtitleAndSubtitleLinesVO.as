package vo
{

	[RemoteClass(alias="SubtitleAndSubtitleLinesVO")];
	[Bindable]
	public class SubtitleAndSubtitleLinesVO
	{
		public var id:int;
		public var exerciseId:int;
		public var userId:int;
		public var language:String;
		public var translation:Boolean;
		public var addingDate:String;
		
		public var subtitleLines:Array;

	}
}