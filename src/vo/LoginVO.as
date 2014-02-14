package vo
{
	[RemoteClass(alias="LoginVO")]
	[Bindable]
	public class LoginVO
	{
		public var username:String;
		public var password:String;
		
		public function LoginVO(username:String, password:String)
		{
			this.username = username;
			this.password = password;
		}
	}
}
