package components.videoPlayer.timedevent
{
	import mx.utils.ObjectUtil;

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