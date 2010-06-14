package model
{
	import com.adobe.cairngorm.model.IModelLocator;
	
	import flash.media.Camera;
	import flash.media.Microphone;
	import flash.net.FileReference;
	import flash.utils.Dictionary;
	
	import modules.autoevaluation.Evaluation;
	import modules.userManagement.KeepAliveTimer;
	
	import mx.collections.ArrayCollection;
	
	import vo.CreditHistoryVO;
	import vo.ExerciseVO;
	import vo.UserVO;
	
	public class DataModel implements IModelLocator
	{
		//This solution for singleton implementation was found in
		//http://life.neophi.com/danielr/2006/10/singleton_pattern_in_as3.html		
		public static var instance:DataModel = new DataModel();
		
		public var localesAndFlags:LocalesAndFlags;
		
		[Bindable] public static var SUBTITLE_MODULE:int = 0;
		[Bindable] public static var RECORDING_MODULE:int = 1;
		[Bindable] public static var GAPS_TO_ABORT_RECORDING:int = 3;
		
		//ViewStack management variables
		[Bindable] public var currentContentViewStackIndex:int;
		
		[Bindable] public var currentExerciseViewStackIndex:int;
		[Bindable] public var currentUploadViewStackIndex:int;
		[Bindable] public var currentEvaluationViewStackIndex:int;
		
		[Bindable] public var oldContentViewStackIndex:int;
		[Bindable] public var newContentViewStackIndex:int;
		
		//Application preferences value pair
		[Bindable] public var prefDic:Dictionary;
		
		//Top ten collaborators data and service state
		[Bindable] public var topTenUsers:ArrayCollection;
		[Bindable] public var isTopTenRetrieved:Boolean = false;
		
		//Login data and service state
		[Bindable] public var loggedUser:UserVO = null;
		[Bindable] public var isSuccessfullyLogged:Boolean = false;
		[Bindable] public var isLoggedIn:Boolean = false;
		[Bindable] public var loginErrorMessage:String = "";
		[Bindable] public var creditUpdateRetrieved:Boolean = false;
		[Bindable] public var keepAliveInterval:int = 180000; //3 minutes
		[Bindable] public var eventSchedulerInstance:KeepAliveTimer = new KeepAliveTimer();
		
		//Pass recovery
		[Bindable] public var passRecoveryDone:Boolean;
		
		//Register related messages
		[Bindable] public var registrationErrorMessage:String = "";
		[Bindable] public var restorePassErrorMessage:String = "";
		[Bindable] public var accountActivationRetrieved:Boolean = false;
		[Bindable] public var accountActivationStatus:int;
		
		//Credit History data and service state
		[Bindable] public var creditHistory:ArrayCollection = new ArrayCollection();
		[Bindable] public var creditChartData:ArrayCollection;
		[Bindable] public var isCreditHistoryRetrieved:Boolean = false;
		[Bindable] public var isChartDataRetrieved:Boolean = false;
		
		[Bindable] public var historicData:CreditHistoryVO = null;
		[Bindable] public var subHistoricData:CreditHistoryVO = null;	
		
		//The info of the video searches
		[Bindable] public var tagCloud: ArrayCollection;
		[Bindable] public var tagCloudRetrieved: Boolean = false;
		[Bindable] public var tagCloudClicked: Boolean = false;
		[Bindable] public var languageChanged: Boolean = false;
		[Bindable] public var videoSearches: ArrayCollection;
		[Bindable] public var videoSearchesRetrieved:Boolean = false;
		[Bindable] public var searchField:String = "";
		[Bindable] public var currentPage:int = 1;
		[Bindable] public var pageSize:int = 7;          		 //Number of results displayed per page
		[Bindable] public var numberOfPagesNav:int = 7;			 //This number must be odd and greater than three
		
		//The info of the current video
		[Bindable] public var currentExercise:ArrayCollection = new ArrayCollection(new Array(null, null));
		[Bindable] public var currentExerciseRetrieved:ArrayCollection = new ArrayCollection(new Array(false, false));
		
		[Bindable] public var availableExercises:ArrayCollection;
		[Bindable] public var availableRecordableExercises:ArrayCollection;
		[Bindable] public var availableExercisesRetrieved:ArrayCollection = new ArrayCollection(new Array(false, false));
		
		[Bindable] public var availableExerciseLocales:Array;
		[Bindable] public var availableExerciseLocalesRetrieved:Boolean = false;
		
		[Bindable] public var evaluationPendingResponses:ArrayCollection;
		[Bindable] public var evaluationPendingRetrieved:Boolean = false;
		
		[Bindable] public var savedResponseRetrieved:Boolean = false;
		[Bindable] public var savedResponseId:int;
		
		//Exercise uploading related data
		[Bindable] public var server: String = "babelia";
		[Bindable] public var red5Port: String = "1935";
		[Bindable] public var uploadDomain:String = "http://"+server+"/";
		[Bindable] public var streamingResourcesPath:String = "rtmp://" + server + "/oflaDemo";
		[Bindable] public var evaluationStreamsFolder:String="evaluations";
		[Bindable] public var responseStreamsFolder:String="responses";
		[Bindable] public var exerciseStreamsFolder:String="exercises";
		
		[Bindable] public var uploadURL:String = uploadDomain+"upload.php";
		[Bindable] public var thumbURL:String = uploadDomain+"resources/images/thumbs";
		
		[Bindable] public var uploadFileReference:FileReference = null;
		[Bindable] public var uploadFileSelected:Boolean = false;
		
		[Bindable] public var uploadProgressUpdated:Boolean = false;
		[Bindable] public var uploadBytesLoaded: int;
		[Bindable] public var uploadBytesTotal: int;
		[Bindable] public var uploadFinished:Boolean = false;
		[Bindable] public var uploadFinishedData:Boolean = false;
		[Bindable] public var uploadErrors:String = '';
		
		
		[Bindable] public var newExerciseData:ExerciseVO = null;
		[Bindable] public var newYoutubeData:ExerciseVO = null;
		[Bindable] public var youtubeTransferComplete:Boolean = false;
		[Bindable] public var youtubeProcessingComplete:Boolean = false;
		[Bindable] public var youtubeProcessUpdate:Boolean = false;
		[Bindable] public var youtubeProcessMessage:String;
		
		[Bindable] public var youtubeThumbnailsUrl:String = "http://img.youtube.com/vi/";
		
		[Bindable] public var unprocessedExerciseSaved:Boolean = false;
		
		//Subtitle related data
		[Bindable] public var subtileSaveId:int;
		[Bindable] public var subtitleSaved:Boolean = false;
	
		[Bindable] public var videoPlayerControlsViewStack:int;	
				
		//Used to store exercise's roles added by the user  
		[Bindable] public var availableExerciseRoles:ArrayCollection = new ArrayCollection(new Array(null, null));
		[Bindable] public var availableExerciseRolesRetrieved:ArrayCollection = new ArrayCollection(new Array(false, false));
		
		//Used to store subtitle-lines and roles in the same DP
		[Bindable] public var availableSubtitleLinesRetrieved: Boolean = false;
		[Bindable] public var availableSubtitleLines:ArrayCollection = new ArrayCollection();
		[Bindable] public var unmodifiedAvailableSubtitleLines:ArrayCollection = new ArrayCollection();
		
		//Evaluation module data
		[Bindable] public var evaluationChartData:ArrayCollection;
		[Bindable] public var evaluationChartDataRetrieved:Boolean = false;
		
		[Bindable] public var waitingForAssessmentData:ArrayCollection;
		[Bindable] public var waitingForAssessmentDataRetrieved:Boolean = false;
		
		[Bindable] public var assessedToCurrentUserData:ArrayCollection;
		[Bindable] public var assessedToCurrentUserDataRetrieved:Boolean = false;
		
		[Bindable] public var assessedByCurrentUserData:ArrayCollection;
		[Bindable] public var assessedByCurrentUserDataRetrieved:Boolean = false;
		
		[Bindable] public var detailsOfAssessedResponseData:ArrayCollection;
		[Bindable] public var detailsOfAssessedResponseDataRetrieved:Boolean = false;
		
		[Bindable] public var addAssessmentRetrieved:Boolean = false;

		//Autoevaluation data
		[Bindable] public var autoevaluationResults:Evaluation = null;
		[Bindable] public var autoevaluationDone:Boolean = false;
		[Bindable] public var autoevaluationAvailable:Boolean = false;
		[Bindable] public var autoevaluationError:String = "";
		
		[Bindable] public var isAutoevaluable:Boolean = false;
		
		[Bindable] public var enableAutoevalToExerciseError:String = "";
		
		
		// Flag for stoping video after tab change
		[Bindable] public var stopVideoFlag:Boolean = false;
		// In order to avoid tab change if recording exercise
		[Bindable] public var recordingExercise:Boolean = false;

		
		//Used by configuration module
		[Bindable] public var videoRec:Boolean = false;
		[Bindable] public var audioRec:Boolean = false;
		[Bindable] public var recording:Boolean = false;
		[Bindable] public var playing:Boolean = false;
		[Bindable] public var permissions:Boolean = true;

		// l10n
		[Bindable] public var locales:Array = [ "en_US" , "es_ES", "eu_ES", "fr_FR"];
		
		// Shows if users denied access to cam or mic to video player
		[Bindable] public var microphone:Microphone;
		[Bindable] public var camera:Camera;
		[Bindable] public var micCamAllowed:Boolean = false;
		[Bindable] public var gapsWithNoSound:int = 0;
		[Bindable] public var soundDetected:Boolean = false;
		
		// Checks for exercise rating and reporting
		[Bindable] public var userRatedExercise:Boolean = false;
		[Bindable] public var userRatedExerciseFlag:Boolean = false;
		[Bindable] public var userReportedExercise:Boolean = false;
		[Bindable] public var userReportedExerciseFlag:Boolean = false;
		
		public function DataModel(){
			if (instance)
				throw new Error("DataModel can only be accessed through DataModel.getInstance()");
			
			//Initialize application's visuals
			initialize();
			
		}
		
		public static function getInstance():DataModel{
			return instance;
		}
		
		private function initialize():void{
			currentContentViewStackIndex = 0;
			currentExerciseViewStackIndex = 0;
			
			oldContentViewStackIndex = 0;
			newContentViewStackIndex = 0;
			
			localesAndFlags = new LocalesAndFlags();
		}

	}
}