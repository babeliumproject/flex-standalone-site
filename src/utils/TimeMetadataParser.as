package utils
{
	import components.videoPlayer.timedevent.EventTrigger;

	public class TimeMetadataParser
	{
		private static var roleColors:Array = [0xffffff, 0xfffd22, 0x69fc00, 0xfd7200, 0x056cf9, 0xff0f0b, 0xc314c9, 0xff6be5];
		
		public static function parseCaptions(captions:Object, playerInstance:Object, captioningInstance:Object=null):Array{
			if (!captions || !playerInstance)
				return null;
			var parsedCaptions:Array = new Array();
			var colorDictionary:Array = new Array();
			for each (var caption:Object in captions)
			{	
				//Show caption
				var showTime:Number = timeToSeconds(caption.showTime);
				var sclosure:Function = playerInstance['showCaption'];
				var params:Object = new Object();
				params.text = caption.text;
				params.color = voiceColor(caption.exerciseRoleName, colorDictionary);
				
				var scpar:Array = new Array();
				scpar.push({func: sclosure, params: params});
				
				if(captioningInstance){
					var capclosure:Function = captioningInstance['highlightSubtitle'];
					var capparam:Number = showTime;
					scpar.push({func: capclosure, params: capparam});
				}
				
				var sevent:EventTrigger=new EventTrigger(scpar, showTime);
				parsedCaptions.push(sevent);
				
				//Hide caption
				var hideTime:Number = timeToSeconds(caption.hideTime);
				var hclosure:Function = playerInstance['hideCaption'];
				
				var hcpar:Array = new Array();
				hcpar.push({func: hclosure, params: null});
				
				var hevent:EventTrigger=new EventTrigger(hcpar, hideTime);
				parsedCaptions.push(hevent);
			}
			return parsedCaptions.length ? parsedCaptions : null;
		}
		
		public static function parseMarkers(markers:Object, playerInstance:Object):Object{
			if (!markers || !playerInstance)
				return null;
			var parsedMarkers:Object = new Object();
			
			var markersByRole:Object = separateByRole(markers);
			
			for (var role:String in markersByRole){
				parsedMarkers[role] = parseRoleMarkers(markers.role, playerInstance);
			}
			return parsedMarkers;
		}
		
		public static function parseRoleMarkers(rolemarkers:Object, playerInstance:Object):Array{
			if (!rolemarkers || !playerInstance)
				return null;
			var parsedRoleCaptions:Array = new Array();
			for each (var rolemarker:Object in rolemarkers)
			{	
				//Marker start
				var showTime:Number = timeToSeconds(rolemarker.showTime);
				var scpar:Array = new Array();
				var sclosure1:Function = playerInstance['setMute'];
				var params1:Boolean = true;
				var sclosure2:Function = playerInstance['muteRecording'];
				var params2:Boolean = false;
				scpar.push({func: sclosure1, params: params1});
				scpar.push({func: sclosure2, params: params2});
				
				var sevent:EventTrigger=new EventTrigger(scpar, showTime);
				parsedRoleCaptions.push(sevent);
				
				//Marker end
				var hideTime:Number = timeToSeconds(rolemarker.hideTime);
				var hcpar:Array = new Array();
				var hclosure1:Function = playerInstance['setMute'];
				var hparams1:Boolean = false;
				var hclosure2:Function = playerInstance['muteRecording'];
				var hparams2:Boolean = true;
				hcpar.push({func: hclosure1, params: hparams1});
				hcpar.push({func: hclosure2, params: hparams2});
				
				var hevent:EventTrigger=new EventTrigger(hcpar, hideTime);
				parsedRoleCaptions.push(hevent);
			}
			return parsedRoleCaptions.length ? parsedRoleCaptions : null;
		}
		
		public static function separateByRole(collection:Object):Object{
			if(!collection) return null;
			var s:Object = new Object();
			for each (var item:Object in collection){
				if (!s.hasOwnProperty(item.exerciseRoleName)){
					s[item.exerciseRoleName] = new Array();
				}
				s[item.exerciseRoleName].push(item);
			}
			return s;
		}
		
		public static function voiceColor(voice:String, colorDict:Array):int{
			var found:Boolean = false;
			var color:uint = roleColors[0];
			for(var i:uint =0; i < colorDict.length; i++){
				if(colorDict[i] == voice){
					found = true;
					color = roleColors[i];
					break;
				}
			}
			if(!found){
				colorDict.push(voice);
				color = roleColors[colorDict.length-1];
			}
			return color;
		}
		
		public static function timeToSeconds(time:String, ms:Boolean=false):Number
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