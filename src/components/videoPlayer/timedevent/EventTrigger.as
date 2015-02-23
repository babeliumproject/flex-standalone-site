package components.videoPlayer.timedevent
{
	import mx.utils.ObjectUtil;

	public class EventTrigger
	{
		public var time:Number;
		public var duration:Number;
		private var actionValues:Array;
		
		public function EventTrigger(actionValues:Array, time:Number=NaN, duration:Number=NaN)
		{
			this.actionValues=actionValues;
			this.time=time;
			this.duration=duration;
		}
		
		public function executeActions():void{
			for each(var av:Object in actionValues){
				if(av.params==null)
					av.func();
				else
					av.func(av.params);
			}
		}
	}
}