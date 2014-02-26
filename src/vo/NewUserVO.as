package vo
{
	[RemoteClass(alias="NewUserVO")]
   	[Bindable]
	public class NewUserVO
	{
		public var username:String;
		public var password:String;
     	public var firstname:String;
     	public var lastname:String;
		public var email:String;
		public var activationHash:String;
		
		//Stores the languages the user knows or is interested in
		public var languages:Array;
		
		public function NewUserVO(username:String, password:String, firstname:String, lastname:String, email:String, activationHash:String, languages:Array){
			
			this.username = username;
			this.password = password;
			this.firstname = firstname;
			this.lastname = lastname;
			this.email = email;
			this.activationHash = activationHash;
			this.languages = languages;

		}
		
		
	}
}
