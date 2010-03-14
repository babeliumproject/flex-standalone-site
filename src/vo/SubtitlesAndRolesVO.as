package vo
{
	[RemoteClass(alias="SubtitlesAndRolesVO")]
	[Bindable]
	public class SubtitlesAndRolesVO
	{
		public var id:int;
		public var subtitleId:int;
		public var showTime:Number;
		public var hideTime:Number;
		public var text:String;
		public var language:String;	
		public var roleId:int;
		public var exerciseId:int;
		public var userId:int;		
		public var singleName:String;
		public var role:String;
	}
}