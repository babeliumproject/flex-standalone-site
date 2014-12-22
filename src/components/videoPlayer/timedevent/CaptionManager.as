package components.videoPlayer.timedevent
{
	public class CaptionManager extends TimelineActionDispatcher
	{
		public function CaptionManager()
		{
			super();
		}
		
		public function parseCaptions(captions:Object, targetInstance:Object):Boolean
		{
			if (!captions || !targetInstance)
				return false;
			this.targetInstance=targetInstance;
			var time:Number;
			eventList = new Array();
			for (var timestamp:String in captions)
			{
				time=timeToSeconds(timestamp);
				if (!isNaN(time))
				{
					var actval:Array = new Array();
					var p:Object=captions[timestamp];
					var closure:*=targetInstance[p['action']];
					if(closure != null) actval.push({func: (closure as Function), params: p.value});
					var event:EventTrigger=new EventTrigger(actval);
					var cueobj:Object = {time: time, event: event};
					eventList.push(cueobj);
				}
			}
		}
	}
}