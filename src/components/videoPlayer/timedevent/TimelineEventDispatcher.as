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
		protected var temporalKeyCollection:Vector.<Number>;
		protected var temporalValueCollection:Vector.<EventTrigger>;
		
		protected var lastFiredTemporalMetadataIndex:int=-1;

		protected static const CHECK_INTERVAL:Number=100; // time check interval in ms
		protected static const TOLERANCE:Number=0.1; // 0.25 time value tolerance in ms

		public static const NULL_PARAMETER:String = "Null parameter";
		public static const INVALID_PARAMETER:String = "Invalid parameter";
		
		protected var targetInstance:Object;

		public function TimelineEventDispatcher()
		{
			
		}

		public function reset():void
		{
			lastFiredTemporalMetadataIndex = -1;
		}
		
		public function get numMarkers():int
		{
			return temporalValueCollection ? temporalValueCollection.length : 0;
		}
		
		public function getMarkerAt(index:int):EventTrigger
		{
			if (index >= 0 && temporalValueCollection != null && index < temporalValueCollection.length)
			{
				return temporalValueCollection[index];
			}
			else
			{
				return null;
			}
		}
	
		public function addMarker(marker:EventTrigger):void
		{
			if (marker == null)
			{
				throw new ArgumentError(INVALID_PARAMETER);
			}
			addValue("" + marker.time, marker);
		}
		
		public function removeMarker(marker:EventTrigger):EventTrigger
		{
			if (marker == null)
			{
				throw new ArgumentError(INVALID_PARAMETER);
			}
			return removeValue("" + marker.time);
		}
		
		public function addMarkers(markerlist:Array):void{
			if(!markerlist || !markerlist.length) return;
			for(var i:int=0; i<markerlist.length; i++){
				var et:EventTrigger = markerlist[i] as EventTrigger;
				if(et){
					addMarker(et);
				}
			}
		}
		
		public function removeAllMarkers():void{
			temporalValueCollection = null;
			temporalKeyCollection = null;
		}
		
		
		public function addValue(key:String, value:Object):void
		{
			var time:Number = new Number(key);
			var marker:EventTrigger = value as EventTrigger;
			if (key == null || isNaN(time) || time < 0 || marker == null)
			{
				throw new ArgumentError(INVALID_PARAMETER);
			}
			if (temporalValueCollection == null)
			{
				temporalKeyCollection = new Vector.<Number>();
				temporalKeyCollection.push(time);
				temporalValueCollection = new Vector.<EventTrigger>();
				temporalValueCollection.push(value);
			}
			else
			{
				// Find the index where we should insert this value
				var index:int = findTemporalMetadata(0, temporalValueCollection.length - 1, time);
				// A negative index value means it doesn't exist in the array and the absolute value is the
				// index where it should be inserted. A positive index means a value exists and in this
				// case we'll overwrite the existing value rather than insert a duplicate.
				if (index < 0)
				{
					index *= -1;
					temporalKeyCollection.splice(index, 0, time);
					temporalValueCollection.splice(index, 0, marker);
				}
					// Make sure we don't insert a dup at index 0
				else if ((index == 0) && (time != temporalKeyCollection[0]))
				{
					temporalKeyCollection.splice(index, 0, time);
					temporalValueCollection.splice(index, 0, marker);
				}
				else
				{
					temporalKeyCollection[index] = time;
					temporalValueCollection[index] = marker;
				}
			}
		}
		
		
		public function removeValue(key:String):*
		{
			if (key == null)
			{
				throw new ArgumentError("Null parameter");
			}
			var time:Number = new Number(key);
			var result:* = null;
			// Also remove from our collections.
			var index:int = temporalValueCollection ? findTemporalMetadata(0, temporalValueCollection.length - 1, time) : -1;
			if (index >= 0)
			{
				temporalKeyCollection.splice(index, 1);
				result = temporalValueCollection.splice(index, 1)[0];
				// If we just removed the last one, clean up and stop the interval timer (fix for FM-1052)
				if (temporalValueCollection.length == 0)
				{
					temporalValueCollection = null;
					temporalKeyCollection = null;
				}
			}
			return result;
		}
		
		
		public function getValue(key:String):*
		{
			if (key == null)
			{
				throw new ArgumentError();
			}
			var time:Number = new Number(key);
			if (!isNaN(time))
			{
				for (var i:int = 0; i < temporalKeyCollection.length; i++)
				{
					var keyTime:Number = temporalKeyCollection[i];
					if (keyTime == time)
					{
						return temporalValueCollection[i];
					}
				}
			}
			return null;
		}

		private function checkForTemporalMetadata(currentTime:Number):void
		{
			var now:Number=currentTime;
			// Start looking one index past the last one we found
			var index:int=findTemporalMetadata(lastFiredTemporalMetadataIndex + 1, temporalValueCollection.length - 1, now);
			// A negative index value means it doesn't exist in the collection and the absolute value is the
			// index where it should be inserted. Therefore, to get the closest match, we'll look at the index
			// before this one. A positive index means an exact match was found.
			if (index <= 0)
			{
				index*=-1;
				index=(index > 0) ? (index - 1) : 0;
			}
			// See if the value at this index is within our tolerance
			if (!checkTemporalMetadata(index, now) && ((index + 1) < temporalValueCollection.length))
			{
				// Look at the next one, see if it is close enough to fire
				checkTemporalMetadata(index + 1, now);
			}
		}

	
		private function findTemporalMetadata(firstIndex:int, lastIndex:int, time:Number):int
		{
			if (firstIndex <= lastIndex)
			{
				//var mid:int=(firstIndex + lastIndex) / 2; // divide and conquer
				var mid:int=(firstIndex + lastIndex) >> 1;

				if (time == temporalKeyCollection[mid])
				{
					return mid;
				}
				else if (time < temporalKeyCollection[mid])
				{
					// search the lower part
					return findTemporalMetadata(firstIndex, mid - 1, time);
				}
				else
				{
					// search the upper part
					return findTemporalMetadata(mid + 1, lastIndex, time);
				}
			}
			return -(firstIndex);
		}

		private function checkTemporalMetadata(index:int, now:Number):Boolean
		{
			if (!temporalValueCollection || !temporalValueCollection.length)
			{
				return false;
			}
			var result:Boolean=false;
			if ((temporalValueCollection[index].time >= (now - TOLERANCE)) && (temporalValueCollection[index].time <= (now + TOLERANCE)) && (index != lastFiredTemporalMetadataIndex))
			{
				trace("TemporalMetadata fired. metadatatime: "+temporalValueCollection[index].time+" currenttime: "+now);
				lastFiredTemporalMetadataIndex=index;
				dispatchTemporalEvents(index);
				result=true;
			}
			return result;
		}

		private function calcNextTime(index:int):Number
		{
			return temporalValueCollection[index + 1 < temporalKeyCollection.length ? index + 1 : temporalKeyCollection.length - 1].time;
		}
		
		private function dispatchTemporalEvents(index:int):void
		{
			var marker:EventTrigger = temporalValueCollection[index];
			marker.executeActions();
		} 

		public function onIntervalTimer(event:PollingEvent):void
		{
			if(temporalValueCollection)
				checkForTemporalMetadata(event.time);
		}


		public function timeToSeconds(time:String, ms:Boolean=false):Number
		{
			var seconds:Number;
			var milliseconds:int;
			var timeExp:RegExp=/(\d{2}):(\d{2}):(\d{2})\.(\d{3})/;
			var matches:Array=time.match(timeExp);
			if (matches && matches.length)
			{
				seconds=(matches[1] * 3600) + (matches[2] * 60) + (matches[3] * 1) + (matches[4] * .001);
				milliseconds=seconds * 1000;
			}
			else
			{
				seconds=parseFloat(time);
				milliseconds=int(seconds * 1000);
			}
			return ms ? Number(milliseconds) : seconds;
		}
	}
}
