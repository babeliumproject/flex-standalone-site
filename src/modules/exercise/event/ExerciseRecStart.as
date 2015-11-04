package modules.exercise.event
{
	import flash.events.Event;

	public class ExerciseRecStart extends Event
	{
		public static const REC_START:String = "rec_start";
		
		public function ExerciseRecStart(eventName:String){
			super(eventName);
		}
		
	}
}