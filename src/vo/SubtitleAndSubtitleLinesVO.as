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

		public function SubtitleAndSubtitleLinesVO(id:int=0, exerciseId:int=0, userId:int=0, language:String=null, translation:Boolean=false, addingDate:String=null, subtitleLines:Array=null)
		{
			this.id=id;
			this.exerciseId=exerciseId;
			this.userId=userId;
			this.language=language;
			this.translation=translation;
			this.addingDate=addingDate;
			this.subtitleLines=subtitleLines;
		}

	}
}