package components.videoPlayer.timedevent
{
	public class EventTrigger
	{
		private var actionValues:Array;
		
		public function EventTrigger(actionValues:Array)
		{
			this.actionValues=actionValues;
		}
		
		public function executeActions():void{
			for each(var av:Object in actionValues){
				av.func(av.params);
			}
		}
	}
}