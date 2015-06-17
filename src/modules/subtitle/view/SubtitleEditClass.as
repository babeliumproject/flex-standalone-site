package modules.subtitle.view
{	
	import components.videoPlayer.VideoPlayer;
	import components.videoPlayer.VideoRecorder;
	import components.videoPlayer.events.MediaStatusEvent;
	import components.videoPlayer.events.VideoPlayerEvent;
	import components.videoPlayer.events.babelia.StreamEvent;
	import components.videoPlayer.events.babelia.SubtitlingEvent;
	import components.videoPlayer.media.AMediaManager;
	
	import control.URLManager;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.globalization.DateTimeFormatter;
	import flash.globalization.DateTimeStyle;
	
	import model.DataModel;
	
	import modules.IGroupInterface;
	import modules.exercise.event.ExerciseEvent;
	import modules.subtitle.event.SubtitleEvent;
	
	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.controls.DataGrid;
	import mx.controls.VRule;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.events.CloseEvent;
	import mx.events.CollectionEvent;
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
	import mx.resources.ResourceManager;
	import mx.utils.ObjectUtil;
	import mx.utils.StringUtil;
	
	import skins.CustomTitleWindow;
	import skins.IconButton;
	
	import spark.collections.Sort;
	import spark.collections.SortField;
	import spark.components.Button;
	import spark.components.ComboBox;
	import spark.components.DropDownList;
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.components.VGroup;
	import spark.events.IndexChangeEvent;
	
	import utils.CollectionUtils;
	
	import view.common.CustomAlert;
	import view.common.IconComboBox;
	
	import vo.CreditHistoryVO;
	import vo.CueObject;
	import vo.ExerciseRoleVO;
	import vo.ExerciseVO;
	import vo.RoleComboDataVO;
	import vo.SubtitleAndSubtitleLinesVO;
	import vo.SubtitleLineVO;


	public class SubtitleEditClass extends HGroup implements IGroupInterface
	{
		private var _dataModel:DataModel=DataModel.getInstance();


		public var mediaid:int;
		public var subtitleid:int;
		
		private var _mediaStatus:int;

		private var subtitleStartTime:Number=0;
		private var subtitleEndTime:Number=0;

		private var startEntry:SubtitleLineVO;
		private var endEntry:SubtitleLineVO;

		private var creationComplete:Boolean=false;

		private var subtitlesToBeSaved:SubtitleAndSubtitleLinesVO;

		protected var _subCollection:ArrayCollection;
		
		protected var _mediaData:Object;
		
		[Bindable]
		public var comboData:ArrayCollection=new ArrayCollection();

		public var availableSubtitleVersions:ArrayCollection;
		
		protected var commitOnly:Boolean=false;
		protected var useWeakReference:Boolean=false;
		protected var useCapture:Boolean=false;
		protected var priority:int=0;
		
		protected var cw1:ChangeWatcher,cw2:ChangeWatcher,cw3:ChangeWatcher,cw4:ChangeWatcher;

		/**
		 *  Visual components declaration
		 */
		[Bindable]
		public var VPSubtitle:VideoRecorder=new VideoRecorder();
		public var exerciseTitle:Label;

		[Bindable]
		public var subtitleList:DataGrid=new DataGrid();

		public var subtitleVersionBox:VGroup;
		public var subtitleVersionSelector:DropDownList;

		public var saveSubtitleButton:IconButton;
		public var saveSubtitleSeparator:VRule;

		public function SubtitleEditClass()
		{
			addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete, false, 0, true);
		}

		private function onCreationComplete(event:FlexEvent):void
		{
			setupVideoPlayer();

			cw1=BindingUtils.bindSetter(onSubtitleLinesRetrieved, _dataModel, "availableSubtitleLinesRetrieved", commitOnly, useWeakReference);
			cw2=BindingUtils.bindSetter(onSubtitleSaved, _dataModel, "subtitleSaved", commitOnly, useWeakReference);
			cw3=BindingUtils.bindSetter(onRolesRetrieved, _dataModel, "availableExerciseRolesRetrieved", commitOnly, useWeakReference);
			cw4=BindingUtils.bindSetter(onSubtitlesRetrieved, _dataModel, "availableSubtitlesRetrieved", commitOnly, useWeakReference);
			
			subtitleVersionSelector.addEventListener(IndexChangeEvent.CHANGE, onSubtitleVersionChange, useCapture, priority, useWeakReference);
			
			creationComplete=true;
		}
		
		public function resetGroup():void
		{
			VPSubtitle.resetComponent();
			
			subtitleVersionBox.includeInLayout=false;
			subtitleVersionBox.visible=false;
			availableSubtitleVersions=null;
			subCollection=null;
			comboData=null;
			
			mediaid=subtitleid=subtitleStartTime=subtitleEndTime=0;			
			
			creationComplete=false;
			subtitlesToBeSaved=null;
			
			startEntry=endEntry=null;
			
			//Reset the model related data
			_dataModel.availableSubtitleLines=null;
			_dataModel.availableExerciseRoles=null;
			_dataModel.availableSubtitles=null;
		}
		
		public function unpinGroup():void{
			if(cw1) cw1.unwatch();
			if(cw2) cw2.unwatch();
			if(cw3) cw3.unwatch();
			if(cw4) cw4.unwatch();
			
			cw1=cw2=cw3=cw4=null;
			
			VPSubtitle.removeEventListener(SubtitlingEvent.START, subtitleStartHandler);
			VPSubtitle.removeEventListener(SubtitlingEvent.END, subtitleEndHandler);
			subtitleVersionSelector.removeEventListener(IndexChangeEvent.CHANGE, onSubtitleVersionChange);
			
			removeEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
		}
		
		
		[Bindable]
		public function get subCollection():ArrayCollection {
			return _subCollection;
		}
		
		public function set subCollection(value:ArrayCollection):void {
			if (value != _subCollection) {
				if (_subCollection != null) {
					_subCollection.removeEventListener(CollectionEvent.COLLECTION_CHANGE, onSubtitleCollectionChanged);
				}
				_subCollection=value;
				if (_subCollection != null) {
					_subCollection.addEventListener(CollectionEvent.COLLECTION_CHANGE, onSubtitleCollectionChanged, false, 0, true);
				}
				onSubtitleCollectionChanged(null);
			}
		}
		
		protected function onSubtitleCollectionChanged(event:CollectionEvent):void{
			trace("CollectionChangeEvent: "+ObjectUtil.toString(subCollection));
			VPSubtitle.setCaptions(subCollection,this);
		}

		public function setupVideoPlayer():void
		{
			VPSubtitle.addEventListener(SubtitlingEvent.START, subtitleStartHandler, useCapture, priority, useWeakReference);
			VPSubtitle.addEventListener(SubtitlingEvent.END, subtitleEndHandler, useCapture, priority, useWeakReference);
		}

		public function resolveIdToRole(item:Object, column:DataGridColumn):String
		{
			var label:String="";
			for each (var dp:RoleComboDataVO in comboData)
			{
				if (dp.roleId == item.exerciseRoleId)
				{
					label=dp.charName;
					break;
				}
			}
			return label;
		}

		private function setSelectedSubtitleVersion(activeSubtitleId:int):void
		{
			if (availableSubtitleVersions && availableSubtitleVersions.length > 1)
			{
				for each (var subtVer:Object in availableSubtitleVersions)
				{
					if (subtVer.id == activeSubtitleId)
					{
						subtitleVersionSelector.selectedItem=subtVer;
						break;
					}
				}
			}
		}

		public function subtitleStartHandler(e:SubtitlingEvent):void
		{
			var stimestr:String = e.time.toFixed(2);
			var htimestr:String = new Number(e.time + 0.5).toFixed(2);
			var time:Number = new Number(stimestr);
			subtitleStartTime=time;
			
			//id, subtitleid, roleid, rolename are unknown at this point
			startEntry=new SubtitleLineVO(0, 0, stimestr, htimestr); 
		
			addSubtitleToCollection(startEntry);

			//VPSubtitle.setCaptions(subtitleCollection);

		}
		
		protected function addSubtitleToCollection(lineData:Object):void{
			if(!subCollection) 
				subCollection=new ArrayCollection();
			subCollection.addItem(lineData);
			//CollectionUtils.sortByField(subCollection,'showTime',true);
		}

		public function subtitleEndHandler(e:SubtitlingEvent):void
		{
			if (subCollection && subCollection.length > 0)
			{
				subtitleEndTime=(e.time < (VPSubtitle.duration - 0.5)) ? e.time : VPSubtitle.duration - 0.5;
				
				trace("Sub start time: "+subtitleStartTime+" Subtitle end time: "+subtitleEndTime);
				
				var item:Object = CollectionUtils.findInCollection(subCollection,CollectionUtils.findField('showTime',subtitleStartTime) as Function);
				if(item){
					trace("Subtitle found in collection: "+ObjectUtil.toString(item));
					item.hideTime=subtitleEndTime;
				}
				//VPSubtitle.setCaptions(subtitleCollection);
			}
		}

		public function onMediaStateChange(e:MediaStatusEvent):void
		{
			_mediaStatus=e.state;
		}

		public function subtitleInsertHandler(e:MouseEvent):void
		{
			if (_mediaStatus == AMediaManager.STREAM_STARTED)
			{
				VPSubtitle.onSubtitlingEvent(new SubtitlingEvent(SubtitlingEvent.START));
			}
			else
			{
				if (subCollection && subCollection.length > 0)
				{
					var lastSub:Object=subCollection.getItemAt(subCollection.length - 1);
					var time:Number=lastSub.hideTime + 0.25;
					this.subtitleStartHandler((new SubtitlingEvent(SubtitlingEvent.START, time)));
				}
				else
				{
					this.subtitleStartHandler((new SubtitlingEvent(SubtitlingEvent.START)));
				}
			}
		}

		public function subtitleRemoveHandler():void
		{
			if (subtitleList.selectedIndex != -1)
			{

				var previouslySelectedIndex:Number=subtitleList.selectedIndex;
				var indexToBeSelected:Number;
				if (previouslySelectedIndex != 0 || subtitleList.rowCount != 1)
					indexToBeSelected=previouslySelectedIndex - 1;

				subCollection.removeItemAt(previouslySelectedIndex);
				subtitleList.selectedIndex=indexToBeSelected;
				
				//VPSubtitle.setCaptions(subtitleCollection);
			}
		}

		public function subtitleClearHandler():void
		{
			CustomAlert.confirm(resourceManager.getString('myResources', 'WARNING_CLEAR_SUBTITLE_LINES'), Alert.YES | Alert.NO, null, subtitleClearConfirmation, Alert.NO);
		}

		private function subtitleClearConfirmation(event:CloseEvent):void
		{
			if (event.detail == Alert.YES){
				subCollection.removeAll();
				//VPSubtitle.setCaptions(null);
			}
		}

		public function subtitleNextHandler():void
		{
			var currentlySelectedIndex:Number=subtitleList.selectedIndex;
			if (currentlySelectedIndex != -1 && currentlySelectedIndex < subtitleList.rowCount)
			{
				subtitleList.selectedIndex=currentlySelectedIndex + 1;
			}
		}

		public function subtitlePreviousHandler():void
		{
			var currentlySelectedIndex:Number=subtitleList.selectedIndex;
			if (currentlySelectedIndex != -1 && currentlySelectedIndex > 0)
			{
				subtitleList.selectedIndex=currentlySelectedIndex - 1;
			}
		}

		public function goToTimeHandler():void
		{
			if (subtitleList.selectedIndex != -1)
			{
				var tempEntry:Object=subtitleList.selectedItem as Object;
				VPSubtitle.seekTo(tempEntry.showTime);
			}
		}
		
		public function highlightSubtitle(time:Number):void{
			if(!isNaN(time) && subtitleList && subtitleList.rowCount){
				var item:Object = CollectionUtils.findInCollection(subCollection, CollectionUtils.findField('showTime', time) as Function);
				if(item) subtitleList.selectedItem = item;
			}
		}

		public function saveSubtitlesHandler():void
		{
			var subLines:ArrayCollection=new ArrayCollection();
			if (subCollection.length > 0)
			{
				for each (var s:Object in subCollection)
				{
					var subLine:SubtitleLineVO=new SubtitleLineVO(0, 0, s.showTime, s.hideTime, s.text, s.exerciseRoleId)
					for each (var dp:Object in comboData)
					{
						if (dp.roleId == subLine.exerciseRoleId)
						{
							subLine.exerciseRoleName=dp.charName;
						}
					}
					subLines.addItem(subLine);
				}
				if (subtitlesWereModified(subLines))
				{
					var errors:String=checkSubtitleErrors();
					if (errors.length == 0)
					{
						var subtitleLines:Array=subLines.toArray();
						subtitlesToBeSaved=new SubtitleAndSubtitleLinesVO();
						subtitlesToBeSaved.mediaId=_mediaData.id;
						subtitlesToBeSaved.subtitleLines=subtitleLines;
						//if (DataModel.getInstance().unmodifiedAvailableSubtitleLines.length == 0)
						subtitlesToBeSaved.id=0;
						//else
						//	subtitles.id=DataModel.getInstance().availableSubtitleLines.getItemAt(0).subtitleId;

						//var subHistoricData:CreditHistoryVO=new CreditHistoryVO();
						//subHistoricData.videoExerciseId=_mediaData.id;
						//subHistoricData.videoExerciseName=_mediaData.mediacode;
						//DataModel.getInstance().subHistoricData=subHistoricData;

						CustomAlert.info(resourceManager.getString('myResources', 'CONFIRMATION_COMPLETE_SUBTITLE'), Alert.YES | Alert.NO, null, completeSubtitleConfirmation, Alert.NO);

					}
					else
					{
						CustomAlert.info(errors);
					}
				}
				else
				{
					CustomAlert.confirm((resourceManager.getString('myResources', 'WARNING_NOT_MODIFIED_SUBTITLES')), 0x4, null, null, 0x4);
				}
			}
			else
			{
				CustomAlert.confirm((resourceManager.getString('myResources', 'WARNING_EMPTY_SUBTITLE')), 0x4, null, null, 0x4);
			}

		}

		private function completeSubtitleConfirmation(event:CloseEvent):void
		{
			if (event.detail == Alert.YES)
			{
				subtitlesToBeSaved.complete=true;
			}
			else
			{
				subtitlesToBeSaved.complete=false;
			}
			new SubtitleEvent(SubtitleEvent.SAVE_SUBAND_SUBLINES, subtitlesToBeSaved).dispatch();
		}

		private function subtitlesWereModified(compareSubject:ArrayCollection):Boolean
		{
			var modified:Boolean=false;
			var unmodifiedSubtitlesLines:ArrayCollection=_dataModel.unmodifiedAvailableSubtitleLines;
			
			if(!unmodifiedSubtitlesLines)
				return true;
			
			if (unmodifiedSubtitlesLines.length != compareSubject.length)
				modified=true;
			else
			{
				for (var i:int=0; i < unmodifiedSubtitlesLines.length; i++)
				{
					var unmodifiedItem:Object=unmodifiedSubtitlesLines.getItemAt(i);
					var compareItem:Object=compareSubject.getItemAt(i);
					if ((unmodifiedItem.text != compareItem.text) || (unmodifiedItem.showTime != compareItem.showTime) || (unmodifiedItem.hideTime != compareItem.hideTime))
					{
						modified=true;
						break;
					}
				}
			}
			return modified;
		}

		private function checkSubtitleErrors():String
		{
			var errorMessage:String="";
			//Check empty roles, time overlappings and empty texts
			for (var i:int=0; i < subCollection.length; i++)
			{
				if (subCollection.getItemAt(i).exerciseRoleId < 1)
					errorMessage+=StringUtil.substitute(resourceManager.getString('myResources', 'ROLE_EMPTY') + "\n", i + 1);
				var lineText:String=subCollection.getItemAt(i).text;
				lineText=lineText.replace(/[ ,\;.\:\-_?¿¡!€$']*/, "");
				if (lineText.length < 1)
					errorMessage+=StringUtil.substitute(resourceManager.getString('myResources', 'EMPTY') + "\n", i + 1);
				if (i > 0)
				{
					if ((subCollection.getItemAt((i - 1)).hideTime + 0.2) >= subCollection.getItemAt(i).showTime)
						errorMessage+=StringUtil.substitute(resourceManager.getString('myResources', 'SUBTITLE_OVERLAPS') + "\n", i);
				}
				var hideTime:Number=subCollection.getItemAt(i).hideTime;
				var showTime:Number=subCollection.getItemAt(i).showTime;
				if ((hideTime > VPSubtitle.duration - 0.5) || hideTime < 0.5 || showTime < 0.5 || showTime > VPSubtitle.duration - 0.5)
					errorMessage+=StringUtil.substitute(resourceManager.getString('myResources', 'SUBTITLE_TIME_OUT_OF_BOUNDS') + "\n", i + 1);
			}
			return errorMessage;
		}



		public function lfRowNum(item:Object, column:DataGridColumn):String
		{
			var itemidx:int = subCollection.getItemIndex(item);
			return String(itemidx+1);
		}

		public function subtitleVersionComboLabelFunction(item:Object):String
		{
			var currentLocale:String=ResourceManager.getInstance().localeChain[0];
			var dFormatter:DateTimeFormatter=new DateTimeFormatter(currentLocale, DateTimeStyle.SHORT, DateTimeStyle.SHORT);
			if (item && item.hasOwnProperty('timecreated') && item.hasOwnProperty('username')){
				var date:Date=new Date(item.timecreated * 1000);
				return "[" + dFormatter.format(date) + "]  " + item.username;
			}else{
				return "";
			}
		}

		public function onSubtitleVersionChange(event:IndexChangeEvent):void
		{
			var select:Object = (event.currentTarget as DropDownList).selectedItem;
			if(select){
				new SubtitleEvent(SubtitleEvent.GET_EXERCISE_SUBLINES, select).dispatch();
			}
		}

		/**
		 * BINDING FUNCTIONS
		 */

		/**
		 * Called each time the property "availableSubtitlesRetrieved" changes in the model
		 * 	@param value
		 */		
		private function onSubtitlesRetrieved(value:Boolean):void
		{
			var subversions:int=DataModel.getInstance().availableSubtitles ? DataModel.getInstance().availableSubtitles.length : 0;
			
			_mediaData=_dataModel.subtitleMedia;
			if(_mediaData){
				var media:Object = new Object();
				media.netConnectionUrl = _mediaData.netConnectionUrl;
				media.mediaUrl = _mediaData.mediaUrl;
				VPSubtitle.loadVideoByUrl(media);
			}
			
			trace("Subtitle versions: " + subversions);
			availableSubtitleVersions=DataModel.getInstance().availableSubtitles;
			subtitleVersionSelector.dataProvider=availableSubtitleVersions;
			if (subversions > 1)
			{
				subtitleVersionBox.includeInLayout=true;
				subtitleVersionBox.visible=true;
				var currentmostSub:Object=availableSubtitleVersions.getItemAt(0);
				new SubtitleEvent(SubtitleEvent.GET_EXERCISE_SUBLINES, currentmostSub).dispatch();
			}
			else if (subversions == 1)
			{
				subtitleVersionBox.includeInLayout=false;
				subtitleVersionBox.visible=false;
				var sub:Object=availableSubtitleVersions.getItemAt(0);
				new SubtitleEvent(SubtitleEvent.GET_EXERCISE_SUBLINES, sub).dispatch();
			}
			else //This media has no subtitles
			{
				subtitleVersionBox.includeInLayout=false;
				subtitleVersionBox.visible=false;
				onSubtitleLinesRetrieved(true);
				onRolesRetrieved(true);
			}
		}
		
		public function onSubtitleLinesRetrieved(value:Boolean):void
		{
			subCollection= _dataModel.availableSubtitleLines;
			var unmodifiedSubtitleCollection:ArrayCollection=_dataModel.unmodifiedAvailableSubtitleLines;
			
			//VPSubtitle.setCaptions(subtitleCollection, this);
			
			if (unmodifiedSubtitleCollection && unmodifiedSubtitleCollection.length > 0){
				var subtitleid:int=parseInt(unmodifiedSubtitleCollection.getItemAt(0).subtitleId);
				setSelectedSubtitleVersion(subtitleid);
			}
		}

		private function onRolesRetrieved(value:Boolean):void
		{
			var avrol:ArrayCollection=getRoleLabels(DataModel.getInstance().availableExerciseRoles);
			var cData:ArrayCollection=new ArrayCollection();
			var insertOption:RoleComboDataVO=new RoleComboDataVO(0, resourceManager.getString('myResources', 'OPTION_INSERT_NEW_ROLE'), RoleComboDataVO.ACTION_INSERT, RoleComboDataVO.FONT_BOLD, RoleComboDataVO.INDENT_NONE);
			cData.addItem(insertOption);
			if (avrol && avrol.length > 0)
			{
				for each (var itemIns:Object in avrol)
				{
					var selectLine:RoleComboDataVO=new RoleComboDataVO(itemIns.code, itemIns.label, RoleComboDataVO.ACTION_SELECT, RoleComboDataVO.FONT_NORMAL, RoleComboDataVO.INDENT_ROLE);
					cData.addItem(selectLine);
				}
				var deleteOption:RoleComboDataVO=new RoleComboDataVO(0, resourceManager.getString('myResources', 'OPTION_DELETE_A_ROLE'), RoleComboDataVO.ACTION_NO_ACTION, RoleComboDataVO.FONT_BOLD, RoleComboDataVO.INDENT_NONE);
				cData.addItem(deleteOption);
				for each (var itemDel:Object in avrol)
				{
					var deleteLine:RoleComboDataVO=new RoleComboDataVO(itemDel.code, itemDel.label, RoleComboDataVO.ACTION_DELETE, RoleComboDataVO.FONT_NORMAL, RoleComboDataVO.INDENT_ROLE);
					cData.addItem(deleteLine);
				}
				comboData=cData;
			}
			else
			{
				var deleteOptionEmpty:RoleComboDataVO=new RoleComboDataVO(0, resourceManager.getString('myResources', 'OPTION_DELETE_A_ROLE'), RoleComboDataVO.ACTION_NO_ACTION, RoleComboDataVO.FONT_BOLD, RoleComboDataVO.INDENT_NONE);
				cData.addItem(deleteOptionEmpty);
				comboData=cData;
			}
		}
		
		private function getRoleLabels(roles:Object):ArrayCollection{
			if(!roles) return null;
			var roleLabels:ArrayCollection=new ArrayCollection();
			var code:int=0;
			for (var role:String in roles){
				code++;
				roleLabels.addItem({'code': code, 'label': role});
			}
			return roleLabels.length ? roleLabels : null;
		}

		private function onSubtitleSaved(value:Boolean):void
		{
			if(_mediaData){
				var mediaid:int = _mediaData.id;
			
				var params:Object = new Object();
				params.id = mediaid;
			
				//Refresh the available subtitle versions, etc.
				new SubtitleEvent(SubtitleEvent.GET_MEDIA_SUBTITLES, params).dispatch();
			}
		}
	}
}
