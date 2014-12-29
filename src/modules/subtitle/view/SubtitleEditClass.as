package modules.subtitle.view
{

	import commands.cuepointManager.ShowHideSubtitleCommand;
	
	import components.videoPlayer.CuePointManager;
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
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.controls.DataGrid;
	import mx.controls.VRule;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
	import mx.resources.ResourceManager;
	import mx.utils.ObjectUtil;
	import mx.utils.StringUtil;
	
	import skins.CustomTitleWindow;
	import skins.IconButton;
	
	import spark.components.Button;
	import spark.components.ComboBox;
	import spark.components.DropDownList;
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.components.VGroup;
	
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
		/**
		 * Singleton objects
		 */
		private var _dataModel:DataModel=DataModel.getInstance();
		private var _cueManager:CuePointManager=CuePointManager.getInstance();

		/**
		 * Variables
		 */
		[Bindable]
		private var videoPlayerReady:Boolean=false;

		[Bindable]
		public var videoPlaybackStartedState:int=AMediaManager.STREAM_STARTED;

		[Bindable]
		public var streamSource:String=DataModel.getInstance().streamingResourcesPath;

		private const EXERCISE_FOLDER:String=DataModel.getInstance().exerciseStreamsFolder;

		private var exerciseFileName:String;
		private var exerciseId:int;
		private var exerciseLanguage:String;

		[Bindable]
		private var subtitleStartTime:Number=0;
		[Bindable]
		private var subtitleEndTime:Number=0;

		private var startEntry:CueObject;
		private var endEntry:CueObject;

		[Bindable]
		public var subtitleStarted:Boolean=false;

		private var creationComplete:Boolean=false;
		
		private var subtitlesToBeSaved:SubtitleAndSubtitleLinesVO;

		/**
		 * Retrieved data holders
		 */
		[Bindable]
		public var subtitleCollection:ArrayCollection;
		[Bindable]
		public var comboData:ArrayCollection=new ArrayCollection();

		[Bindable]
		public var availableSubtitleVersions:ArrayCollection=new ArrayCollection();

		/**
		 *  Visual components declaration
		 */
		[Bindable]
		public var VPSubtitle:VideoRecorder=new VideoRecorder();
		public var exerciseTitle:Label;

		[Bindable]
		public var subtitleList:DataGrid=new DataGrid();

		public var guestEditWarningBox:HGroup;

		public var subtitleVersionBox:VGroup;
		public var subtitleVersionSelector:DropDownList;

		public var saveSubtitleButton:IconButton;
		public var saveSubtitleSeparator:VRule;

		public function SubtitleEditClass()
		{
			this.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
		}

		private function onCreationComplete(event:FlexEvent):void
		{
			setupVideoPlayer();

			BindingUtils.bindSetter(onExerciseSelected, _dataModel, "currentExerciseRetrieved");
			BindingUtils.bindSetter(onSubtitleLinesRetrieved, _dataModel, "availableSubtitleLinesRetrieved");
			BindingUtils.bindSetter(onSubtitleSaved, _dataModel, "subtitleSaved");
			BindingUtils.bindSetter(onRolesRetrieved, _dataModel, "availableExerciseRolesRetrieved");
			BindingUtils.bindSetter(onSubtitlesRetrieved, _dataModel, "availableSubtitlesRetrieved");

			creationComplete=true;

		}

		public function setupVideoPlayer():void
		{
			VPSubtitle.addEventListener(SubtitlingEvent.START, subtitleStartHandler, false, 0, true);
			VPSubtitle.addEventListener(SubtitlingEvent.END, subtitleEndHandler, false, 0, true);
		}

		public function prepareVideoPlayer():void
		{
			var netConnectionUrl:String='';
			
			var media:Object=new Object();
			media.netConnectionUrl = netConnectionUrl;
			media.mediaUrl = EXERCISE_FOLDER+'/'+exerciseFileName;
			
			VPSubtitle.loadVideoByUrl(media);
			
			VPSubtitle.removeEventListener(StreamEvent.ENTER_FRAME, _cueManager.monitorCuePoints);
			VPSubtitle.addEventListener(StreamEvent.ENTER_FRAME, _cueManager.monitorCuePoints, false, 0, true);
		}

		public function resolveIdToRole(item:Object, column:DataGridColumn):String
		{
			var label:String="";
			for each (var dp:RoleComboDataVO in comboData)
			{
				if (dp.roleId == item.roleId)
				{
					label=dp.charName;
					break;
				}
			}
			return label;
		}

		private function setSelectedSubtitleVersion(activeSubtitleId:int):void
		{
			if (availableSubtitleVersions.length > 1)
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
			subtitleStartTime= (e.time < 0.5) ? 0.5 : e.time;
			startEntry=new CueObject(0, subtitleStartTime, subtitleStartTime + 0.5, '', 0, '');
			startEntry.setStartCommand(new ShowHideSubtitleCommand(startEntry, VPSubtitle));
			startEntry.setEndCommand(new ShowHideSubtitleCommand(null, VPSubtitle));

			_cueManager.addCue(startEntry);

		}

		public function subtitleEndHandler(e:SubtitlingEvent):void
		{
			if (subtitleCollection && subtitleCollection.length > 0)
			{
				subtitleEndTime= (e.time < (VPSubtitle.duration - 0.5)) ? e.time : VPSubtitle.duration - 0.5;
				endEntry=new CueObject(0, subtitleStartTime, subtitleEndTime, '', 0, '');
				endEntry.setStartCommand(new ShowHideSubtitleCommand(endEntry, VPSubtitle));
				endEntry.setEndCommand(new ShowHideSubtitleCommand(null, VPSubtitle));
				_cueManager.setCueAt(endEntry, _cueManager.getCueIndex(startEntry));
			}
		}
		
		private var _mediaStatus:int;
		
		public function onMediaStateChange(e:MediaStatusEvent):void{
			_mediaStatus = e.state;
		}

		public function subtitleInsertHandler(e:MouseEvent):void
		{
			if(_mediaStatus == videoPlaybackStartedState){
				VPSubtitle.onSubtitlingEvent(new SubtitlingEvent(SubtitlingEvent.START));
			}else{
				if(subtitleCollection && subtitleCollection.length > 0){
					var lastSub:CueObject = subtitleCollection.getItemAt(subtitleCollection.length-1) as CueObject;
					var time:Number = lastSub.endTime + 0.25;
					trace(time);
					this.subtitleStartHandler((new SubtitlingEvent(SubtitlingEvent.START,time)));
				} else {
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

				_cueManager.removeCueAt(subtitleList.selectedIndex);
				subtitleList.selectedIndex=indexToBeSelected;

			}
		}

		public function subtitleClearHandler():void
		{
			CustomAlert.confirm(resourceManager.getString('myResources', 'WARNING_CLEAR_SUBLINES'), Alert.YES | Alert.NO, null, subtitleClearConfirmation, Alert.NO);
		}

		private function subtitleClearConfirmation(event:CloseEvent):void
		{
			if (event.detail == Alert.YES)
				_cueManager.removeAllCue();
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
				var tempEntry:CueObject=_cueManager.getCueAt(subtitleList.selectedIndex) as CueObject;
				VPSubtitle.seekTo(tempEntry.startTime);
			}
		}

		public function saveSubtitlesHandler():void
		{
			var currentExercise:ExerciseVO=DataModel.getInstance().currentExercise.getItemAt(0) as ExerciseVO;
			var subLines:ArrayCollection=new ArrayCollection();
			if (subtitleCollection.length > 0)
			{
				for each (var s:CueObject in subtitleCollection)
				{
					var subLine:SubtitleLineVO=new SubtitleLineVO(0, 0, s.startTime, s.endTime, s.text, s.roleId)
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
						subtitlesToBeSaved.mediaId=currentExercise.id;
						subtitlesToBeSaved.language=exerciseLanguage;
						subtitlesToBeSaved.subtitleLines=subtitleLines;
						//if (DataModel.getInstance().unmodifiedAvailableSubtitleLines.length == 0)
						subtitlesToBeSaved.id=0;
						//else
						//	subtitles.id=DataModel.getInstance().availableSubtitleLines.getItemAt(0).subtitleId;
						
						

						var subHistoricData:CreditHistoryVO=new CreditHistoryVO();
						subHistoricData.videoExerciseId=currentExercise.id;
						subHistoricData.videoExerciseName=currentExercise.exercisecode;
						DataModel.getInstance().subHistoricData=subHistoricData;
						
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
		
		private function completeSubtitleConfirmation(event:CloseEvent):void{
			if(event.detail == Alert.YES){
				subtitlesToBeSaved.complete = true;
			} else {
				subtitlesToBeSaved.complete = false;
			}
			new SubtitleEvent(SubtitleEvent.SAVE_SUBAND_SUBLINES, subtitlesToBeSaved).dispatch();
		}

		private function subtitlesWereModified(compareSubject:ArrayCollection):Boolean
		{
			var modified:Boolean=false;
			var unmodifiedSubtitlesLines:ArrayCollection=DataModel.getInstance().unmodifiedAvailableSubtitleLines;
			if (unmodifiedSubtitlesLines.length != compareSubject.length)
				modified=true;
			else
			{
				for (var i:int=0; i < unmodifiedSubtitlesLines.length; i++)
				{
					var unmodifiedItem:CueObject=unmodifiedSubtitlesLines.getItemAt(i) as CueObject;
					var compareItem:SubtitleLineVO=compareSubject.getItemAt(i) as SubtitleLineVO;
					if ((unmodifiedItem.text != compareItem.text) || (unmodifiedItem.startTime != compareItem.showTime) || (unmodifiedItem.endTime != compareItem.hideTime))
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
			for (var i:int=0; i < subtitleCollection.length; i++)
			{
				if (subtitleCollection.getItemAt(i).roleId < 1)
					errorMessage+=StringUtil.substitute(resourceManager.getString('myResources', 'ROLE_EMPTY') + "\n", i + 1);
				var lineText:String=subtitleCollection.getItemAt(i).text;
				lineText=lineText.replace(/[ ,\;.\:\-_?¿¡!€$']*/, "");
				if (lineText.length < 1)
					errorMessage+=StringUtil.substitute(resourceManager.getString('myResources', 'EMPTY') + "\n", i + 1);
				if (i > 0)
				{
					if (( subtitleCollection.getItemAt((i - 1)).endTime + 0.2 ) >= subtitleCollection.getItemAt(i).startTime)
						errorMessage+=StringUtil.substitute(resourceManager.getString('myResources', 'SUBOVERLAPS') + "\n", i);
				}
				var endTime:Number = subtitleCollection.getItemAt(i).endTime;
				var startTime:Number = subtitleCollection.getItemAt(i).startTime;
				if((endTime > VPSubtitle.duration - 0.5) || endTime < 0.5 || startTime < 0.5 || startTime > VPSubtitle.duration - 0.5 )
					errorMessage+=StringUtil.substitute(resourceManager.getString('myResources', 'SUBTIME_OUT_OF_BOUNDS') + "\n", i+1);
			}
			return errorMessage;
		}



		public function lfRowNum(oItem:Object, iCol:int):String
		{
			var iIndex:int=_cueManager.getCueIndex(oItem as CueObject) + 1;
			return String(iIndex);
		}

		public function subtitleVersionComboLabelFunction(item:Object):String
		{
			var currentLocale:String = ResourceManager.getInstance().localeChain[0];
			var dFormatter:DateTimeFormatter=new DateTimeFormatter(currentLocale, DateTimeStyle.SHORT, DateTimeStyle.SHORT);
			
			if (item != null)
				return "[" + dFormatter.format(new Date(item.timecreated)) + "]  " + item.userName;
			else
				return "";
		}

		public function onSubtitleVersionChange(event:Event):void
		{

			var exerciseToWatch:ExerciseVO=new ExerciseVO();
			exerciseToWatch.exercisecode=exerciseFileName;
			exerciseToWatch.id=exerciseId;
			exerciseToWatch.language=exerciseLanguage;
			exerciseToWatch.title=exerciseTitle.text;

			//Which subtitle version we want to retrieve
			var subtitleId:int=subtitleVersionSelector.selectedItem.id;

			//Set a flag that notices the currently selected label we're no longer dealing with the most recent subtitle.

			//Request the specified subtitles and launch the same events as when we watch the latest ones.
			var subtitles:SubtitleAndSubtitleLinesVO=new SubtitleAndSubtitleLinesVO(subtitleId, 0, '', exerciseLanguage);

			CuePointManager.getInstance().reset();

			new SubtitleEvent(SubtitleEvent.GET_MEDIA_SUBTITLES, new SubtitleAndSubtitleLinesVO(0, exerciseId, '', '')).dispatch();
			new SubtitleEvent(SubtitleEvent.GET_EXERCISE_SUBLINES, subtitles).dispatch();
			new ExerciseEvent(ExerciseEvent.WATCH_EXERCISE, exerciseToWatch).dispatch();
		}

		/**
		 * BINDING FUNCTIONS
		 */

		public function onExerciseSelected(value:Boolean):void
		{
			if (DataModel.getInstance().currentExerciseRetrieved.getItemAt(DataModel.SUBMODULE) /*&& videoPlayerReady*/)
			{
				//Add the subtitle editor to the stage
				this.includeInLayout=true;
				this.visible=true;
				
				DataModel.getInstance().currentExerciseRetrieved.setItemAt(false, DataModel.SUBMODULE);
				var watchExercise:ExerciseVO=DataModel.getInstance().currentExercise.getItemAt(DataModel.SUBMODULE) as ExerciseVO;
				exerciseFileName=watchExercise.exercisecode;
				exerciseId=watchExercise.id;
				exerciseLanguage=watchExercise.language;
				exerciseTitle.text=watchExercise.title;

				prepareVideoPlayer();
			}
		}

		public function onSubtitleLinesRetrieved(value:Boolean):void
		{
			if (DataModel.getInstance().availableSubtitleLinesRetrieved)
			{
				DataModel.getInstance().availableSubtitleLinesRetrieved=false;
				subtitleCollection=_cueManager.cuelist;
				if (DataModel.getInstance().unmodifiedAvailableSubtitleLines.length > 0)
					setSelectedSubtitleVersion(DataModel.getInstance().unmodifiedAvailableSubtitleLines.getItemAt(0).subtitleId);
				for each (var cueObj:CueObject in subtitleCollection)
				{
					cueObj.setStartCommand(new ShowHideSubtitleCommand(cueObj, VPSubtitle, subtitleList));
					cueObj.setEndCommand(new ShowHideSubtitleCommand(null, VPSubtitle, subtitleList));
				}
			}
		}

		private function onSubtitlesRetrieved(value:Boolean):void
		{
			var subversions:int = DataModel.getInstance().availableSubtitles ? DataModel.getInstance().availableSubtitles.length : 0;
			trace("Subtitle versions: "+subversions);
			availableSubtitleVersions=DataModel.getInstance().availableSubtitles;
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
			else
			{
				subtitleVersionBox.includeInLayout=false;
				subtitleVersionBox.visible=false;
			}
		}

		private function onRolesRetrieved(value:Boolean):void
		{

			if (DataModel.getInstance().availableExerciseRolesRetrieved.getItemAt(DataModel.SUBMODULE) == true)
			{
				var avrol:ArrayCollection=DataModel.getInstance().availableExerciseRoles.getItemAt(DataModel.SUBMODULE) as ArrayCollection;
				var cData:ArrayCollection=new ArrayCollection;
				var insertOption:RoleComboDataVO=new RoleComboDataVO(0, resourceManager.getString('myResources', 'OPTION_INSERT_NEW_ROLE'), RoleComboDataVO.ACTION_INSERT, RoleComboDataVO.FONT_BOLD, RoleComboDataVO.INDENT_NONE);
				cData.addItem(insertOption);
				if (avrol.length > 0)
				{
					for each (var itemIns:ExerciseRoleVO in avrol)
					{
						var selectLine:RoleComboDataVO=new RoleComboDataVO(itemIns.id, itemIns.characterName, RoleComboDataVO.ACTION_SELECT, RoleComboDataVO.FONT_NORMAL, RoleComboDataVO.INDENT_ROLE);
						cData.addItem(selectLine);
					}
					var deleteOption:RoleComboDataVO=new RoleComboDataVO(0, resourceManager.getString('myResources', 'OPTION_DELETE_A_ROLE'), RoleComboDataVO.ACTION_NO_ACTION, RoleComboDataVO.FONT_BOLD, RoleComboDataVO.INDENT_NONE);
					cData.addItem(deleteOption);
					for each (var itemDel:ExerciseRoleVO in avrol)
					{
						var deleteLine:RoleComboDataVO=new RoleComboDataVO(itemDel.id, itemDel.characterName, RoleComboDataVO.ACTION_DELETE, RoleComboDataVO.FONT_NORMAL, RoleComboDataVO.INDENT_ROLE);
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
				DataModel.getInstance().availableExercisesRetrieved.setItemAt(false, DataModel.SUBMODULE);
			}
		}

		private function onSubtitleSaved(value:Boolean):void
		{
			var currentExercise:ExerciseVO=DataModel.getInstance().currentExercise.getItemAt(0) as ExerciseVO;
			if (DataModel.getInstance().subtitleSaved)
			{
				_cueManager.removeAllCue();
				DataModel.getInstance().subtitleSaved=false;
				var subtitles:SubtitleAndSubtitleLinesVO=new SubtitleAndSubtitleLinesVO(0, currentExercise.id, '', currentExercise.language);

				new SubtitleEvent(SubtitleEvent.GET_MEDIA_SUBTITLES, new SubtitleAndSubtitleLinesVO(0, currentExercise.id, '', '')).dispatch();
				new SubtitleEvent(SubtitleEvent.GET_EXERCISE_SUBLINES, subtitles).dispatch();
			}
		}

		public function resetGroup():void
		{
			VPSubtitle.resetComponent();
			_cueManager.reset();

			subtitleVersionBox.includeInLayout=false;
			subtitleVersionBox.visible=false;
			availableSubtitleVersions=null;
			comboData=null;
		}
	}
}