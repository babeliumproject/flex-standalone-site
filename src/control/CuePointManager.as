package control
{
	import business.SubtitleDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	
	import events.CueManagerEvent;
	
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	
	import modules.videoPlayer.events.babelia.StreamEvent;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ArrayUtil;
	
	import view.common.CustomAlert;
	
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
		[Bindable] 
		public var cuelist:ArrayCollection = new ArrayCollection();
		
		private var cache:Dictionary; // as HashMap
		private var exerciseId:int;
		private var subtitleId:int;
		public var cached:Boolean = false;
		
		//Prevents multiple firing of the same subtitle event
		//private var displayed:Boolean = false;

		/**
		 * Constructor - Singleton Pattern
		 **/
		public function CuePointManager() 
		{
			if (instance)
				throw new Error("CuePointManager can only be accessed through CuePointManager.getInstance()");
			
			cuelist = new ArrayCollection();
			cache = new Dictionary();
			exerciseId = -1;
			subtitleId = -1;
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
		 	exerciseId = -1;
			subtitleId = -1;
		 	cached = false;
		 	cuelist.removeAll();
		}

		/**
		 * Set video.
		 * @return true if video was cached
		 **/
		 public function setVideo(videoId:int) : Boolean
		 {
		 	this.exerciseId = videoId;
		 
		 	if ( cache[this.exerciseId] != null )
		 	{
		 		var cachedCuelist:CueObjectCache = cache[this.exerciseId] as CueObjectCache;
		 		
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
		 
		 public function get currentSubtitle():int{
			 return subtitleId;
		 }

		/**
		 * Cuelist manage functions
		 **/
		public function addCue(cueobj:CueObject) : void
		{
			cuelist.addItem(cueobj);
			sortByStartTime();
		}
		
		public function setCueAt(cueobj:CueObject, pos:int) : void
		{
			cuelist.setItemAt(cueobj, pos);
		}
		
		public function getCueAt(pos:int) : CueObject
		{
			return cuelist.getItemAt(pos) as CueObject;
		}
		
		public function removeCueAt(pos:int) : CueObject
		{
			return cuelist.removeItemAt(pos) as CueObject;
		}
		
		public function getCueIndex(cueobj:CueObject): int 
		{
			return cuelist.getItemIndex(cueobj);
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
		 * Cuelist sorting functions
		 **/
		public function sortByStartTime():void{
			var showTimeSort:SortField=new SortField();
			showTimeSort.name="startTime";
			showTimeSort.numeric=true;
			var numericDataSort:Sort=new Sort();
			numericDataSort.fields=[showTimeSort];
			cuelist.sort=numericDataSort;
			cuelist.refresh();
		}
		
		public function sortByEndTime():void{
			var showTimeSort:SortField=new SortField();
			showTimeSort.name="endTime";
			showTimeSort.numeric=true;
			var numericDataSort:Sort=new Sort();
			numericDataSort.fields=[showTimeSort];
			cuelist.sort=numericDataSort;
			cuelist.refresh();
		}
		
		public function setCueListStartCommand(command:ICommand):void{
			for each (var cuepoint:CueObject in cuelist){
				cuepoint.setStartCommand(command);
			}
		}
		
		public function setCueListEndCommand(command:ICommand):void{
			for each (var cuepoint:CueObject in cuelist){
				cuepoint.setEndCommand(command);
			}
		}
		
		
		/**
		 * Save cache of cuepoints
		 **/
		public function saveCache() : void
		{
			if ( cache[this.exerciseId] != null )
			{
				var cachedVideo:CueObjectCache = cache[this.exerciseId] as CueObjectCache;
				cachedVideo.setCachedTime(flash.utils.getTimer());
				cachedVideo.setCueList(cuelist);
			}
			else
			{
				cache[this.exerciseId] = new CueObjectCache(flash.utils.getTimer(), cuelist);
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
				if (/*!displayed &&*/ ((curTime - 0.08) < cueobj.getStartTime() 
						&& cueobj.getStartTime() < (curTime + 0.08)))
				{
					/*displayed = true;*/
					cueobj.executeStartCommand();
					break;
				}
				
				if (/*displayed &&*/ ((curTime - 0.08) < cueobj.getEndTime() 
						&& cueobj.getEndTime() < (curTime + 0.08)))
				{
					/*displayed = false;*/
					cueobj.executeEndCommand();
					break;
				}
			}
		 }


		/**
		 * Get cuepoints from subtitle
		 **/ 
		public function setCuesFromSubtitleUsingLocale(language:String) : void
		{
			var subtitle:SubtitleAndSubtitleLinesVO = new SubtitleAndSubtitleLinesVO();
			subtitle.exerciseId = this.exerciseId;
			subtitle.language = language;
			
			// add this manager as iresponder and get subtitle lines
			new SubtitleDelegate(this).getSubtitleLines(subtitle);
		}
		
		public function setCuesFromSubtitleUsingId(subtitleId:int):void{
			new SubtitleDelegate(this).getSubtitleLinesUsingId(subtitleId);
		}
		
		public function addCueFromSubtitleLine(subline:SubtitleLineVO) : void
		{
			var cueObj:CueObject = new CueObject(subline.showTime, subline.hideTime, 
														subline.text, subline.exerciseRoleId, subline.exerciseRoleName);
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
					subtitleId = (resultCollection.getItemAt(0) as SubtitleLineVO).subtitleId;
				}
			}
			//sortByStartTime();
			
			dispatchEvent(new CueManagerEvent(CueManagerEvent.SUBTITLES_RETRIEVED));
		}
		
		public function fault(info:Object):void
		{
			var faultEvent:FaultEvent = info as FaultEvent;
			CustomAlert.error("Error while getting the subtitle lines.");
		}
	}
}