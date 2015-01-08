package components.videoPlayer.timedevent
{
	import mx.utils.ObjectUtil;

	public class CaptionManager extends TimelineEventDispatcher
	{
			
		private var roleColors:Array = [0xffffff, 0xfffd22, 0x69fc00, 0xfd7200, 0x056cf9, 0xff0f0b, 0xc314c9, 0xff6be5];
		public var colorDictionary:Array = new Array();
		
		public function CaptionManager()
		{
			super();
		}
		
		public function parseCaptions(captions:Object, playerInstance:Object, captioningInstance:Object=null):Boolean{
			if (!captions || !playerInstance)
				return false;
			this.targetInstance=playerInstance;
			colorDictionary = new Array();
			for each (var caption:Object in captions)
			{	
				//Show caption
				var showTime:Number = timeToSeconds(caption.showTime);
				var sclosure:Function = playerInstance['showCaption'];
				var params:Object = new Object();
				params.text = caption.text;
				params.color = voiceColor(caption.exerciseRoleName);
				
				var scpar:Array = new Array();
				scpar.push({func: sclosure, params: params});
				
				if(captioningInstance){
					var capclosure:Function = captioningInstance['highlightSubtitle'];
					var capparam:Number = showTime;
					scpar.push({func: capclosure, params: capparam});
				}
				
				var sevent:EventTrigger=new EventTrigger(scpar, showTime);
				addMarker(sevent);
				
				//Hide caption
				var hideTime:Number = timeToSeconds(caption.hideTime);
				var hclosure:Function = playerInstance['hideCaption'];
				
				var hcpar:Array = new Array();
				hcpar.push({func: hclosure, params: null});
				
				var hevent:EventTrigger=new EventTrigger(hcpar, hideTime);
				addMarker(hevent);
			}
			
			trace(ObjectUtil.toString(temporalValueCollection));
			trace(ObjectUtil.toString(temporalKeyCollection));
			
			return true;
		}
		
		private function voiceColor(voice:String):int{
			var found:Boolean = false;
			var color:uint = roleColors[0];
			for(var i:uint =0; i < colorDictionary.length; i++){
				if(colorDictionary[i] == voice){
					found = true;
					color = roleColors[i];
					break;
				}
			}
			if(!found){
				colorDictionary.push(voice);
				color = roleColors[colorDictionary.length-1];
			}
			return color;
		}
		
		private function parseTimestampCaptions(captions:Object, targetInstance:Object):Boolean
		{
			if (!captions || !targetInstance)
				return false;
			this.targetInstance=targetInstance;
			var time:Number;
			for (var timestamp:String in captions)
			{
				time=timeToSeconds(timestamp);
				if (!isNaN(time))
				{
					var actval:Array = new Array();
					var p:Object=captions[timestamp];
					var closure:*=targetInstance[p['action']];
					if(closure != null) actval.push({func: (closure as Function), params: p.value});
					var event:EventTrigger=new EventTrigger(actval, time);
					addMarker(event);
				}
			}
			return true;
		}
	}
}