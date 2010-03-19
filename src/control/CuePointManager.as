package control
{
	import business.SubtitleDelegate;
	
	import events.CueManagerEvent;
	
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	
	import modules.videoPlayer.events.babelia.StreamEvent;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ArrayUtil;
	
	import vo.CueObject;
	import vo.CueObjectCache;
	import vo.SubtitleAndSubtitleLinesVO;
	import vo.SubtitleLineVO;
	
	public class CuePointManager extends EventDispatcher implements IResponder
	{
		private static var instance:CuePointManager = new CuePointManager();
		
		/**
		 * Used variables
		 **/ 
		private var cuelist:ArrayCollection;
		private var cache:Dictionary; // as HashMap
		private var watchingVideo:int;
		public var cached:Boolean = false;

		/**
		 * Constructor - Singleton Pattern
		 **/
		public function CuePointManager() 
		{
			if (instance)
				throw new Error("CuePointManager can only be accessed through CuePointManager.getInstance()");
			
			cuelist = new ArrayCollection();
			cache = new Dictionary();
			watchingVideo = -1;
			cached = false;
		}
		
		public static function getInstance() : CuePointManager
		{
			return instance;
		}

		/**
		 * Reset CuePointManager on module change
		 **/
		public function reset() : void
		{
		 	watchingVideo = -1;
		 	cached = false;
		 	cuelist.removeAll();
		}

		/**
		 * Set video.
		 * @return true if video was cached
		 **/
		 public function setVideo(videoId:int) : Boolean
		 {
		 	this.watchingVideo = videoId;
		 
		 	if ( cache[this.watchingVideo] != null )
		 	{
		 		var cachedCuelist:CueObjectCache = cache[this.watchingVideo] as CueObjectCache;
		 		
		 		/**
		 		 *  flash.utils.getTimer():int 
		 		 *  integer value of milliseconds since SWF started running
		 		 **/
		 		if ( cachedCuelist.getCachedTime()+300000 > flash.utils.getTimer() )
		 		{
		 			this.setCueList(cachedCuelist.getCueList());
		 			return true;
		 		}
		 	}
		 	
			return false;
		 }

		/**
		 * Cuelist manage functions
		 **/
		public function addCue(cueobj:CueObject) : void
		{
			cuelist.addItem(cueobj);
		}
		
		public function setCue(pos:int, cueobj:CueObject) : void
		{
			cuelist.setItemAt(cueobj, pos);
		}
		
		public function getCue(pos:int) : CueObject
		{
			return cuelist.getItemAt(pos) as CueObject;
		}
		
		public function removeCue(pos:int) : CueObject
		{
			return cuelist.removeItemAt(pos) as CueObject;
		}
		
		public function removeAllCue() : void
		{
			cuelist.removeAll();
		}
		
		public function setCueList(cuelist:ArrayCollection) : void
		{
			this.cuelist = cuelist;
			saveCache(); // auto-cache
		}
		
		
		/**
		 * Save cache of cuepoints
		 **/
		public function saveCache() : void
		{
			if ( cache[this.watchingVideo] != null )
			{
				var cachedVideo:CueObjectCache = cache[this.watchingVideo] as CueObjectCache;
				cachedVideo.setCachedTime(flash.utils.getTimer());
				cachedVideo.setCueList(cuelist);
			}
			else
			{
				cache[this.watchingVideo] = new CueObjectCache(flash.utils.getTimer(), cuelist);
			}
		}

		
		/**
		 * Callback function - OnEnterFrame
		 * 
		 * Comandos de inicio y final por si el vídeo
		 * tiene silencios.
		 **/ 
		public function monitorCuePoints(ev:StreamEvent) : void
		{
			var curTime:Number = ev.time;
			
			for each (var cueobj:CueObject in cuelist)
			{
				if ((curTime - 0.08) < cueobj.getStartTime() 
						&& cueobj.getStartTime() < (curTime + 0.08))
				{
					cueobj.executeStartCommand();
					break;
				}
				
				if ((curTime - 0.08) < cueobj.getEndTime() 
						&& cueobj.getEndTime() < (curTime + 0.08))
				{
					cueobj.executeEndCommand();
					break;
				}
			}
		 }


		/**
		 * Get cuepoints from subtitle
		 **/ 
		public function setCuesFromSubtitle(language:String) : void
		{
			var subtitle:SubtitleAndSubtitleLinesVO = new SubtitleAndSubtitleLinesVO();
			subtitle.exerciseId = this.watchingVideo;
			subtitle.language = language;
			
			// add this manager as iresponder and get subtitle lines
			new SubtitleDelegate(this).getSubtitleLines(subtitle);
		}
		
		private function addCueFromSubtitleLine(subline:SubtitleLineVO) : void
		{
			var cueObj:CueObject = new CueObject(subline.showTime, subline.hideTime, 
														subline.text, subline.role);
			this.addCue(cueObj);
		}
		
		
		/**
		 * Getting cuelists for set their commands
		 **/
		public function getCuelist() : ArrayCollection
		{
			return cuelist;
		}
		
		/**
		 * Return cuepoint list in array mode with startTime and role
		 **/
		public function cues2rolearray() : ArrayCollection
		{
			var arrows:ArrayCollection = new ArrayCollection();
			
			for each ( var cue:CueObject in getCuelist() )
				arrows.addItem({time:cue.getStartTime(),role:cue.getRole()});
				
			return arrows;
		}
		

		/**
		 * Implements IResponder methods for subtitle lines retrieve
		 **/ 
		public function result(data:Object):void
		{
			var result:Object = data.result;
			
			if ( result is Array )
			{
				var resultCollection:ArrayCollection=new ArrayCollection(ArrayUtil.toArray(result));
				
				if ( resultCollection.length > 0 &&
						resultCollection.getItemAt(0) is SubtitleLineVO )
				{
					for ( var i:int = 0; i < resultCollection.length; i++ )
					{
						addCueFromSubtitleLine(resultCollection.getItemAt(i) as SubtitleLineVO);
					}
				}
			}
			
			dispatchEvent(new CueManagerEvent(CueManagerEvent.SUBTITLES_RETRIEVED));
		}
		
		public function fault(info:Object):void
		{
			var faultEvent:FaultEvent = info as FaultEvent;
			Alert.show("Error while getting your subtitle lines: "+faultEvent.message);
		}
	}
}