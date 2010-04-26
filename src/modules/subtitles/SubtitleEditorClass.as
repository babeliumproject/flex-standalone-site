package modules.subtitles
{

	import commands.cuepointManager.ShowHideSubtitleCommand;
	
	import control.BabeliaBrowserManager;
	import control.CuePointManager;
	
	import events.ExerciseRoleEvent;
	import events.SubtitleEvent;
	import events.ViewChangeEvent;
	
	import flash.events.MouseEvent;
	
	import model.DataModel;
	
	import modules.videoPlayer.VideoPlayer;
	import modules.videoPlayer.VideoPlayerBabelia;
	import modules.videoPlayer.events.VideoPlayerEvent;
	import modules.videoPlayer.events.babelia.StreamEvent;
	import modules.videoPlayer.events.babelia.SubtitlingEvent;
	import modules.videoUpload.IconComboBox;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.containers.HBox;
	import mx.containers.Panel;
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.controls.DataGrid;
	import mx.controls.Label;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	
	import vo.CreditHistoryVO;
	import vo.CueObject;
	import vo.ExerciseRoleVO;
	import vo.ExerciseVO;
	import vo.RoleComboDataVO;
	import vo.SubtitleAndSubtitleLinesVO;
	import vo.SubtitleLineVO;


	public class SubtitleEditorClass extends HBox
	{
		private var cueManager:CuePointManager = CuePointManager.getInstance();
		[Bindable]
		private var videoPlayerReady:Boolean = false;
		
		[Bindable] public var videoPlaybackStartedState:int = VideoPlayer.PLAYBACK_STARTED_STATE;
		
		[Bindable] 
		public var streamSource:String = "rtmp://" + DataModel.getInstance().server + "/oflaDemo";

		private var exerciseFileName:String;
		private var exerciseId:int;
		private var exerciseLanguage:String;

		[Bindable]
		public var subtitleCollection:ArrayCollection;

		[Bindable]
		[Embed(source="../../resources/images/flags/flag_united_kingdom.png")]
		public var FlagEnglish:Class;

		[Bindable]
		[Embed(source="../../resources/images/flags/flag_spain.png")]
		public var FlagSpanish:Class;

		[Bindable]
		[Embed(source="../../resources/images/flags/flag_france.png")]
		public var FlagFrench:Class;

		[Bindable]
		[Embed(source="../../resources/images/flags/flag_basque_country.png")]
		public var FlagBasque:Class;

		[Bindable]
		public var flaggedLanguageData:Array=new Array({label: 'English', icon: 'FlagEnglish'}, {label: 'Spanish', icon: 'FlagSpanish'}, {label: 'Basque', icon: 'FlagBasque'}, {label: 'French', icon: 'FlagFrench'});

		[Bindable]
		private var subtitleStartTime:Number=0;
		[Bindable]
		private var subtitleEndTime:Number=0;

		private var startEntry:CueObject;
		private var endEntry:CueObject;

		[Bindable]
		public var subtitleStarted:Boolean=false;

		[Bindable]
		public var videoPlayerControlsViewStack:int=1;
		public var subtitleEditorVisible:Boolean=false;


		[Bindable]
		public var comboData:ArrayCollection = new ArrayCollection();

		//Visual components declaration
		[Bindable]
		public var VP:VideoPlayerBabelia = new VideoPlayerBabelia();
		public var exerciseTitle:Label;
		public var subtitleExerciseButton:Button;

		public var subtitleEditor:Panel;
		public var subtitleList:DataGrid=new DataGrid();
		public var languageComboBox:IconComboBox;

		private var browser:BabeliaBrowserManager;
		
		public function SubtitleEditorClass()
		{
			this.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
		}

		private function onCreationComplete(event:FlexEvent):void
		{
			var model:DataModel=DataModel.getInstance();
			browser=BabeliaBrowserManager.getInstance();
			setupVideoPlayer();

			BindingUtils.bindSetter(onExerciseSelected, model, "currentExerciseRetrieved");
			BindingUtils.bindSetter(onSubtitleLinesRetrieved, model, "availableSubtitleLinesRetrieved");
			BindingUtils.bindSetter(onSubtitleSaved, model, "subtitleSaved");
			BindingUtils.bindSetter(onRolesRetrieved, model, "availableExerciseRolesRetrieved");
			BindingUtils.bindSetter(onTabChange, model, "stopVideoFlag");
			BindingUtils.bindSetter(onLogout, model, "isLoggedIn");

			BindingUtils.bindSetter(onURLChange, browser, "targetFragment");
			
			BindingUtils.bindProperty(subtitleEditor, "visible", model, "isLoggedIn");
			BindingUtils.bindProperty(subtitleExerciseButton, "enabled", model, "isLoggedIn");

		}
		
		public function setupVideoPlayer() : void
		{
			VP.addEventListener(VideoPlayerEvent.CONNECTED, onVideoPlayerReady);
			VP.addEventListener(SubtitlingEvent.START, subtitleStartHandler);
			VP.addEventListener(SubtitlingEvent.END, subtitleEndHandler);
		}
		
		public function onVideoPlayerReady(e:VideoPlayerEvent) : void
		{
			videoPlayerReady = true;
			VP.stopVideo();

			onExerciseSelected(true);
		}

		public function onExerciseSelected(value:Boolean):void
		{
			if (DataModel.getInstance().currentExerciseRetrieved.getItemAt(DataModel.SUBTITLE_MODULE) && videoPlayerReady)
			{
				DataModel.getInstance().currentExerciseRetrieved.setItemAt(false, DataModel.SUBTITLE_MODULE);
				var watchExercise:ExerciseVO=DataModel.getInstance().currentExercise.getItemAt(DataModel.SUBTITLE_MODULE) as ExerciseVO;
				exerciseFileName=watchExercise.name;
				exerciseId=watchExercise.id;
				exerciseLanguage=watchExercise.language;
				exerciseTitle.text = watchExercise.title;

				prepareVideoPlayer();

			}
		}
		
		public function prepareVideoPlayer():void{
			VP.stopVideo();
			VP.videoSource = exerciseFileName;
			VP.removeEventListener(StreamEvent.ENTER_FRAME, cueManager.monitorCuePoints);
			VP.addEventListener(StreamEvent.ENTER_FRAME, cueManager.monitorCuePoints);
			VP.enableSubtitlingEndButton = false;	
		}

		public function resolveIdToRole(item:Object, column:DataGridColumn):String
		{
			var label:String = "";
			for each (var dp:RoleComboDataVO in comboData)
			{
				if (dp.roleId == item.roleId){
					label = dp.charName;
					break;
				}
			}
			return label;
		}


		public function onSubtitleLinesRetrieved(value:Boolean):void
		{
			if (DataModel.getInstance().availableSubtitleLinesRetrieved)
			{
				DataModel.getInstance().availableSubtitleLinesRetrieved=false;
				subtitleCollection=cueManager.cuelist;
				for each (var cueObj:CueObject in subtitleCollection){
					cueObj.setStartCommand(new ShowHideSubtitleCommand(cueObj, VP));
					cueObj.setEndCommand(new ShowHideSubtitleCommand(null, VP));
				}
			}
		}
		
		private function onRolesRetrieved(value:Boolean):void
		{

			if (DataModel.getInstance().availableExerciseRolesRetrieved.getItemAt(DataModel.SUBTITLE_MODULE) == true)
			{
				var avrol:ArrayCollection=DataModel.getInstance().availableExerciseRoles.getItemAt(DataModel.SUBTITLE_MODULE) as ArrayCollection;
				var cData:ArrayCollection=new ArrayCollection;
				var insertOption:RoleComboDataVO = new RoleComboDataVO(0, resourceManager.getString('myResources', 'OPTION_INSERT_NEW_ROLE'), RoleComboDataVO.ACTION_INSERT, RoleComboDataVO.FONT_BOLD, RoleComboDataVO.INDENT_NONE);
				cData.addItem(insertOption);
				if (avrol.length > 0)
				{
					for each (var itemIns:ExerciseRoleVO in avrol)
					{
						var selectLine:RoleComboDataVO = new RoleComboDataVO(itemIns.id, itemIns.characterName, RoleComboDataVO.ACTION_SELECT, RoleComboDataVO.FONT_NORMAL, RoleComboDataVO.INDENT_ROLE);
						cData.addItem(selectLine);
					}
					var deleteOption:RoleComboDataVO = new RoleComboDataVO(0, resourceManager.getString('myResources', 'OPTION_DELETE_A_ROLE'), RoleComboDataVO.ACTION_NO_ACTION, RoleComboDataVO.FONT_BOLD, RoleComboDataVO.INDENT_NONE);
					cData.addItem(deleteOption);
					for each (var itemDel:ExerciseRoleVO in avrol)
					{
						var deleteLine:RoleComboDataVO = new RoleComboDataVO(itemDel.id, itemDel.characterName, RoleComboDataVO.ACTION_DELETE, RoleComboDataVO.FONT_NORMAL, RoleComboDataVO.INDENT_ROLE);
						cData.addItem(deleteLine);
					}
					comboData.removeAll();
					comboData=cData;
					
				}
				else
				{
					var deleteOptionEmpty:RoleComboDataVO = new RoleComboDataVO(0, resourceManager.getString('myResources', 'OPTION_DELETE_A_ROLE'), RoleComboDataVO.ACTION_NO_ACTION, RoleComboDataVO.FONT_BOLD, RoleComboDataVO.INDENT_NONE);
					cData.addItem(deleteOptionEmpty);
					comboData.removeAll();
					comboData=cData;
				}
				DataModel.getInstance().availableExercisesRetrieved.setItemAt(false, DataModel.SUBTITLE_MODULE);
			}
		}

		public function subtitleStartHandler(e:SubtitlingEvent):void
		{
			VP.enableSubtitlingEndButton = true;
			subtitleStartTime=e.time; 
			startEntry=new CueObject(subtitleStartTime, subtitleStartTime + 0.5,'',0,'');
			startEntry.setStartCommand(new ShowHideSubtitleCommand(startEntry,VP));
			startEntry.setEndCommand(new ShowHideSubtitleCommand(null,VP));

			cueManager.addCue(startEntry);

		}

		public function subtitleEndHandler(e:SubtitlingEvent):void
		{
			VP.enableSubtitlingEndButton = false;
			if (subtitleCollection.length > 0)
			{
				subtitleEndTime=e.time;
				endEntry=new CueObject(subtitleStartTime, subtitleEndTime, '',0,'');
				endEntry.setStartCommand(new ShowHideSubtitleCommand(endEntry,VP));
				endEntry.setEndCommand(new ShowHideSubtitleCommand(null,VP));
				cueManager.setCueAt(endEntry, cueManager.getCueIndex(startEntry));
			}
		}

		public function subtitleInsertHandler(e:MouseEvent):void
		{
			VP.onSubtitlingEvent(new SubtitlingEvent( SubtitlingEvent.START ));
		}

		public function subtitleRemoveHandler():void
		{
			if (subtitleList.selectedIndex != -1)
			{

				var previouslySelectedIndex:Number=subtitleList.selectedIndex;
				var indexToBeSelected:Number;
				if (previouslySelectedIndex == subtitleList.rowCount)
				{
					indexToBeSelected=previouslySelectedIndex - 1;
				}
				else if (previouslySelectedIndex == 0 && subtitleList.rowCount == 1)
				{
					//nothing
				}
				else
				{
					indexToBeSelected=previouslySelectedIndex;
				}
				cueManager.removeCueAt(subtitleList.selectedIndex);
				subtitleList.selectedIndex=indexToBeSelected;

			}
		}

		public function subtitleClearHandler():void
		{
			Alert.show(resourceManager.getString('myResources', 'WARNING_CLEAR_SUBTITLE_LINES'), resourceManager.getString('myResources', 'TITLE_CONFIRM_ACTION'), Alert.YES | Alert.NO, null, subtitleClearConfirmation, null, Alert.NO);
		}

		private function subtitleClearConfirmation(event:CloseEvent):void
		{
			if (event.detail == Alert.YES)
				cueManager.removeAllCue();
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
				var tempEntry:CueObject=cueManager.getCueAt(subtitleList.selectedIndex) as CueObject;
				VP.seekTo(tempEntry.getStartTime());
			}
		}

		public function saveSubtitlesHandler():void
		{
			var currentExercise:ExerciseVO=DataModel.getInstance().currentExercise.getItemAt(0) as ExerciseVO;
			var subLines:ArrayCollection = new ArrayCollection();
			if (subtitleCollection.length > 0)
			{
				for each (var s:CueObject in subtitleCollection)
				{
					var subLine:SubtitleLineVO = new SubtitleLineVO(0,0,s.startTime,s.endTime,s.text,s.roleId)
					for each (var dp:Object in comboData)
					{
						if (dp.roleId == subLine.exerciseRoleId)
						{
							subLine.exerciseRoleName = dp.charName;
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
						var subtitles:SubtitleAndSubtitleLinesVO=new SubtitleAndSubtitleLinesVO();
						subtitles.exerciseId=currentExercise.id;
						subtitles.userId=DataModel.getInstance().loggedUser.id;
						subtitles.language=exerciseLanguage;
						subtitles.subtitleLines=subtitleLines;
						//if (DataModel.getInstance().unmodifiedAvailableSubtitleLines.length == 0)
							subtitles.id=0;
						//else
						//	subtitles.id=DataModel.getInstance().availableSubtitleLines.getItemAt(0).subtitleId;

						var subHistoricData:CreditHistoryVO=new CreditHistoryVO();
						subHistoricData.videoExerciseId=currentExercise.id;
						subHistoricData.videoExerciseName=currentExercise.name;
						DataModel.getInstance().subHistoricData=subHistoricData;
						new SubtitleEvent(SubtitleEvent.SAVE_SUBTITLE_AND_SUBTITLE_LINES, subtitles).dispatch();
					}
					else
					{
						Alert.show(errors, resourceManager.getString('myResources', 'WARNING_SUBTITLE_HAS_ERRORS'));
					}
				}
				else
				{
					Alert.show(resourceManager.getString('myResources','WARNING_NOT_MODIFIED_SUBTITLES'), resourceManager.getString('myResources', 'TITLE_INFORMATION_MESSAGE'));
				}
			}
			else
			{
				Alert.show(resourceManager.getString('myResources', 'WARNING_EMPTY_SUBTITLE'), resourceManager.getString('myResources', 'TITLE_INFORMATION_MESSAGE'));
			}

		}

		private function subtitlesWereModified(compareSubject:ArrayCollection):Boolean
		{
			var modified:Boolean = false;
			var unmodifiedSubtitlesLines:ArrayCollection = DataModel.getInstance().unmodifiedAvailableSubtitleLines;
			if (unmodifiedSubtitlesLines.length != compareSubject.length)
				modified = true;
			else{
				var i:int;
				for(i=0; i<unmodifiedSubtitlesLines.length; i++){
					if(unmodifiedSubtitlesLines.getItemAt(i).text != compareSubject.getItemAt(i).text){
						modified = true;
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
					errorMessage+="The role on the line " + (i + 1) + " is empty.\n";
				var lineText:String=subtitleCollection.getItemAt(i).text;
				lineText=lineText.replace(/[ ,\;.\:\-_?¿¡!€$']*/, "");
				if (lineText.length < 1)
					errorMessage+="The text on the line " + (i + 1) + " is empty.\n";
				if (i > 0)
				{
					if (subtitleCollection.getItemAt((i - 1)).endTime >= subtitleCollection.getItemAt(i).startTime)
						errorMessage+="The subtitle on the line " + i + " overlaps with the next subtitle.\n";
				}
			}
			return errorMessage;
		}

		private function onSubtitleSaved(value:Boolean):void
		{
			var currentExercise:ExerciseVO=DataModel.getInstance().currentExercise.getItemAt(0) as ExerciseVO;
			if (DataModel.getInstance().subtitleSaved)
			{
				cueManager.removeAllCue();
				DataModel.getInstance().subtitleSaved=false;
				var subtitles:SubtitleAndSubtitleLinesVO=new SubtitleAndSubtitleLinesVO(0, currentExercise.id, 0, '', currentExercise.language);
				var roles:ExerciseRoleVO = new ExerciseRoleVO();
				roles.exerciseId = currentExercise.id;
				new ExerciseRoleEvent(ExerciseRoleEvent.GET_EXERCISE_ROLES, roles).dispatch();
				new SubtitleEvent(SubtitleEvent.GET_EXERCISE_SUBTITLE_LINES, subtitles).dispatch();
			}

		}

		

		public function lfRowNum(oItem:Object, iCol:int):String
		{
			var iIndex:int=cueManager.getCueIndex(oItem as CueObject) + 1;
			return String(iIndex);
		}


		public function viewSubtitlingControls(event:MouseEvent):void
		{
			if(!subtitleEditorVisible){
				videoPlayerControlsViewStack=0;
				VP.subtitlingControls = true;
				subtitleEditorVisible=!subtitleEditorVisible;
				
				// Update URL
				BabeliaBrowserManager.getInstance().updateURL(
					BabeliaBrowserManager.index2fragment(ViewChangeEvent.VIEWSTACK_PLAYER_MODULE_INDEX),
					BabeliaBrowserManager.SUBTITLE,
					exerciseFileName);
				
			} else {
				videoPlayerControlsViewStack=1;
				VP.subtitlingControls = false;
				subtitleEditorVisible=!subtitleEditorVisible;
				
				// Update URL
				BabeliaBrowserManager.getInstance().updateURL(
					BabeliaBrowserManager.index2fragment(ViewChangeEvent.VIEWSTACK_PLAYER_MODULE_INDEX),
					BabeliaBrowserManager.VIEW,
					exerciseFileName);
			}
		}

		public function hideSubtitlingControls(event:MouseEvent):void
		{
			subtitleEditorVisible=false;
		}

		public function onTabChange(value:Boolean):void
		{
			if (videoPlayerReady){
				VP.endVideo();
				VP.setSubtitle(""); // Clear subtitles if any
				VP.videoSource = ""; // Reset video source
				VP.subtitlingControls = false;
				VP.removeEventListener(StreamEvent.ENTER_FRAME, cueManager.monitorCuePoints);
			}
			hideSubtitlingControls(null);
		}

		public function onLogout(value:Boolean):void
		{
			if (DataModel.getInstance().isLoggedIn == false)
			{
				onTabChange(false);
			}
		}
		
		public function onURLChange(value:Object) : void
		{
			if ( browser.moduleIndex != ViewChangeEvent.VIEWSTACK_PLAYER_MODULE_INDEX )
				return;
			
			if ( value == null )
				return;
			
			var actionFragment:String = browser.actionFragment;
			
			if ( actionFragment == BabeliaBrowserManager.VIEW
					|| actionFragment == BabeliaBrowserManager.SUBTITLE )
			{
				if ( browser.targetFragment != '' )
				{
					var tempEx:ExerciseVO = null;
					var exercises:ArrayCollection = DataModel.getInstance().availableExercises;
					
					for ( var i:int = 0; i < exercises.length; i++ )
					{
						var tmp:ExerciseVO = exercises.getItemAt(i) as ExerciseVO;
						if ( tmp.name == browser.targetFragment )
						{
							tempEx = tmp;
							break;
						}
					}
					
					if ( tempEx == null )
					{
						new ViewChangeEvent(ViewChangeEvent.VIEW_HOME_MODULE).dispatch();
						return;
					}
					else
						exerciseFileName = tempEx.name;
					
					var subtitles:SubtitleAndSubtitleLinesVO=new SubtitleAndSubtitleLinesVO(0, tempEx.id, 0, '', tmp.language);
					var roles:ExerciseRoleVO=new ExerciseRoleVO();
					roles.exerciseId=tempEx.id;
					
					//If it doesn't work this way, we can chain the events
					new ExerciseRoleEvent(ExerciseRoleEvent.GET_EXERCISE_ROLES, roles).dispatch();
					new SubtitleEvent(SubtitleEvent.GET_EXERCISE_SUBTITLE_LINES, subtitles).dispatch();
					DataModel.getInstance().currentExercise.setItemAt(tempEx, DataModel.SUBTITLE_MODULE);
					DataModel.getInstance().currentExerciseRetrieved.setItemAt(true, DataModel.SUBTITLE_MODULE);
				}
				else
				{
					new ViewChangeEvent(ViewChangeEvent.VIEW_HOME_MODULE).dispatch();
					return;
				}
			}
			
			if ( actionFragment == BabeliaBrowserManager.SUBTITLE &&
					DataModel.getInstance().isLoggedIn )
			{
				subtitleEditorVisible = false;
				viewSubtitlingControls(null);
			}
			else if ( actionFragment == BabeliaBrowserManager.VIEW )
			{
				subtitleEditorVisible = true;
				viewSubtitlingControls(null);
			}
		}

	}
}