// ActionScript file
package vo
{
	
	[RemoteClass(alias="SubtitleLineVO")]
	[Bindable]
	public class SubtitleLineVO
	{
		public var id:int;
		public var subtitleId:int;
		public var showTime:Number;
		public var hideTime:Number;
		public var text:String;
		public var exerciseRoleId:int;
		public var exerciseRoleName:String;	
	}
}