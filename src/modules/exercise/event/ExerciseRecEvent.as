package modules.exercise.event
{
	import flash.events.Event;

	public class ExerciseRecEvent extends Event
	{
		public static const WEBCAM:String = "webcam";
		public static const MIC:String = "mic"; 
		
		public function ExerciseRecEvent(eventName:String){
			super(eventName);
		}
		
	}
}