package model
{
	import business.NetConnectionDelegate;
	
	import com.adobe.cairngorm.model.IModelLocator;
	
	import components.autoevaluation.Evaluation;
	import components.main.Body;
	import components.main.LoginPopup;
	import components.userManagement.KeepAliveTimer;
	
	import flash.media.Camera;
	import flash.media.Microphone;
	import flash.net.FileReference;
	import flash.net.NetConnection;
	import flash.utils.Dictionary;
	
	import modules.account.view.LoginRestorePassForm;
	
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
		
		/**
		 * RTMP: The "plain" variant of the protocol that uses TCP port 1935 by default
		 */
		public static const RTMP:String = "rtmp";
		
		/**
		 * RTMPT (Tunnelized RTMP): Encapsulates the protocol's messages into HTTP requests to traverse firewalls. 
		 * Often used to send messages in the clear over TCP to ports 80 and 443. The encapsulated session can contain RTMP, RTMPS or RTMPE packets within.
		 */
		public static const RTMPT:String = "rtmpt";
		
		/**
		 * RTMPS (Secure RTMP): Is RTMP over a secure SSL connection using HTTPS
		 */
		public static const RTMPS:String = "rtmps";
		
		/**
		 * RTMPE (Encrypted RTMP): Is RTMP encrypted using Adobe's own security mechanism. 
		 * While the details of the implementation are proprietary, the mechanism uses industry standard cryptography primitive.
		 */
		public static const RTMPE:String = "rtmpe";
		
		public static const RTMP_PORT:uint=1935;
		public static const RTMPT_PORT:uint=80;

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
		public var currentExercise:ArrayCollection=new ArrayCollection(new Array(null, null));
		[Bindable]
		public var currentExerciseRetrieved:ArrayCollection=new ArrayCollection(new Array(false, false));

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
		
		public var streamingProtocol:String=RTMP;
		public var streamingPort:uint=1935;
		public var streamingApp:String='babeliumlms';
		[Bindable] public var streamingResourcesPath:String=streamingProtocol+"://" + server + ":"+ streamingPort + "/" + streamingApp;
	
		[Bindable] public var evaluationStreamsFolder:String="evaluations";
		[Bindable] public var responseStreamsFolder:String="responses";
		[Bindable] public var exerciseStreamsFolder:String="exercises";
		[Bindable] public var configStreamsFolder:String="config";

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
		public var availableExerciseRoles:ArrayCollection;
		[Bindable]
		public var availableExerciseRolesRetrieved:Boolean;

		//Used to store subtitle-lines and roles in the same DP
		[Bindable]
		public var availableSubtitles:ArrayCollection=new ArrayCollection();
		[Bindable]
		public var availableSubtitlesRetrieved:Boolean=false;
		[Bindable]
		public var availableSubtitleLinesRetrieved:Boolean=false;
		[Bindable]
		public var availableSubtitleLines:ArrayCollection;
		[Bindable]
		public var unmodifiedAvailableSubtitleLines:ArrayCollection=new ArrayCollection();

		//Evaluation module data
		[Bindable]
		public var evaluationChartData:ArrayCollection;
		[Bindable]
		public var evaluationChartDataRetrieved:Boolean=false;
		
		[Bindable]
		public var submissionDataRetrieved:Boolean;
		public var submissionData:Object;

		[Bindable]
		public var waitingForAssessmentCount:uint;
		[Bindable]
		public var waitingForAssessmentData:ArrayCollection;
		[Bindable]
		public var waitingForAssessmentDataRetrieved:Boolean=false;

		[Bindable]
		public var assessedToCurrentUserCount:uint;
		[Bindable]
		public var assessedToCurrentUserData:ArrayCollection;
		[Bindable]
		public var assessedToCurrentUserDataRetrieved:Boolean=false;

		[Bindable]
		public var assessedByCurrentUserCount:uint;
		[Bindable]
		public var assessedByCurrentUserData:ArrayCollection;
		[Bindable]
		public var assessedByCurrentUserDataRetrieved:Boolean=false;

		[Bindable]
		public var userActivityDataRetrieved:Boolean;
		public var userActivityData:Object;
		
		[Bindable]
		public var responseAssessmentDataRetrieved:Boolean=false;
		public var responseAssessmentData:ArrayCollection;
	
		[Bindable]
		public var addAssessmentRetrieved:Boolean=false;


		//Homepage module data
		[Bindable]
		public var messagesOfTheDayRetrieved:Boolean;
		[Bindable]
		public var messagesOfTheDayData:ArrayCollection=new ArrayCollection();

		[Bindable]
		public var userLatestReceivedAssessmentsRetrieved:Boolean;
		[Bindable]
		public var userLatestReceivedAssessments:ArrayCollection=new ArrayCollection();
		[Bindable]
		public var userLatestDoneAssessmentsRetrieved:Boolean;
		[Bindable]
		public var userLatestDoneAssessments:ArrayCollection=new ArrayCollection();
		[Bindable]
		public var userLatestUploadedVideos:ArrayCollection=new ArrayCollection();
		[Bindable]
		public var userLatestUploadedVideosRetrieved:Boolean;
		[Bindable]
		public var signedInBestRatedVideos:ArrayCollection=new ArrayCollection();
		[Bindable]
		public var signedInBestRatedVideosRetrieved:Boolean;
		[Bindable]
		public var signedInLatestUploadedVideos:ArrayCollection=new ArrayCollection();
		[Bindable]
		public var signedInLatestUploadedVideosRetrieved:Boolean;
		[Bindable]
		public var unsignedBestRatedVideos:ArrayCollection=new ArrayCollection();
		[Bindable]
		public var unsignedBestRatedVideosRetrieved:Boolean;

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


		// Flag for stoping video after tab change
		[Bindable]
		public var stopVideoFlag:Boolean=false;
		// In order to avoid tab change if recording exercise
		[Bindable]
		public var recordingExercise:Boolean=false;


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
		
		[Bindable]
		public var exerciseData:ExerciseVO;
		[Bindable]
		public var exerciseDataRetrieved:Boolean;
		
		[Bindable]
		public var exerciseMedia:ArrayCollection;
		[Bindable]
		public var exerciseMediaRetrieved:Boolean;
		
		[Bindable]
		public var exercisePreview:ArrayCollection;
		[Bindable]
		public var exercisePreviewRetrieved:Boolean;
		
		[Bindable]
		public var latestCreations:ArrayCollection;
		[Bindable]
		public var latestCreationsRetrieved:Boolean;
		[Bindable]
		public var defaultThumbnailModified:Boolean;
		
		public var moduleMap:Object = {};
		[Bindable]
		public var moduleMapProxy:ObjectProxy = new ObjectProxy(moduleMap);

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