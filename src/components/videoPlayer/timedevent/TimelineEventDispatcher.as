package components.videoPlayer.timedevent
{
	
	import components.videoPlayer.events.PollingEvent;
	
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	
	import mx.utils.ObjectUtil;
	
	import spark.collections.Sort;
	import spark.collections.SortField;

	public class TimelineEventDispatcher extends EventDispatcher
	{
		
		public static const DELAY_THRESHOLD:int = 80;
		
		protected var targetInstance:Object;
		protected var eventList:Array;
		protected var currentEventTime:Number;

		public function TimelineEventDispatcher()
		{
			eventList = new Array();
		}
		
		public function reset():void{
			eventList = new Array();	
		}

		public function pollEventPoints(ev:PollingEvent):void
		{
			var curTime:Number=ev.time * 1000;
			for each (var cueobj:Object in eventList)
			{
				if (((curTime - DELAY_THRESHOLD) < cueobj.time && cueobj.time < (curTime + DELAY_THRESHOLD)) && cueobj.time != currentEventTime)
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
			} else {
				milliseconds = parseInt(time);
			}
			return milliseconds;
		}
	}
}
