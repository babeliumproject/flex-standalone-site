package model
{
	import business.NetConnectionDelegate;
	
	import com.adobe.cairngorm.model.IModelLocator;
	
	import components.autoevaluation.Evaluation;
	import components.main.Body;
	import components.main.LoginPopup;
	import components.main.LoginRestorePassForm;
	import components.userManagement.KeepAliveTimer;
	
	import flash.media.Camera;
	import flash.media.Microphone;
	import flash.net.FileReference;
	import flash.net.NetConnection;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.utils.ObjectProxy;
	
	import vo.CreditHistoryVO;
	import vo.ExerciseVO;
	import vo.UserVO;
	import vo.VideoSliceVO;

	dynamic public class DataModel implements IModelLocator
	{
		//This solution for singleton implementation was found in
		//http://life.neophi.com/danielr/2006/10/singleton_pattern_in_as3.html		
		public static var instance:DataModel=new DataModel();
		
		public static const SOURCE_LOCALE:String='en_US';

		public var appBody:Body;

		public var localesAndFlags:LocalesAndFlags;

		public static const SUBMODULE:int=0;
		public static const RECORDING_MODULE:int=1;
		public static const GAPS_TO_ABORT_RECORDING:int=3;

		public static const PURPOSE_EVALUATE:String='evaluate';
		public static const PURPOSE_PRACTICE:String='practice';
		
		
		[Bindable]
		public var levels:ArrayCollection = new ArrayCollection([{'level':1,'label':'A1'}, {'level':2,'label':'A2'}, {'level':3,'label':'B1'}, {'level':4,'label':'B2'}, {'level':5,'label':'C1'}]);	
		
		
		//NetConnection management variables
		[Bindable]
		public var netConnectionDelegate:NetConnectionDelegate;
		[Bindable]
		public var netConnection:NetConnection;
		[Bindable]
		public var netConnected:Boolean;
		[Bindable]
		public var netConnectOngoingAttempt:Boolean;
		
		public var bandwidthInfo:Object;

		//Application preferences value pair
		[Bindable]
		public var prefDic:Dictionary;
		[Bindable]
		public var preferencesRetrieved:Boolean=false;

		//Top ten collaborators data and service state
		[Bindable]
		public var topTenUsers:ArrayCollection;
		[Bindable]
		public var isTopTenRetrieved:Boolean=false;

		//User related values
		[Bindable]
		public var loggedUser:UserVO=null;
		[Bindable]
		public var isSuccessfullyLogged:Boolean=false;
		[Bindable]
		public var isLoggedIn:Boolean=false;
		[Bindable]
		public var loginErrorMessage:String="";
		[Bindable]
		public var creditUpdateRetrieved:Boolean=false;
		[Bindable]
		public var keepAliveInterval:int=180000; //3 minutes
		[Bindable]
		public var eventSchedulerInstance:KeepAliveTimer=new KeepAliveTimer();
		[Bindable]
		public var activationEmailResent:Boolean=false;
		[Bindable]
		public var activationEmailResentErrorMessage:String='';
		[Bindable]
		public var loginPop:LoginPopup;
		[Bindable]
		public var passwordChanged:Boolean=false;
		[Bindable]
		public var userPreferredLanguagesModified:Boolean=false;
		[Bindable]
		public var userPersonalDataModified:Boolean=false;
		[Bindable]
		public var userVideoListRetrieved:Boolean=false;
		[Bindable]
		public var userVideoList:ArrayCollection=new ArrayCollection();
		[Bindable]
		public var selectedVideosDeleted:Boolean=false;
		[Bindable]
		public var exerciseDataModified:Boolean=false;

		//Pass recovery
		[Bindable]
		public var passRecoveryDone:Boolean;

		//Register related messages
		[Bindable]
		public var registrationErrorMessage:String="";
		[Bindable]
		public var registrationResponse:Boolean=false;
		[Bindable]
		public var restorePassErrorMessage:String="";
		[Bindable]
		public var accountActivationRetrieved:Boolean=false;
		[Bindable]
		public var accountActivationStatus:int;

		//Credit History data and service state
		[Bindable]
		public var creditHistory:ArrayCollection=new ArrayCollection();
		[Bindable]
		public var creditChartData:ArrayCollection;
		[Bindable]
		public var isCreditHistoryRetrieved:Boolean=false;
		[Bindable]
		public var isChartDataRetrieved:Boolean=false;

		[Bindable]
		public var historicData:CreditHistoryVO=null;
		[Bindable]
		public var subHistoricData:CreditHistoryVO=null;

		[Bindable]
		public var currentPage:int=1;
		[Bindable]
		public var pageSize:int=8; //Number of results displayed per page
		[Bindable]
		public var numberOfPagesNav:int=7; //This number must be odd and greater than three

		//The info of the current video
		
		[Bindable]
		public var watchExerciseDataRetrieved:Boolean;
		public var watchExerciseData:Object;
		[Bindable]
		public var watchExerciseSubtitlesRetrieved:Boolean;
		public var watchExerciseSubtitles:Object;
		
		[Bindable]
		public var recordMediaDataRetrieved:Boolean;
		public var recordMediaData:Object;
		
		[Bindable]
		public var availableExercises:ArrayCollection;
		[Bindable]
		public var availableRecordableExercises:ArrayCollection;
		
		[Bindable]
		public var availableRecordableExercisesRetrieved:Boolean;
		
		[Bindable]
		public var availableExercisesRetrieved:ArrayCollection=new ArrayCollection(new Array(false, false));

		[Bindable]
		public var availableExerciseLocales:Array;
		[Bindable]
		public var availableExerciseLocalesRetrieved:Boolean=false;

		[Bindable]
		public var evaluationPendingResponses:ArrayCollection;
		[Bindable]
		public var evaluationPendingRetrieved:Boolean=false;

		[Bindable]
		public var savedResponseRetrieved:Boolean=false;
		[Bindable]
		public var savedResponseId:int;

		//Exercise uploading related data
		[Bindable]
		public var server:String='babeliumlms';
		

		public var defaultNetConnectionUrl:String;

		[Bindable]
		public var uploadDomain:String="http://" + server + "/";
		[Bindable]
		public var uploadURL:String=uploadDomain + "upload.php";

		[Bindable]
		public var newExerciseData:ExerciseVO=null;
		[Bindable]
		public var newYoutubeData:ExerciseVO=null;
		[Bindable]
		public var youtubeTransferComplete:Boolean=false;
		[Bindable]
		public var youtubeProcessingComplete:Boolean=false;
		[Bindable]
		public var youtubeProcessUpdate:Boolean=false;
		[Bindable]
		public var youtubeProcessMessage:String;

		[Bindable]
		public var youtubeThumbnailsUrl:String="http://img.youtube.com/vi/";

		[Bindable]
		public var unprocessedExerciseSaved:Boolean=false;

		[Bindable]
		public var activeUserList:ArrayCollection;

		//Video Slice related data	
		[Bindable]
		public var urlSearch:String="";
		[Bindable]
		public var userSearch:String="";
		[Bindable]
		public var retrieveVideoComplete:Boolean=false;
		[Bindable]
		public var retrieveUserVideoComplete:Boolean=false;
		[Bindable]
		public var slicePreview:Boolean=false;
		[Bindable]
		public var sliceComplete:Boolean=false;
		[Bindable]
		public var tempVideoSlice:VideoSliceVO=new VideoSliceVO;
		[Bindable]
		public var tempExercise:ExerciseVO=new ExerciseVO;

		//Subtitle related data
		[Bindable]
		public var subtileSaveId:int;
		[Bindable]
		public var subtitleSaved:Boolean=false;

		[Bindable]
		public var videoPlayerControlsViewStack:int;

		[Bindable]
		public var exercisesWithoutSubtitles:ArrayCollection=new ArrayCollection();
		[Bindable]
		public var exercisesWithoutSubtitlesRetrieved:Boolean=false;
		[Bindable]
		public var exercisesWithSubtitlesToReview:ArrayCollection=new ArrayCollection();
		[Bindable]
		public var exercisesWithSubtitlesToReviewRetrieved:Boolean=false;

		//Used to store exercise's roles added by the user  
		[Bindable]
		public var availableExerciseRoles:Object;
		[Bindable]
		public var availableExerciseRolesRetrieved:Boolean;

		//Used to store subtitle-lines and roles in the same DP
		[Bindable]
		public var availableSubtitlesRetrieved:Boolean=false;
		public var availableSubtitles:ArrayCollection;
		public var subtitleMedia:Object;
		
		[Bindable]
		public var availableSubtitleLinesRetrieved:Boolean=false;
		public var availableSubtitleLines:ArrayCollection;
		public var unmodifiedAvailableSubtitleLines:ArrayCollection;

		//Evaluation module data
		[Bindable]
		public var evaluationChartData:ArrayCollection;
		[Bindable]
		public var evaluationChartDataRetrieved:Boolean=false;
		
		[Bindable]
		public var submissionDataRetrieved:Boolean;
		public var submissionData:Object;

		
		[Bindable]
		public var waitingForAssessmentDataRetrieved:Boolean=false;
		public var waitingForAssessmentCount:uint;
		public var waitingForAssessmentData:ArrayCollection;

		[Bindable]
		public var assessedToCurrentUserDataRetrieved:Boolean=false;
		public var assessedToCurrentUserCount:uint;
		public var assessedToCurrentUserData:ArrayCollection;
		
		[Bindable]
		public var assessedByCurrentUserDataRetrieved:Boolean=false;
		public var assessedByCurrentUserCount:uint;
		public var assessedByCurrentUserData:ArrayCollection;

		[Bindable]
		public var userActivityDataRetrieved:Boolean;
		public var userActivityData:Object;
		
		[Bindable]
		public var responseAssessmentDataRetrieved:Boolean=false;
		public var responseAssessmentData:Object;
	
		[Bindable]
		public var addAssessmentRetrieved:Boolean=false;
		public var addAssessmentData:Object;

		//Homepage module data
		[Bindable]
		public var messagesOfTheDayRetrieved:Boolean;
		public var messagesOfTheDayData:ArrayCollection;

		[Bindable]
		public var userLatestReceivedAssessmentsRetrieved:Boolean;
		public var userLatestReceivedAssessments:ArrayCollection;
		
		[Bindable]
		public var userLatestDoneAssessmentsRetrieved:Boolean;
		public var userLatestDoneAssessments:ArrayCollection;
		
		[Bindable]
		public var userLatestUploadedVideosRetrieved:Boolean;
		public var userLatestUploadedVideos:ArrayCollection;
		
		[Bindable]
		public var signedInBestRatedVideosRetrieved:Boolean;
		public var signedInBestRatedVideos:ArrayCollection;
		
		[Bindable]
		public var signedInLatestUploadedVideosRetrieved:Boolean;
		public var signedInLatestUploadedVideos:ArrayCollection;
		
		[Bindable]
		public var unsignedBestRatedVideosRetrieved:Boolean;
		public var unsignedBestRatedVideos:ArrayCollection;	

		//Autoevaluation data
		[Bindable]
		public var autoevaluationResults:Evaluation=null;
		[Bindable]
		public var autoevaluationDone:Boolean=false;
		[Bindable]
		public var autoevaluationAvailable:Boolean=false;
		[Bindable]
		public var autoevaluationError:String="";

		[Bindable]
		public var isAutoevaluable:Boolean=false;

		[Bindable]
		public var enableAutoevalToExerciseError:String="";


		//Used by configuration module
		[Bindable]
		public var videoRec:Boolean=false;
		[Bindable]
		public var audioRec:Boolean=false;
		[Bindable]
		public var recording:Boolean=false;
		[Bindable]
		public var playing:Boolean=false;
		[Bindable]
		public var permissions:Boolean=true;

		// Variables to manage the input devices
		[Bindable]
		public var microphone:Microphone;
		[Bindable]
		public var camera:Camera;
		[Bindable]
		public var micCamAllowed:Boolean=false;
		[Bindable]
		public var gapsWithNoSound:int=0;
		[Bindable]
		public var soundDetected:Boolean=false;
		[Bindable]
		public var cameraWidth:int=320;
		[Bindable]
		public var cameraHeight:int=240;

		[Bindable]
		public var minExerciseDuration:uint=15; //seconds
		[Bindable]
		public var maxExerciseDuration:uint=120; //seconds
		[Bindable]
		public var minVideoEvalDuration:uint=5; //seconds
		[Bindable]
		public var maxFileSize:uint=188743680; //Bytes (180MB)

		// Checks for exercise rating and reporting
		[Bindable]
		public var userRatedExercise:Boolean=false;
		[Bindable]
		public var userRatedExerciseFlag:Boolean=false;
		[Bindable]
		public var userReportedExercise:Boolean=false;
		[Bindable]
		public var userReportedExerciseFlag:Boolean=false;
		
		//Create module properties
		[Bindable]
		public var enabledCreateStepsChanged:Boolean;
		public var enabledCreateSteps:Array;
		
		[Bindable]
		public var exerciseDataRetrieved:Boolean;
		public var exerciseData:ExerciseVO;
		
		[Bindable]
		public var exerciseMediaRetrieved:Boolean;
		public var exerciseMedia:ArrayCollection;
		
		[Bindable]
		public var exercisePreviewRetrieved:Boolean;
		public var exercisePreview:Object;
		
		[Bindable]
		public var latestCreationsRetrieved:Boolean;
		public var latestCreations:ArrayCollection;
		
		[Bindable]
		public var defaultThumbnailModified:Boolean;
		
		//Course module properties
		[Bindable]
		public var courseListRetrieved:Boolean;
		public var courseList:ArrayCollection;

		public function DataModel()
		{
			if (instance)
				throw new Error("DataModel can only be accessed through DataModel.getInstance()");

			//Initialize application's visuals
			initialize();

		}

		public static function getInstance():DataModel
		{
			return instance;
		}

		private function initialize():void
		{
			localesAndFlags=new LocalesAndFlags();
		}

		static public function juggleTypes(target:*):*
		{
			var change:*=target;
			for (var i:* in change)
			{
				if (change[i] is Object)
				{
					change[i]=DataModel.juggleTypes(change[i]);
				}
				change[i]=isNaN(Number(change[i])) ? change[i] : Number(change[i]);
			}
			return change;
		}

	}
}