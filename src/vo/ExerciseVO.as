package vo
{

	[RemoteClass(alias="ExerciseVO")]
	[Bindable]
	public class ExerciseVO
	{
		public var id:int;
		public var exercisecode:String;
		public var title:String;
		public var description:String;
		public var language:String;
		public var difficulty:*;
		public var timecreated:uint;
		public var timemodified:uint;
		public var status:String;
		
		public var userName:String;
		public var userId:uint;
		
		public var transcriptionId:int;

		
		public var avgRating:Number;
		public var ratingCount:int; //used for bayesian average rating calculation
		
		
		public var isSubtitled:uint;
		
		public var tags:*;
		public var descriptors:*;
		public var related:*;
		public var media:*;
		
		public var score:Number; //is used to sort the searches
		public var idIndex:int; //is used to delete exercises
		public var itemSelected:Boolean; //Determines whether this object is selected in a customRenderer list-based control

	}
}