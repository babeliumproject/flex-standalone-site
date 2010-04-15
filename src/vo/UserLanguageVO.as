package vo
{
	[RemoteClass(alias="UserLanguageVO")]
	[Bindable]
	public class UserLanguageVO
	{
		public var id:int;
		public var userId:int;
		public var language:String; //Use the language's two digit code: ES, EU, FR, EN...
		public var level:int; //Level goes from 1 to 6. 7 used for mother tongue
		public var positives_to_next_level:int; //An indicator of how many assessments or steps are needed to advance to the next level
	
		public function UserLanguageVO(id:int, userId:int, language:String, level:int, positives_to_next_level:int){
			this.id = id;
			this.userId = userId;
			this.language = language;
			this.level = level;
			this.positives_to_next_level = positives_to_next_level;
		}
		
	}
}