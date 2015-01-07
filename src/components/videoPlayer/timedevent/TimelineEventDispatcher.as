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
		
		public static const DELAY_THRESHOLD_MS:int = 100;
		
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
			var curTime:Number=Math.round(ev.time * 1000);
			for each (var cueobj:Object in eventList)
			{
				if (((curTime - DELAY_THRESHOLD_MS) < cueobj.time && cueobj.time < (curTime + DELAY_THRESHOLD_MS)) && cueobj.time != currentEventTime)
				{
					//Don't fire the same event more than once
					currentEventTime=cueobj.time;
					cueobj.event.executeActions();
					break;
				}
			}
		}
		
		/**
		 * Use with ordered Arrays only 
		 * @param keys
		 * @param target
		 * @return 
		 * 
		 */		
		public function binarySearch(keys:Array, target:String):int{
			var high:int = keys.length;
			var low:int = -1;
			while (high - low > 1) {
				//var probe:int = (low + high) / 2;
				var probe:int = (low + high) >> 1;
				if (keys[probe] > target)
					high = probe;
				else
					low = probe;
			}
			
			if (low == -1 || keys[low] !== target)
				return -1;
			else
				return low;
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
				milliseconds = Math.floor(parseFloat(time)*1000);
			}
			return milliseconds;
		}
	}
}
