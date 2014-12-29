package components.videoPlayer.timedevent
{
	public class CaptionManager extends TimelineActionDispatcher
	{
		
		
		private var roleColors:Array = [0xffffff, 0xfffd22, 0x69fc00, 0xfd7200, 0x056cf9, 0xff0f0b, 0xc314c9, 0xff6be5];
		public var colorDictionary:Array = new Array();
		
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