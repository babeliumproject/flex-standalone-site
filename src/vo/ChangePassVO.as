package vo
{
	[RemoteClass(alias="ChangePassVO")]
	[Bindable]
	public class ChangePassVO
	{
		public var id:int;
		public var oldpass:String;
		public var newpass:String;
		
		public function ChangePassVO(id:int, oldpass:String, newpass:String)
		{
			this.id = id;
			this.oldpass = oldpass;
			this.newpass = newpass;
		}
	}
}