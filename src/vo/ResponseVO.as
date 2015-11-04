package vo
{
	[RemoteClass(alias="ResponseVO")]
	[Bindable]
	public class ResponseVO
	{
		public var id:int;
		public var exerciseId:int;
		public var mediaId:int;
		public var fileIdentifier:String;
		public var isPrivate:Boolean;
		public var thumbnailUri:String;
		public var source:String;
		public var duration:int;
		public var addingDate:String;
		public var ratingAmount:int;
		public var characterName:String;
		public var transcriptionId:int;
		public var subtitleId:int;
		
		
		public function ResponseVO(id:int=0, exerciseId:int=0, fileIdentifier:String=null, isPrivate:Boolean=false, thumbnailUri:String=null, source:String=null, duration:int=0, addingDate:String=null, ratingAmount:int=0, characterName:String=null, transcriptionId:int=0, subtitleId:int=0){
			this.id = id;
			this.exerciseId = exerciseId;
			this.fileIdentifier = fileIdentifier;
			this.isPrivate = isPrivate;
			this.thumbnailUri = thumbnailUri;
			this.source = source;
			this.duration = duration;
			this.addingDate = addingDate;
			this.ratingAmount = ratingAmount;
			this.characterName = characterName;
			this.transcriptionId = transcriptionId;
			this.subtitleId = subtitleId;
		}
		

	}
}