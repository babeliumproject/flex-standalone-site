package vo
{
	[RemoteClass(alias="UserVO")]
   	[Bindable]
	public class UserVO
	{
		public var id:int;
		public var name:String;
		public var email:String;
		public var creditCount:int;
	}
}