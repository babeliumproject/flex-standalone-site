package modules.subtitle.view
{

	import commands.cuepointManager.ShowHideSubtitleCommand;
	
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
		/**
		 * Singleton objects
		 */
		private var _dataModel:DataModel=DataModel.getInstance();

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

			BindingUtils.bindSetter(onExerciseSelected, _dataModel, "currentExerciseRetrieved", false, true);
			BindingUtils.bindSetter(onSubtitleLinesRetrieved, _dataModel, "availableSubtitleLinesRetrieved", false, true);
			BindingUtils.bindSetter(onSubtitleSaved, _dataModel, "subtitleSaved", false, true);
			BindingUtils.bindSetter(onRolesRetrieved, _dataModel, "availableExerciseRolesRetrieved", false, true);
			BindingUtils.bindSetter(onSubtitlesRetrieved, _dataModel, "availableSubtitlesRetrieved", false, true);

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
			media.netConnectionUrl=netConnectionUrl;
			media.mediaUrl=EXERCISE_FOLDER + '/' + exerciseFileName;

			VPSubtitle.loadVideoByUrl(media);

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
			subtitleStartTime=(e.time < 0.5) ? 0.5 : e.time;
			startEntry=new CueObject(0, subtitleStartTime, subtitleStartTime + 0.5, '', 0, '');
			startEntry.setStartCommand(new ShowHideSubtitleCommand(startEntry, VPSubtitle));
			startEntry.setEndCommand(new ShowHideSubtitleCommand(null, VPSubtitle));

			VPSubtitle.setCaptions(subtitleCollection);

		}

		public function subtitleEndHandler(e:SubtitlingEvent):void
		{
			if (subtitleCollection && subtitleCollection.length > 0)
			{
				subtitleEndTime=(e.time < (VPSubtitle.duration - 0.5)) ? e.time : VPSubtitle.duration - 0.5;
				endEntry=new CueObject(0, subtitleStartTime, subtitleEndTime, '', 0, '');
				endEntry.setStartCommand(new ShowHideSubtitleCommand(endEntry, VPSubtitle));
				endEntry.setEndCommand(new ShowHideSubtitleCommand(null, VPSubtitle));
				VPSubtitle.setCaptions(subtitleCollection);
			}
		}

		private var _mediaStatus:int;

		public function onMediaStateChange(e:MediaStatusEvent):void
		{
			_mediaStatus=e.state;
		}

		public function subtitleInsertHandler(e:MouseEvent):void
		{
			if (_mediaStatus == videoPlaybackStartedState)
			{
				VPSubtitle.onSubtitlingEvent(new SubtitlingEvent(SubtitlingEvent.START));
			}
			else
			{
				if (subtitleCollection && subtitleCollection.length > 0)
				{
					var lastSub:Object=subtitleCollection.getItemAt(subtitleCollection.length - 1);
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

				VPSubtitle.setCaptions(subtitleCollection);
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
				VPSubtitle.setCaptions(null);
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
				var tempEntry:Object=subtitleList.selectedIndex as Object;
				VPSubtitle.seekTo(tempEntry.showTime);
			}
		}
		
		public function highlightSubtitle(time:Number):void{
			if(!isNaN(time) && subtitleList && subtitleList.rowCount){
				var item:Object = CollectionUtils.findInCollection(subtitleCollection, CollectionUtils.findField('showTime', time) as Function);
				if(item) subtitleList.selectedItem = item;
			}
		}

		public function saveSubtitlesHandler():void
		{
			var currentExercise:ExerciseVO=DataModel.getInstance().currentExercise.getItemAt(0) as ExerciseVO;
			var subLines:ArrayCollection=new ArrayCollection();
			if (subtitleCollection.length > 0)
			{
				for each (var s:Object in subtitleCollection)
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
			for (var i:int=0; i < subtitleCollection.length; i++)
			{
				if (subtitleCollection.getItemAt(i).exerciseRoleId < 1)
					errorMessage+=StringUtil.substitute(resourceManager.getString('myResources', 'ROLE_EMPTY') + "\n", i + 1);
				var lineText:String=subtitleCollection.getItemAt(i).text;
				lineText=lineText.replace(/[ ,\;.\:\-_?¿¡!€$']*/, "");
				if (lineText.length < 1)
					errorMessage+=StringUtil.substitute(resourceManager.getString('myResources', 'EMPTY') + "\n", i + 1);
				if (i > 0)
				{
					if ((subtitleCollection.getItemAt((i - 1)).hideTime + 0.2) >= subtitleCollection.getItemAt(i).showTime)
						errorMessage+=StringUtil.substitute(resourceManager.getString('myResources', 'SUBOVERLAPS') + "\n", i);
				}
				var hideTime:Number=subtitleCollection.getItemAt(i).hideTime;
				var showTime:Number=subtitleCollection.getItemAt(i).showTime;
				if ((hideTime > VPSubtitle.duration - 0.5) || hideTime < 0.5 || showTime < 0.5 || showTime > VPSubtitle.duration - 0.5)
					errorMessage+=StringUtil.substitute(resourceManager.getString('myResources', 'SUBTIME_OUT_OF_BOUNDS') + "\n", i + 1);
			}
			return errorMessage;
		}



		public function lfRowNum(oItem:Object, iCol:int):String
		{
			var iIndex:int=int(oItem) + 1;
			return String(iIndex);
		}

		public function subtitleVersionComboLabelFunction(item:Object):String
		{
			var currentLocale:String=ResourceManager.getInstance().localeChain[0];
			var dFormatter:DateTimeFormatter=new DateTimeFormatter(currentLocale, DateTimeStyle.SHORT, DateTimeStyle.SHORT);
			var date:Date=new Date(item.timecreated * 1000);
			if (item != null)
				return "[" + dFormatter.format(date) + "]  " + item.username;
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

		/**
		 * Called each time the property "availableSubtitlesRetrieved" changes in the model
		 * 	@param value
		 */		
		private function onSubtitlesRetrieved(value:Boolean):void
		{
			var subversions:int=DataModel.getInstance().availableSubtitles ? DataModel.getInstance().availableSubtitles.length : 0;
			
			var mediaData:Object=_dataModel.subtitleMedia;
			
			trace("Subtitle media: "+ObjectUtil.toString(mediaData));
			trace("Subtitle versions: " + subversions);
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
		
		public function onSubtitleLinesRetrieved(value:Boolean):void
		{
			subtitleCollection=_dataModel.availableSubtitleLines;
			var unmodifiedSubtitleCollection:ArrayCollection=_dataModel.unmodifiedAvailableSubtitleLines;
			
			VPSubtitle.setCaptions(subtitleCollection, this);
			
			if (unmodifiedSubtitleCollection && unmodifiedSubtitleCollection.length > 0)
				setSelectedSubtitleVersion(unmodifiedSubtitleCollection.getItemAt(0).subtitleId);
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
			var currentExercise:ExerciseVO=DataModel.getInstance().currentExercise.getItemAt(0) as ExerciseVO;
			if (DataModel.getInstance().subtitleSaved)
			{
				VPSubtitle.setCaptions(null);
				DataModel.getInstance().subtitleSaved=false;
				var subtitles:SubtitleAndSubtitleLinesVO=new SubtitleAndSubtitleLinesVO(0, currentExercise.id, '', currentExercise.language);

				new SubtitleEvent(SubtitleEvent.GET_MEDIA_SUBTITLES, new SubtitleAndSubtitleLinesVO(0, currentExercise.id, '', '')).dispatch();
				new SubtitleEvent(SubtitleEvent.GET_EXERCISE_SUBLINES, subtitles).dispatch();
			}
		}

		public function resetGroup():void
		{
			VPSubtitle.resetComponent();

			subtitleVersionBox.includeInLayout=false;
			subtitleVersionBox.visible=false;
			availableSubtitleVersions=null;
			comboData=null;
		}
	}
}
