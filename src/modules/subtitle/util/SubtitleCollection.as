package modules.subtitle.util
{

	public class SubtitleCollection
	{
		public static const NULL_PARAMETER:String = "Null parameter";
		public static const INVALID_PARAMETER:String = "Invalid parameter";
		
		protected var keyCollection:Vector.<Number>;
		protected var valueCollection:Vector.<SubtitleCollectionItem>;
		
		public function reset():void
		{
		}
		
		public function get numItems():int
		{
			return valueCollection ? valueCollection.length : 0;
		}
		
		public function getItemAt(index:int):SubtitleCollectionItem
		{
			if (index >= 0 && valueCollection != null && index < valueCollection.length)
			{
				return valueCollection[index];
			}
			else
			{
				return null;
			}
		}
		
		public function addItem(marker:SubtitleCollectionItem):void
		{
			if (marker == null)
			{
				throw new ArgumentError(INVALID_PARAMETER);
			}
			addValue("" + marker.showTime, marker);
		}
		
		public function removeItem(marker:SubtitleCollectionItem):SubtitleCollectionItem
		{
			if (marker == null)
			{
				throw new ArgumentError(INVALID_PARAMETER);
			}
			return removeValue("" + marker.showTime);
		}
		
		public function addItems(markerlist:Array):void{
			if(!markerlist || !markerlist.length) return;
			for(var i:int=0; i<markerlist.length; i++){
				var et:SubtitleCollectionItem = markerlist[i] as SubtitleCollectionItem;
				if(et){
					addItem(et);
				}
			}
		}
		
		public function removeAllItems():void{
			valueCollection = null;
			keyCollection = null;
		}
		
		
		public function addValue(key:String, value:Object):void
		{
			var time:Number = new Number(key);
			var marker:SubtitleCollectionItem = value as SubtitleCollectionItem;
			if (key == null || isNaN(time) || time < 0 || marker == null)
			{
				throw new ArgumentError(INVALID_PARAMETER);
			}
			if (valueCollection == null)
			{
				keyCollection = new Vector.<Number>();
				keyCollection.push(time);
				valueCollection = new Vector.<SubtitleCollectionItem>();
				valueCollection.push(value);
			}
			else
			{
				// Find the index where we should insert this value
				var index:int = binaryFindKey(0, valueCollection.length - 1, time);
				// A negative index value means it doesn't exist in the array and the absolute value is the
				// index where it should be inserted. A positive index means a value exists and in this
				// case we'll overwrite the existing value rather than insert a duplicate.
				if (index < 0)
				{
					index *= -1;
					keyCollection.splice(index, 0, time);
					valueCollection.splice(index, 0, marker);
				}
					// Make sure we don't insert a dup at index 0
				else if ((index == 0) && (time != keyCollection[0]))
				{
					keyCollection.splice(index, 0, time);
					valueCollection.splice(index, 0, marker);
				}
				else
				{
					keyCollection[index] = time;
					valueCollection[index] = marker;
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
			var index:int = valueCollection ? binaryFindKey(0, valueCollection.length - 1, time) : -1;
			if (index >= 0)
			{
				keyCollection.splice(index, 1);
				result = valueCollection.splice(index, 1)[0];
				// If we just removed the last one, clean up and stop the interval timer (fix for FM-1052)
				if (valueCollection.length == 0)
				{
					valueCollection = null;
					keyCollection = null;
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
				for (var i:int = 0; i < keyCollection.length; i++)
				{
					var keyTime:Number = keyCollection[i];
					if (keyTime == time)
					{
						return valueCollection[i];
					}
				}
			}
			return null;
		}
		
		private function binaryFindKey(firstIndex:int, lastIndex:int, time:Number):int
		{
			if (firstIndex <= lastIndex)
			{
				//var mid:int=(firstIndex + lastIndex) / 2; // divide and conquer
				var mid:int=(firstIndex + lastIndex) >> 1;
				
				if (time == keyCollection[mid])
				{
					return mid;
				}
				else if (time < keyCollection[mid])
				{
					// search the lower part
					return binaryFindKey(firstIndex, mid - 1, time);
				}
				else
				{
					// search the upper part
					return binaryFindKey(mid + 1, lastIndex, time);
				}
			}
			return -(firstIndex);
		}
	}
}
