package components.videoPlayer.timedevent
{
	import events.PollingEvent;
	
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	
	import mx.utils.ObjectUtil;

	public class EventPointManager extends EventDispatcher
	{
		
		private var targetInstance:Object;
		private var eventList:Array;
		private var currentEventTime:Number;

		public function EventPointManager()
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

		public function parseEventPoints(points:Object, targetInstance:Object):Boolean
		{
			if (!points || !targetInstance)
				return false;
			this.targetInstance=targetInstance;
			var time:Number;
			eventList = new Array();
			for (var timestamp:String in points)
			{
				time=timeToSeconds(timestamp);
				if (!isNaN(time))
				{
					var actval:Array = new Array();
					if (points[timestamp].hasOwnProperty('exercise'))
					{
						var ex:Object=points[timestamp].exercise;
						var funcex:*=parseActionValue('exercise', ex);
						if(funcex != null) actval.push({func: (funcex as Function), params: ex.value});
					}
					if (points[timestamp].hasOwnProperty('response'))
					{
						var rp:Object=points[timestamp].response;
						var funcrp:*=parseActionValue('response', rp);
						if(funcrp != null) actval.push({func: (funcrp as Function), params: ex.value});
					}
					var event:EventTrigger=new EventTrigger(actval);
					var cueobj:Object = {time: time, event: event};
					eventList.push(cueobj);
				}
			}
			//trace(ObjectUtil.toString(eventList));
			return true;
		}

		public function parseActionValue(targetStream:String, actions:Object):*
		{
			if (!actions || !actions.hasOwnProperty('action') /*|| !actions.hasOwnProperty('value')*/)
				return null;
			var action:String=actions.action;
			var value:String= actions.hasOwnProperty(value) ? actions.value : null;

			
			//return targetInstance.hasOwnProperty(action) ? targetInstance[action] : null;
			
			switch (action)
			{
				case 'mute':
					if(targetStream == 'exercise')
						return this.targetInstance.mute;
					if(targetStream == 'response')
						return this.targetInstance.muteRecording;
				case 'volumechange':
					if (targetStream == 'exercise')
						return this.targetInstance.setVolume;
					if (targetStream == 'response')
						return this.targetInstance.setVolumeRecording;
				case 'subtitlechange':
				//return videoPlayerInstance.setSubtitle;
				case 'roleboxchange':
				//return videoPlayerInstance.setRolebox;
				case 'highlightctrlchange':
				//return videoPlayerInstance.setHighlightControls;
				default:
					return null;
			}
			return null;
		}
		
		public function mapActionToFunction(label:String, stream:String):String{
			var func:String;
			switch(label)
			{
				case 'volumechange':
					break;
				case 'mute':
					func = stream ? 'muteRecording' : 'mute';
					break;
				
				default:
			}
			return func;
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
