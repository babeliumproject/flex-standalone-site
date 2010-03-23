package modules.subtitles
{

	import control.CuePointManager;
	
	import events.ExerciseRoleEvent;
	import events.SubtitleEvent;
	
	import flash.events.MouseEvent;
	
	import model.DataModel;
	
	import modules.videoPlayer.VideoPlayerBabelia;
	import modules.videoPlayer.events.VideoPlayerEvent;
	import modules.videoPlayer.events.babelia.StreamEvent;
	import modules.videoPlayer.events.babelia.SubtitlingEvent;
	import modules.videoUpload.IconComboBox;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.containers.HBox;
	import mx.containers.Panel;
	import mx.containers.ViewStack;
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.controls.DataGrid;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	
	import vo.CreditHistoryVO;
	import vo.CueObject;
	import vo.ExerciseRoleVO;
	import vo.ExerciseVO;
	import vo.SubtitleAndSubtitleLinesVO;


	public class SubtitleEditorClass extends HBox
	{
		private var cueManager:CuePointManager = CuePointManager.getInstance();
		private var videoPlayerReady:Boolean = false;
		
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
		public var comboData:ArrayCollection;

		//Visual components declaration
		[Bindable]
		public var VP:VideoPlayerBabelia=new VideoPlayerBabelia();

		public var subtitleEditor:Panel;
		public var subtitleExerciseButton:Button;
		public var subtitleList:DataGrid=new DataGrid();
		public var languageComboBox:IconComboBox;
		public var subtitlingControls:HBox;
		public var videoControls:ViewStack;

		public function SubtitleEditorClass()
		{
			this.addEventListener(FlexEvent.CREATION_COMPLETE, setBindings);
			setupVideoPlayer();
		}

		private function setBindings(event:FlexEvent):void
		{
			var model:DataModel=DataModel.getInstance();
			BindingUtils.bindSetter(onExerciseSelected, model, "currentExerciseRetrieved");
			BindingUtils.bindSetter(onSubtitleLinesRetrieved, model, "availableSubtitlesAndRolesRetrieved");
			BindingUtils.bindSetter(onSubtitleSaved, model, "subtitleSaved");
			BindingUtils.bindSetter(availableRolesRetrieved, model, "availableExerciseRoles");
			BindingUtils.bindSetter(onTabChange, model, "stopVideoFlag");
			BindingUtils.bindSetter(onLogout, model, "isLoggedIn");

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
			VP.videoSource = exerciseFileName;
			VP.addEventListener(StreamEvent.ENTER_FRAME, cueManager.monitorCuePoints);
			VP.enableSubtitlingEndButton = false;
		}

		public function onExerciseSelected(value:Boolean):void
		{
			if (DataModel.getInstance().currentExerciseRetrieved.getItemAt(0) == true)
			{
				DataModel.getInstance().currentExerciseRetrieved.setItemAt(false, 0);
				var watchExercise:ExerciseVO=DataModel.getInstance().currentExercise.getItemAt(0) as ExerciseVO;
				exerciseFileName=watchExercise.name;
				exerciseId=watchExercise.id;
				exerciseLanguage=watchExercise.language;
				
				if ( videoPlayerReady )
				{
					// Avoid bug #188, streaming error on tab change
					VP.videoSource = "";
					VP.videoSource = watchExercise.name;
					VP.removeEventListener(StreamEvent.ENTER_FRAME, cueManager.monitorCuePoints);
					VP.addEventListener(StreamEvent.ENTER_FRAME, cueManager.monitorCuePoints);
					VP.enableSubtitlingEndButton = false;	
				}
			}
		}


		public function resolveIdToRole(item:Object, column:DataGridColumn):String
		{
			for each (var dp:Object in comboData)
			{
				if (dp.roleId == item.roleId)
					return dp.charName;
			}
			return "";
		}


		public function onSubtitleLinesRetrieved(value:Boolean):void
		{
			if (DataModel.getInstance().availableSubtitleLinesRetrieved)
			{
				DataModel.getInstance().availableSubtitleLinesRetrieved=false;
				subtitleCollection=cueManager.getCuelist();
			}
		}

		public function subtitleStartHandler(e:SubtitlingEvent):void
		{
			VP.enableSubtitlingEndButton = true;
			subtitleStartTime=e.time;
			startEntry=new CueObject(subtitleStartTime, subtitleStartTime + 0.5,'',0,'');

			cueManager.addCue(startEntry);

		}

		public function subtitleEndHandler(e:SubtitlingEvent):void
		{
			VP.enableSubtitlingEndButton = false;
			if (subtitleCollection.length > 0)
			{
				subtitleEndTime=e.time;
				endEntry=new CueObject(subtitleStartTime, subtitleEndTime, '',0,'');
				
				cueManager.setCueAt(endEntry, cueManager.getCueIndex(startEntry));
			}
		}

		public function subtitleInsertHandler():void
		{

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
			if (subtitleCollection.length > 0)
			{
				if (subtitlesWereModified())
				{
					var errors:String=checkSubtitleErrors();
					if (errors.length == 0)
					{
						for each (var s:CueObject in subtitleCollection)
						{
							for each (var dp:Object in comboData)
							{
								if (dp.roleId == s.getRoleId())
								{
									s.setRole(dp.charName);
								}
							}
						}
						var subtitleLines:Array=subtitleCollection.toArray();
						var subtitles:SubtitleAndSubtitleLinesVO=new SubtitleAndSubtitleLinesVO();
						subtitles.exerciseId=currentExercise.id;
						subtitles.userId=DataModel.getInstance().loggedUser.id;
						subtitles.language=exerciseLanguage;
						subtitles.subtitleLines=subtitleLines;
						if (DataModel.getInstance().availableSubtitleLines.length == 0)
							subtitles.id=0;
						else
							subtitles.id=DataModel.getInstance().availableSubtitleLines.getItemAt(0).subtitleId;

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

		private function subtitlesWereModified():Boolean
		{
			var modified:Boolean = false;
			var unmodifiedSubtitlesLines:ArrayCollection = DataModel.getInstance().unmodifiedAvailableSubtitleLines;
			if (unmodifiedSubtitlesLines.length != subtitleCollection.length)
				modified = true;
			else{
				var i:int;
				for(i=0; i<unmodifiedSubtitlesLines.length; i++){
					if(unmodifiedSubtitlesLines.getItemAt(i).text != subtitleCollection.getItemAt(i).text){
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
					if (subtitleCollection.getItemAt((i - 1)).hideTime >= subtitleCollection.getItemAt(i).showTime)
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
				DataModel.getInstance().subtitleSaved=false;
				var subtitles:SubtitleAndSubtitleLinesVO=new SubtitleAndSubtitleLinesVO(0, currentExercise.id, 0, currentExercise.language);
				var roles:ExerciseRoleVO = new ExerciseRoleVO();
				roles.exerciseId = currentExercise.id;
				new ExerciseRoleEvent(ExerciseRoleEvent.GET_EXERCISE_ROLES, roles).dispatch();
				new SubtitleEvent(SubtitleEvent.GET_EXERCISE_SUBTITLE_LINES, subtitles).dispatch();
			}

		}

		private function availableRolesRetrieved(value:Boolean):void
		{

			if (DataModel.getInstance().availableExerciseRoles)
			{
				var avrol:ArrayCollection=DataModel.getInstance().availableExerciseRoles.getItemAt(0) as ArrayCollection;
				var cData:ArrayCollection=new ArrayCollection;
				var insertLine:Object={roleId: 0, charName: resourceManager.getString('myResources', 'OPTION_INSERT_NEW_ROLE'), action: 'insert', fontWeight: 'bold', indent: 0};
				cData.addItem(insertLine);
				if (avrol.length > 0)
				{
					for each (var item:Object in avrol)
					{
						var comboline:Object={roleId: item.data, charName: item.label, action: 'select', fontWeight: 'normal', indent: 10};
						cData.addItem(comboline);
					}
					var deleteLine:Object={roleId: 0, charName: resourceManager.getString('myResources', 'OPTION_DELETE_A_ROLE'), action: 'nothing', fontWeight: 'bold', indent: 0};
					cData.addItem(deleteLine);
					for each (var item2:Object in avrol)
					{
						var comboline2:Object={roleId: item2.data, charName: item2.label, action: 'delete', fontWeight: 'normal', indent: 10};
						cData.addItem(comboline2);
					}
					comboData.removeAll();
					comboData=cData;
				}
				else
				{
					var deleteLineEmpty:Object={roleId: 0, charName: resourceManager.getString('myResources', 'OPTION_DELETE_A_ROLE'), action: 'nothing', fontWeight: 'bold', indent: 0};
					cData.addItem(deleteLineEmpty);
					comboData.removeAll();
					comboData=cData;
				}
			}
		}

		public function lfRowNum(oItem:Object, iCol:int):String
		{
			var iIndex:int=cueManager.getCueIndex(oItem as CueObject) + 1;
			return String(iIndex);
		}


		public function viewSubtitlingControls(event:MouseEvent):void
		{
			if( !VP.subtitlingControls ){
				VP.subtitlingControls = true;
			} else {
				VP.subtitlingControls = false;
			}
		}

		public function hideSubtitlingControls(event:MouseEvent):void
		{
			subtitleEditorVisible=false;
		}

		public function onTabChange(value:Boolean):void
		{
			VP.endVideo();
			VP.subtitlingControls = false;
			VP.removeEventListener(StreamEvent.ENTER_FRAME, cueManager.monitorCuePoints);
			hideSubtitlingControls(null);
		}

		public function onLogout(value:Boolean):void
		{
			if (DataModel.getInstance().isLoggedIn == false)
			{
				onTabChange(false);
			}
		}


	}
}