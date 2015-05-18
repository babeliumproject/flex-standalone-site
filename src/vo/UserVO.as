package vo
{
	[RemoteClass(alias="UserVO")]
   	[Bindable]
	public class UserVO
	{
		public var id:int;
		public var username:String;
		public var email:String;
		public var creditCount:int;
		public var firstname:String;
		public var lastname:String;
		public var active:Boolean;
		public var joiningDate:String;
		public var isAdmin:Boolean;
		
		//An array of UserLanguageVO objects
		public var userLanguages:Array;
		public var permissions:Object;
	}
}
