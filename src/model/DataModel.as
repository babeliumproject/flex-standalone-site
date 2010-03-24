package model
{
	
	import com.adobe.cairngorm.model.IModelLocator;
	
	import flash.net.FileReference;
	import flash.utils.Dictionary;
	
	import modules.autoevaluation.Evaluation;
	
	import mx.collections.ArrayCollection;
	
	import vo.CreditHistoryVO;
	import vo.ExerciseVO;
	import vo.UserVO;
	
	public class DataModel implements IModelLocator
	{
		//This solution for singleton implementation was found in
		//http://life.neophi.com/danielr/2006/10/singleton_pattern_in_as3.html		
		public static var instance:DataModel = new DataModel();
		
		public var media:Media;
		
		//ViewStack management variables
		[Bindable] public var viewContentViewStackIndex:int;
		[Bindable] public var viewExerciseViewStackIndex:int;
		[Bindable] public var viewUploadViewStackIndex:int;
		
		//ViewSize management properties
		[Bindable] public var viewSizeChanged:Boolean;
		
		//Application preferences value pair
		[Bindable] public var prefDic:Dictionary;
		
		//Account options list
		[Bindable] public var accountOptions:ArrayCollection = new ArrayCollection 
		(new Array ("General Overview","Credit History","Password Change","Top Collaborators"));
		
		//Top ten collaborators data and service state
		[Bindable] public var topTenUsers:ArrayCollection;
		[Bindable] public var isTopTenRetrieved:Boolean = false;
		
		//Login data and service state
		[Bindable] public var loggedUser:UserVO = null;
		[Bindable] public var isSuccessfullyLogged:Boolean = false;
		[Bindable] public var isLoggedIn:Boolean = false;
		[Bindable] public var loginErrorMessage:String = "";
		[Bindable] public var creditUpdateRetrieved:Boolean = false;
		
		//Pass recovery
		[Bindable] public var passRecoveryDone:Boolean;
		
		//Register error message
		[Bindable] public var registrationErrorMessage:String = "";
		[Bindable] public var restorePassErrorMessage:String = "";
		
		//Credit History data and service state
		[Bindable] public var creditHistory:ArrayCollection = new ArrayCollection();
		[Bindable] public var creditChartData:ArrayCollection;
		[Bindable] public var isCreditHistoryRetrieved:Boolean = false;
		[Bindable] public var isChartDataRetrieved:Boolean = false;
		
		[Bindable] public var historicData:CreditHistoryVO = null;
		[Bindable] public var subHistoricData:CreditHistoryVO = null;	
		
		//The info of the current video
		[Bindable] public var currentExercise:ArrayCollection = new ArrayCollection(new Array(null, null));
		[Bindable] public var currentExerciseRetrieved:ArrayCollection = new ArrayCollection(new Array(false, false));
		
		[Bindable] public var availableExercises:ArrayCollection;
		[Bindable] public var availableExercisesRetrieved:ArrayCollection = new ArrayCollection(new Array(false, false));
		
		[Bindable] public var availableExerciseLocales:Array;
		[Bindable] public var availableExerciseLocalesRetrieved:Boolean = false;
		
		[Bindable] public var evaluationPendingResponses:ArrayCollection;
		[Bindable] public var evaluationPendingRetrieved:Boolean = false;
		
		//Exercise uploading related data
		[Bindable] public var server: String = "babelia";
		[Bindable] public var red5Port: String = "1935";
		[Bindable] public var uploadDomain:String = "http://"+server+"/";
		
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
		
		//Autoevaluation data
		[Bindable] public var autoevaluationResults:Evaluation = null;
		[Bindable] public var autoevaluationDone:Boolean = false;
		[Bindable] public var autoevaluationAvailable:Boolean = false;
		[Bindable] public var autoevaluationError:String = "";
		
		[Bindable] public var isAutoevaluable:Boolean = false;
		
		
		// Flag for stoping video after tab change
		[Bindable] public var stopVideoFlag:Boolean = false;
		// In order to avoid tab change if recording exercise
		[Bindable] public var recordingExercise:Boolean = false;
		
		// Shows if users denied access to cam or mic to video player
		[Bindable] public var camAccessDenied:Boolean = false;
		[Bindable] public var micAccessDenied:Boolean = false;
		
		//Used to configuration module
		[Bindable] public var videoRec:Boolean = false;
		[Bindable] public var audioRec:Boolean = false;
		[Bindable] public var recording:Boolean = false;
		[Bindable] public var playing:Boolean = false;

		// l10n
		[Bindable] public var locales:Array = [ "en_US" , "es_ES", "eu_ES", "fr_FR"];
	
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
			viewContentViewStackIndex = 0;
			viewExerciseViewStackIndex = 0;
			media = new Media();
		}

	}
}