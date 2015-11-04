package modules.exercise.model
{
	import mx.collections.ArrayCollection;

	[Bindable]
	public class ExerciseModel
	{
		public var exercises:ArrayCollection;
		
		public var exerciserated:Boolean;
		public var exercisereported:Boolean;
		public var exercisesubmitted:Boolean;
	}
}