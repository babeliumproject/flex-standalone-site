package modules.evaluation
{
	import commands.cuepointManager.RecordingOtherRoleCommand;
	import commands.cuepointManager.ShowHideSubtitleCommand;
	import commands.cuepointManager.StartRecordingSelectedRoleCommand;
	import commands.cuepointManager.StopRecordingSelectedRoleCommand;
	
	import control.BabeliaBrowserManager;
	import control.CuePointManager;
	
	import events.CueManagerEvent;
	import events.EvaluationEvent;
	import events.ViewChangeEvent;
	
	import flash.events.MouseEvent;
	
	import model.DataModel;
	
	import modules.autoevaluation.AutoevaluationPanel;
	import modules.search.VideoPaginator;
	import modules.videoPlayer.VideoPlayer;
	import modules.videoPlayer.VideoPlayerBabelia;
	import modules.videoPlayer.events.VideoPlayerEvent;
	import modules.videoPlayer.events.babelia.StreamEvent;
	import modules.videoPlayer.events.babelia.VideoPlayerBabeliaEvent;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.containers.TabNavigator;
	import mx.containers.ViewStack;
	import mx.controls.DataGrid;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.events.FlexEvent;
	import mx.events.IndexChangedEvent;
	import mx.events.ListEvent;
	import mx.managers.BrowserManager;
	import mx.managers.PopUpManager;
	import mx.resources.ResourceManager;
	
	import spark.components.Button;
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.components.NavigatorContent;
	import spark.components.VGroup;
	import spark.layouts.VerticalAlign;
	
	import view.common.CustomAlert;
	import view.common.TimeFormatter;
	
	import vo.CreditHistoryVO;
	import vo.CueObject;
	import vo.EvaluationVO;
	
	public class EvaluationMainClass extends VGroup
	{
		
		/**
		 * Constants
		 */
		private const EXERCISE_FOLDER:String=DataModel.getInstance().exerciseStreamsFolder;
		private const RESPONSE_FOLDER:String=DataModel.getInstance().responseStreamsFolder;
		private const EVALUATION_FOLDER:String=DataModel.getInstance().evaluationStreamsFolder;
		
		private var dataModel:DataModel=DataModel.getInstance();
		private var browserManager:BabeliaBrowserManager = BabeliaBrowserManager.getInstance();
		private var _cueManager:CuePointManager=CuePointManager.getInstance();
		private var _cueManagerReady:Boolean=false;
		
		private var _timeFormatter:TimeFormatter=new TimeFormatter();
		
		[Bindable]
		public var _streamSource:String=DataModel.getInstance().streamingResourcesPath;
		[Bindable]
		public var thumbUrl:String=DataModel.getInstance().thumbURL;
		[Bindable]
		public var _exerciseTitle:String=ResourceManager.getInstance().getString('myResources', 'LABEL_EXERCISE_TITLE');
		[Bindable]
		public var _evaluationSelected:Boolean=false;
		
		private var _videoPlayerReady:Boolean=false;
		
		private var _exerciseId:uint;
		private var _exerciseName:String;
		
		private var _responseId:uint;
		private var _responseName:String;
		private var _responseCharacterName:String;
		private var _responseSubtitleId:uint;
		private var _responseAddingDate:String;
		private var _responseUserName:String;
		
		private var _userName:String;
		
		private var _videoCommentName:String;
		
		/**
		 *  Pagination control variables
		 */
		
		private var _currentPageWaitingForAssessment:uint=1;
		private var _currentPageAssessedByCurrentUser:uint=1;
		private var _currentPageAssessedToCurrentUser:uint=1;
		
		/**
		 *  Back-end data holders
		 */
		[Bindable]
		public var assessmentDetailList:ArrayCollection;
		[Bindable]
		public var waitingForAssessmentList:ArrayCollection;
		[Bindable]
		public var assessedToCurrentUserList:ArrayCollection;
		[Bindable]
		public var assessedByCurrentUserList:ArrayCollection;
		
		/**
		 *  Visual component declaration
		 */
	
		public var evaluationRatingBox:EvaluationRatingBox;
		public var paginationWaitingAssessment:HGroup;
		public var paginationAssessedByCurrentUser:HGroup;
		public var assessmentsOfSelectedResponse:HGroup;
		
		public var videoPlayerBox:VGroup;
		public var evaluationTypeNavigator:TabNavigator;
		
		public var waitingAssessmentBoxNavContent:NavigatorContent;
		public var assessedToCurrentUserBoxNavContent:NavigatorContent;
		public var assessedByCurrentUserBoxNavContent:NavigatorContent;
		
		public var computerEvaluation:AutoevaluationPanel;
		public var assessedToCurrentUserListAndPagination:AssessedToCurrentUserList;
		
		[Bindable]
		public var VP:VideoPlayerBabelia = new VideoPlayerBabelia();
		
		[Bindable] public var waitingAssessmentDataGrid:DataGrid = new DataGrid();
		[Bindable] public var assessmentDetailDataGrid:DataGrid = new DataGrid();
		[Bindable] public var assessedByCurrentUserDataGrid:DataGrid = new DataGrid();
		
		[Bindable] public var evaluationOptionsViewStack:ViewStack;
		
		//Empty while we have mixed visuals and code
		
		
		
		public function EvaluationMainClass()
		{
			super();
			this.paddingBottom=8
			this.verticalAlign=VerticalAlign.TOP;
			this.percentWidth=100;
			this.addEventListener(FlexEvent.CREATION_COMPLETE, completeHandler);
		}
		
		/**
		 * Constructor
		 */
		public function completeHandler(event:FlexEvent):void
		{
			_timeFormatter.outputMilliseconds=false;
			
			//Set the data bindings for this class
			setBindings();
			
			refreshEvaluationLists();
			
			setupVideoPlayer();
		}
		
		private function setBindings():void{
		
			BindingUtils.bindSetter(showAutoevalTab, dataModel, "autoevaluationAvailable");
			BindingUtils.bindSetter(userAuthenticationHandler, dataModel, "isLoggedIn");
			BindingUtils.bindSetter(onTabChange, dataModel, "stopVideoFlag");
			
			BindingUtils.bindSetter(waitingAssessmentRetrievedHandler, dataModel, "waitingForAssessmentDataRetrieved");
			BindingUtils.bindSetter(assessedToCurrentUserRetrievedHandler, dataModel, "assessedToCurrentUserDataRetrieved");
			BindingUtils.bindSetter(assessedByCurrentUserRetrievedHandler, dataModel, "assessedByCurrentUserDataRetrieved");
			BindingUtils.bindSetter(detailsOfAssessmentRetrievedHandler, dataModel, "detailsOfAssessedResponseDataRetrieved");
			BindingUtils.bindSetter(assessmentSavedHandler, dataModel, "addAssessmentRetrieved");
		
			BindingUtils.bindSetter(onURLChange, browserManager, "targetFragment");
			
		}
		
		private function setupVideoPlayer():void
		{
			VP.addEventListener(VideoPlayerEvent.CONNECTED, onVideoPlayerReady);
			VP.addEventListener(VideoPlayerEvent.VIDEO_FINISHED_PLAYING, evaluationRatingBox.onResponseFinished);
			VP.addEventListener(VideoPlayerBabeliaEvent.SECONDSTREAM_FINISHED_PLAYING, evaluationRatingBox.onResponseFinished);
		}
		
		private function onVideoPlayerReady(e:VideoPlayerEvent):void
		{
			_videoPlayerReady=true;
			VP.stopVideo();
		}
		
		private function waitingAssessmentRetrievedHandler(value:Boolean):void
		{
			var waDataprovider:ArrayCollection=dataModel.waitingForAssessmentData;
			//waitingAssessmentDataGrid.rowCount=waDataprovider.length;
			waitingForAssessmentList=waDataprovider;
			createPagination(waitingAssessmentDataGrid, waitingForAssessmentList, _currentPageWaitingForAssessment, paginationWaitingAssessment, navigateToPageWaitingAssessment);
			allDataReceived();
		}
		
		private function assessedByCurrentUserRetrievedHandler(value:Boolean):void
		{
			var abcuDataprovider:ArrayCollection=dataModel.assessedByCurrentUserData;
			//assessedByCurrentUserDataGrid.rowCount=abcuDataprovider.length;
			assessedByCurrentUserList=abcuDataprovider;
			createPagination(assessedByCurrentUserDataGrid, assessedByCurrentUserList, _currentPageAssessedByCurrentUser, paginationAssessedByCurrentUser, navigateToPageAssessedByCurrentUser);
			allDataReceived();
		}
		
		private function assessedToCurrentUserRetrievedHandler(value:Boolean):void
		{
			var atcuDataprovider:ArrayCollection=dataModel.assessedToCurrentUserData;
			//assessedToCurrentUserDataGrid.rowCount=atcuDataprovider.length;
			assessedToCurrentUserList=atcuDataprovider;
			allDataReceived();
		}
		
		private function detailsOfAssessmentRetrievedHandler(value:Boolean):void
		{
			var doaDataprovider:ArrayCollection=dataModel.detailsOfAssessedResponseData;
			assessmentDetailDataGrid.rowCount=doaDataprovider.length;
			assessmentDetailList=doaDataprovider;
		}
		
		private function assessmentSavedHandler(value:Boolean):void
		{
			evaluationRatingBox.includeInLayout=false;
			evaluationRatingBox.visible=false;
			
			resetVideoPlayer();
			
			refreshEvaluationLists();
		}
		
		private function refreshEvaluationLists():void
		{
			if (dataModel.isLoggedIn)
			{
				_userName=dataModel.loggedUser.name;
				new EvaluationEvent(EvaluationEvent.GET_RESPONSES_WAITING_ASSESSMENT).dispatch();
				new EvaluationEvent(EvaluationEvent.GET_RESPONSES_ASSESSED_TO_CURRENT_USER).dispatch();
				new EvaluationEvent(EvaluationEvent.GET_RESPONSES_ASSESSED_BY_CURRENT_USER).dispatch();
			}
			else
			{
				_userName='';
				waitingForAssessmentList=new ArrayCollection();
				assessedToCurrentUserList=new ArrayCollection();
				assessedByCurrentUserList=new ArrayCollection();
				assessmentDetailList=new ArrayCollection();
				createPagination(waitingAssessmentDataGrid, waitingForAssessmentList, _currentPageWaitingForAssessment, paginationWaitingAssessment, navigateToPageWaitingAssessment);
				createPagination(assessedByCurrentUserDataGrid, assessedByCurrentUserList, _currentPageAssessedByCurrentUser, paginationAssessedByCurrentUser, navigateToPageAssessedByCurrentUser);
			}
			assessmentsOfSelectedResponse.visible=false;
			evaluationRatingBox.includeInLayout=false;
			evaluationRatingBox.visible=false;
		}
		
		private function prepareEvaluation():void
		{
			// Prepare new video in VideoPlayer
			resetVideoPlayer();
			
			prepareCueManager();
		}
		
		private function resetCueManager():void
		{
			_cueManager.reset();
			VP.removeEventListener(StreamEvent.ENTER_FRAME, _cueManager.monitorCuePoints);
			_cueManager.removeEventListener(CueManagerEvent.SUBTITLES_RETRIEVED, onSubtitlesRetrieved);
		}
		
		private function prepareCueManager():void
		{
			_cueManager.addEventListener(CueManagerEvent.SUBTITLES_RETRIEVED, onSubtitlesRetrieved);
			_cueManager.setCuesFromSubtitleUsingId(_responseSubtitleId);
			//set cues from subtitle id retrieved from the list
			
			VP.removeEventListener(StreamEvent.ENTER_FRAME, _cueManager.monitorCuePoints);
			VP.addEventListener(StreamEvent.ENTER_FRAME, _cueManager.monitorCuePoints);
		}
		
		private function onSubtitlesRetrieved(e:CueManagerEvent):void
		{
			setupSimultaneousPlaybackCommands();
			
			VP.state=VideoPlayerBabelia.PLAY_BOTH_STATE;
			VP.videoSource=EXERCISE_FOLDER + '/' + _exerciseName;
			VP.secondSource=RESPONSE_FOLDER + '/' + _responseName;
			VP.addEventListener(VideoPlayerEvent.METADATA_RETRIEVED, onMetadataRetrieved);
			VP.refresh();
		}
		
		private function setupSimultaneousPlaybackCommands():void
		{
			var auxList:ArrayCollection=_cueManager.getCuelist();
			
			if (auxList.length <= 0)
				return;
			
			for each (var cueobj:CueObject in auxList)
			{
				if (cueobj.getRole() != _responseCharacterName)
				{
					cueobj.setStartCommand(new RecordingOtherRoleCommand(cueobj.getText(), cueobj.getRole(), cueobj.getEndTime() - cueobj.getStartTime(), VP));
					
					cueobj.setEndCommand(new ShowHideSubtitleCommand(null, VP));
				}
				else
				{
					cueobj.setStartCommand(new StartRecordingSelectedRoleCommand(cueobj.getText(), _responseCharacterName, cueobj.getEndTime() - cueobj.getStartTime(), VP));
					
					cueobj.setEndCommand(new StopRecordingSelectedRoleCommand(VP));
				}
			}
			
			_cueManagerReady=true;
		}
		
		private function showArrows():void
		{
			VP.setArrows(_cueManager.cues2rolearray(), _responseCharacterName);
			VP.arrows=true;
		}
		
		private function hideArrows():void
		{
			VP.arrows=false;
			VP.removeArrows();
		}
		
		private function onMetadataRetrieved(e:Event):void
		{
			showArrows();
		}
		
		/*
		private function viewGraphicClickHandler():void
		{
		EvaluationChartPopUp.responseId=_responseId;
		var evaluationChartPopUp:EvaluationChartPopUp=EvaluationChartPopUp(PopUpManager.createPopUp(this, EvaluationChartPopUp, true));
		PopUpManager.centerPopUp(evaluationChartPopUp);
		}*/
		
		private function allDataReceived():void
		{
			if (waitingForAssessmentList != null && assessedByCurrentUserList != null && assessedByCurrentUserList != null)
			{
				onURLChange("Data");
			}
		}
		
		public function waitingAssessmentChangeHandler(event:Event):void
		{
			var selectedItem:EvaluationVO=(DataGrid(event.target).selectedItem) as EvaluationVO;
			
			_exerciseId=selectedItem.exerciseId;
			_exerciseName=selectedItem.exerciseName;
			_exerciseTitle=selectedItem.exerciseTitle;
			
			_responseId=selectedItem.responseId;
			_responseName=selectedItem.responseFileIdentifier;
			_responseSubtitleId=selectedItem.responseSubtitleId;
			_responseCharacterName=selectedItem.responseCharacterName;
			_responseAddingDate=selectedItem.responseAddingDate;
			_responseUserName=selectedItem.responseUserName;
			
			//Retrieve the associated subtitles and prepare the videoplayer
			prepareEvaluation();
			_evaluationSelected=true;
			
			//Visualize the video player component
			videoPlayerBox.includeInLayout=true;
			videoPlayerBox.visible=true;
			
			//Prepare the component in which the user leaves the assessment
			evaluationRatingBox.resetEvaluationButtonClickHandler(null);
			evaluationRatingBox.responseData(_responseId, _userName, _responseName, _responseAddingDate, _responseUserName, _exerciseTitle);
			evaluationRatingBox.includeInLayout=true;
			evaluationRatingBox.visible=true;
			
			
			var urlResponseName:String=_responseName.replace("audio/", "");
			
			BabeliaBrowserManager.getInstance().updateURL(BabeliaBrowserManager.index2fragment(ViewChangeEvent.VIEWSTACK_EVALUATION_MODULE_INDEX), BabeliaBrowserManager.EVALUATE, urlResponseName);
			
		}
		
		public function assessedToCurrentUserChangeHandler(event:Event):void
		{
			var selectedItem:EvaluationVO=(DataGrid(event.target).selectedItem) as EvaluationVO;
			_exerciseId=selectedItem.exerciseId;
			_exerciseName=selectedItem.exerciseName;
			_responseCharacterName=selectedItem.responseCharacterName;
			_responseId=selectedItem.responseId;
			_responseName=selectedItem.responseFileIdentifier;
			_responseSubtitleId=selectedItem.responseSubtitleId;
			
			_exerciseTitle=selectedItem.exerciseTitle;
			_evaluationSelected=true;
			
			
			
			//Retrieve the associated subtitles and prepare the videoplayer
			prepareEvaluation();
			
			//Visualize the video player component
			videoPlayerBox.includeInLayout=true;
			videoPlayerBox.visible=true;
			
			//overallAverageRating.text=resourceManager.getString('myResources', 'AVG') + ": " + selectedItem.overallScoreAverage;
			
			assessmentsOfSelectedResponse.visible=true;
			
			new EvaluationEvent(EvaluationEvent.DETAILS_OF_ASSESSED_RESPONSE, null, _responseId).dispatch();
			
			//Get the autoevaluation info if available
			computerEvaluation.setResponseID(_responseId);
			
			var urlResponseName:String=_responseName.replace("audio/", "");
			
			BabeliaBrowserManager.getInstance().updateURL(BabeliaBrowserManager.index2fragment(ViewChangeEvent.VIEWSTACK_EVALUATION_MODULE_INDEX), BabeliaBrowserManager.REVISE, urlResponseName);
		}
		
		public function assessedByCurrentUserChangeHandler(event:Event):void
		{
			var selectedItem:EvaluationVO=(DataGrid(event.target).selectedItem) as EvaluationVO;
			_exerciseId=selectedItem.exerciseId;
			_exerciseName=selectedItem.exerciseName;
			_responseCharacterName=selectedItem.responseCharacterName;
			_responseId=selectedItem.responseId;
			_responseName=selectedItem.responseFileIdentifier;
			_responseSubtitleId=selectedItem.responseSubtitleId;
			
			_exerciseTitle=selectedItem.exerciseTitle;
			_evaluationSelected=true;
			
			//Retrieve the associated subtitles and prepare the videoplayer
			prepareEvaluation();
			
			//Visualize the video player component
			videoPlayerBox.includeInLayout=true;
			videoPlayerBox.visible=true;
			
			var urlResponseName:String=_responseName.replace("audio/", "");
			
			BabeliaBrowserManager.getInstance().updateURL(BabeliaBrowserManager.index2fragment(ViewChangeEvent.VIEWSTACK_EVALUATION_MODULE_INDEX), BabeliaBrowserManager.VIEW, urlResponseName);
		}
		
		public function assessmentDetailChangeHandler(event:Event):void
		{
			var selectedItem:EvaluationVO=(DataGrid(event.target).selectedItem) as EvaluationVO;
			if (selectedItem.evaluationVideoFileIdentifier)
			{
				VP.pauseVideo();
				_videoCommentName=selectedItem.evaluationVideoFileIdentifier;
				
				
				//EvaluationVideoCommentWatch.videoSource=EVALUATION_FOLDER + '/' + _videoCommentName;
				var watchEvaluationVideoComment:EvaluationVideoCommentWatch=EvaluationVideoCommentWatch(PopUpManager.createPopUp(this, EvaluationVideoCommentWatch, true));
				watchEvaluationVideoComment.videoSource=EVALUATION_FOLDER + '/' + _videoCommentName;
				PopUpManager.centerPopUp(watchEvaluationVideoComment);
				assessmentDetailDataGrid.selectedItem=null;
			}
		}
		
		private function showAutoevalTab(val:Boolean):void
		{
			if (evaluationTypeNavigator != null)
			{
				//Show the autoevaluation tab if autoevaluation is available, else hide it
				evaluationTypeNavigator.getTabAt(1).visible=DataModel.getInstance().autoevaluationAvailable;
				evaluationTypeNavigator.getTabAt(1).enabled=DataModel.getInstance().autoevaluationAvailable;
				evaluationTypeNavigator.getTabAt(1).includeInLayout=DataModel.getInstance().autoevaluationAvailable;
				evaluationTypeNavigator.selectedIndex=0;
			}
			else
				DataModel.getInstance().autoevaluationAvailable=true;
		}
		
		public function durationLabelFunction(item:Object, column:DataGridColumn):String
		{
			if (item)
				return _timeFormatter.format(item.exerciseDuration);
			else
				return "";
		}
		
		private function resetVideoPlayer():void
		{
			VP.endVideo(); // Stop video
			VP.setSubtitle(""); // Clear subtitles if any
			VP.videoSource=""; // Reset video source
			
			hideArrows(); // Hide arrows
			
			VP.state=VideoPlayerBabelia.PLAY_STATE; //Reset the player window to display only the exercise
			
			resetCueManager();
			
			//Hide the video player until an exercise is selected
			videoPlayerBox.includeInLayout=false;
			videoPlayerBox.visible=false;
		}
		
		public function onEvaluationTabChange(event:IndexChangedEvent):void
		{
			var newIndex:uint=event.newIndex;
			switch (newIndex)
			{
				case evaluationOptionsViewStack.getChildIndex(waitingAssessmentBoxNavContent):
					assessedToCurrentUserListAndPagination.assessedToCurrentUserListTable.selectedItem=null;
					assessedByCurrentUserDataGrid.selectedItem=null;
					assessmentsOfSelectedResponse.visible=false;
					
					_currentPageWaitingForAssessment=1;
					_currentPageAssessedByCurrentUser=1;
					_currentPageAssessedToCurrentUser=1;
					assessedToCurrentUserListAndPagination.currentPaginationPage=_currentPageAssessedToCurrentUser;
					createPagination(waitingAssessmentDataGrid, waitingForAssessmentList, _currentPageWaitingForAssessment, paginationWaitingAssessment, navigateToPageWaitingAssessment);
					createPagination(assessedByCurrentUserDataGrid, assessedByCurrentUserList, _currentPageAssessedByCurrentUser, paginationAssessedByCurrentUser, navigateToPageAssessedByCurrentUser);
					
					resetVideoPlayer();
					
					break;
				case evaluationOptionsViewStack.getChildIndex(assessedToCurrentUserBoxNavContent):
					waitingAssessmentDataGrid.selectedItem=null;
					assessedByCurrentUserDataGrid.selectedItem=null;
					evaluationRatingBox.includeInLayout=false;
					evaluationRatingBox.visible=false;
					
					_currentPageWaitingForAssessment=1;
					_currentPageAssessedByCurrentUser=1;
					_currentPageAssessedToCurrentUser=1;
					assessedToCurrentUserListAndPagination.currentPaginationPage=_currentPageAssessedToCurrentUser;
					createPagination(waitingAssessmentDataGrid, waitingForAssessmentList, _currentPageWaitingForAssessment, paginationWaitingAssessment, navigateToPageWaitingAssessment);
					createPagination(assessedByCurrentUserDataGrid, assessedByCurrentUserList, _currentPageAssessedByCurrentUser, paginationAssessedByCurrentUser, navigateToPageAssessedByCurrentUser);
					
					resetVideoPlayer();
					
					break;
				case evaluationOptionsViewStack.getChildIndex(assessedByCurrentUserBoxNavContent):
					waitingAssessmentDataGrid.selectedItem=null;
					assessedToCurrentUserListAndPagination.assessedToCurrentUserListTable.selectedItem=null;
					assessmentsOfSelectedResponse.visible=false;
					evaluationRatingBox.includeInLayout=false;
					evaluationRatingBox.visible=false;
					
					_currentPageWaitingForAssessment=1;
					_currentPageAssessedByCurrentUser=1;
					_currentPageAssessedToCurrentUser=1;
					assessedToCurrentUserListAndPagination.currentPaginationPage=_currentPageAssessedToCurrentUser;
					createPagination(waitingAssessmentDataGrid, waitingForAssessmentList, _currentPageWaitingForAssessment, paginationWaitingAssessment, navigateToPageWaitingAssessment);
					createPagination(assessedByCurrentUserDataGrid, assessedByCurrentUserList, _currentPageAssessedByCurrentUser, paginationAssessedByCurrentUser, navigateToPageAssessedByCurrentUser);
					
					resetVideoPlayer();
					
					break;
				default:
					break;
			}
		}
		
		private function userAuthenticationHandler(value:Boolean):void
		{
			refreshEvaluationLists();
			
			resetVideoPlayer();
			
			evaluationOptionsViewStack.selectedChild=waitingAssessmentBoxNavContent;
		}
		
		private function onTabChange(value:Boolean):void
		{
			evaluationRatingBox.includeInLayout=false;
			evaluationRatingBox.visible=false;
			assessmentsOfSelectedResponse.visible=false;
			
			// Remove selected items
			waitingAssessmentDataGrid.selectedIndex=-1;
			assessedByCurrentUserDataGrid.selectedIndex=-1;
			assessedToCurrentUserListAndPagination.assessedToCurrentUserListTable.selectedItem=-1;
			
			//Return the pagination controls to the first page
			_currentPageWaitingForAssessment=1;
			_currentPageAssessedByCurrentUser=1;
			_currentPageAssessedToCurrentUser=1;
			
			assessedToCurrentUserListAndPagination.currentPaginationPage=_currentPageAssessedToCurrentUser;
			createPagination(waitingAssessmentDataGrid, waitingForAssessmentList, _currentPageWaitingForAssessment, paginationWaitingAssessment, navigateToPageWaitingAssessment);
			createPagination(assessedByCurrentUserDataGrid, assessedByCurrentUserList, _currentPageAssessedByCurrentUser, paginationAssessedByCurrentUser, navigateToPageAssessedByCurrentUser);
			
			resetVideoPlayer();
			
			evaluationOptionsViewStack.selectedChild=waitingAssessmentBoxNavContent;
		}
		
		public function createPagination(targetDatagrid:DataGrid, dataProvider:ArrayCollection, currentPageIndicator:uint, paginationContainer:HGroup, pageClickHandler:Function):void
		{
			VideoPaginator.createPaginationMenu(dataProvider.length, DataModel.getInstance().pageSize, currentPageIndicator, DataModel.getInstance().numberOfPagesNav, paginationContainer, pageClickHandler);
			refreshDataProvider(targetDatagrid, dataProvider, currentPageIndicator);
		}
		
		public function refreshDataProvider(targetDatagrid:DataGrid, dataProvider:ArrayCollection, currentPageIndicator:uint):void
		{
			var current:int=currentPageIndicator - 1;
			var pageSize:int=DataModel.getInstance().pageSize;
			var dataTemp:ArrayCollection=new ArrayCollection(dataProvider.source.slice((current * pageSize), (current * pageSize) + pageSize));
			targetDatagrid.rowCount=dataTemp.length;
			targetDatagrid.dataProvider=dataTemp;
		}
		
		private function navigateToPageWaitingAssessment(event:MouseEvent):void
		{
			_currentPageWaitingForAssessment=int((event.target as Button).id);
			createPagination(waitingAssessmentDataGrid, waitingForAssessmentList, _currentPageWaitingForAssessment, paginationWaitingAssessment, navigateToPageWaitingAssessment);
		}
		
		private function navigateToPageAssessedByCurrentUser(event:MouseEvent):void
		{
			_currentPageAssessedByCurrentUser=int((event.target as Button).id);
			createPagination(assessedByCurrentUserDataGrid, assessedByCurrentUserList, _currentPageAssessedByCurrentUser, paginationAssessedByCurrentUser, navigateToPageAssessedByCurrentUser);
		}
		
		private function onURLChange(value:Object):void
		{
			var browser:BabeliaBrowserManager=BabeliaBrowserManager.getInstance();
			
			if (browser.moduleClass != ViewChangeEvent.VIEWSTACK_EVALUATION_MODULE_INDEX)
				return;
			
			if (value == null)
				return;
			
			//	if (!dataModel.isLoggedIn)
			//	{
			//new ViewChangeEvent(ViewChangeEvent.VIEW_EVALUATION_MODULE).dispatch();
			//		return;
			//	}
			
			
			if (waitingForAssessmentList == null || assessedByCurrentUserList == null || assessedToCurrentUserList == null)
			{
				//new ViewChangeEvent(ViewChangeEvent.VIEW_EVALUATION_MODULE).dispatch();
				return;
			}
			
			switch (browser.actionFragment)
			{
				case BabeliaBrowserManager.EVALUATE:
					if (browser.targetFragment != '')
					{
						var tmpEvaluate:EvaluationVO;
						for each (var evEvaluate:EvaluationVO in waitingForAssessmentList)
						{
							var evaluateStripped:String=evEvaluate.responseFileIdentifier.replace("audio/", "");
							
							if (evaluateStripped == browser.targetFragment)
							{
								tmpEvaluate=evEvaluate;
								break;
							}
						}
						if (tmpEvaluate)
							callLater(goToSelectedEvaluate, [tmpEvaluate]);
					}
					break;
				
				case BabeliaBrowserManager.REVISE:
					if (browser.targetFragment != '')
					{
						evaluationOptionsViewStack.selectedChild=assessedToCurrentUserBoxNavContent;
						var tmpRevise:EvaluationVO;
						for each (var evRevise:EvaluationVO in assessedToCurrentUserList)
						{
							var reviseStripped:String=evRevise.responseFileIdentifier.replace("audio/", "");
							
							if (reviseStripped == browser.targetFragment)
							{
								tmpRevise=evRevise;
								break;
							}
						}
						if (tmpRevise)
							callLater(goToSelectedRevise, [tmpRevise]);
					}
					break;
				
				case BabeliaBrowserManager.VIEW:
					
					if (browser.targetFragment != '')
					{
						var tmpView:EvaluationVO;
						for each (var evView:EvaluationVO in assessedByCurrentUserList)
						{
							var viewStripped:String=evView.responseFileIdentifier.replace("audio/", "");
							if (viewStripped == browser.targetFragment)
							{
								tmpView=evView;
								break;
							}
						}
						if (tmpView != null)
							callLater(goToSelectedView, [tmpView]);
					}
					break;
				default:
					new ViewChangeEvent(ViewChangeEvent.VIEW_EVALUATION_MODULE).dispatch();
					break;
			}
		}
		
		private function goToSelectedEvaluate(tmpEvaluate:EvaluationVO):void
		{
			//Go to the speficied tab and dispatch a change event
			evaluationOptionsViewStack.selectedChild=waitingAssessmentBoxNavContent;
			waitingAssessmentDataGrid.selectedItem=tmpEvaluate;
			waitingAssessmentDataGrid.dispatchEvent(new ListEvent(ListEvent.CHANGE));
		}
		
		private function goToSelectedView(tmpView:EvaluationVO):void
		{
			//Go to the speficied tab and dispatch a change event
			evaluationOptionsViewStack.selectedChild=assessedByCurrentUserBoxNavContent;
			assessedByCurrentUserDataGrid.selectedItem=tmpView;
			assessedByCurrentUserDataGrid.dispatchEvent(new ListEvent(ListEvent.CHANGE));
		}
		
		private function goToSelectedRevise(tmpRevise:EvaluationVO):void
		{
			//Go to the speficied tab and dispatch a change event
			evaluationOptionsViewStack.selectedChild=assessedToCurrentUserBoxNavContent;
			assessedToCurrentUserListAndPagination.assessedToCurrentUserListTable.selectedItem=tmpRevise;
			assessedToCurrentUserListAndPagination.assessedToCurrentUserListTable.dispatchEvent(new ListEvent(ListEvent.CHANGE));
			
		}
		
		
	}
}