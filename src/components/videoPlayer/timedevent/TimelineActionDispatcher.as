package components.videoPlayer.timedevent
{
	
	import components.videoPlayer.events.PollingEvent;
	
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	
	import mx.utils.ObjectUtil;

	public class TimelineActionDispatcher extends EventDispatcher
	{
		
		protected var targetInstance:Object;
		protected var eventList:Array;
		protected var currentEventTime:Number;

		public function TimelineActionDispatcher()
		{
			eventList = new Array();
		}

		public function pollEventPoints(ev:PollingEvent):void
		{
			var curTime:Number=ev.time * 1000;
			var delayThreshold:Number = 80;
			for each (var cueobj:Object in eventList)
			{
				if (((curTime - delayThreshold) < cueobj.time && cueobj.time < (curTime + delayThreshold)) && cueobj.time != currentEventTime)
				{
					//Don't fire the same event more than once
					currentEventTime=cueobj.time;
					cueobj.event.executeActions();
					break;
				}
			}
		}

		public function timeToSeconds(time:String):Number
		{
			var seconds:Number;
			var milliseconds:Number;
			var timeExp:RegExp=/(\d{2}):(\d{2}):(\d{2})\.(\d{3})/;
			var matches:Array=time.match(timeExp);
			if (matches && matches.length)
			{
				seconds=(matches[1] * 3600) + (matches[2] * 60) + (matches[3] * 1) + (matches[4] * .001);
				milliseconds = seconds * 1000;
			}
			return milliseconds;
		}

	}
}
