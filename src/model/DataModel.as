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
		private static var instance:DataModel = new DataModel();
		
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
		(new Array ("General Overview","Credit History","Password Change","Top Collaborators","Check Web-Cam"));
		
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
		
		//Used to store the subtitles of a video file, it's an array of CuePoints
		[Bindable] public var videoSubtitles:ArrayCollection;
		[Bindable] public var areVideoSubtitlesRetrieved:Boolean = false;
		
		//Used to store the subtitles added by the current user
		[Bindable] public var userVideoSubtitles:ArrayCollection;
		[Bindable] public var areUserVideoSubtitlesRetrieved:Boolean = false;	
		
		//The info of the current video
		[Bindable] public var currentExercise:ExerciseVO;
		[Bindable] public var currentExerciseRetrieved:Boolean = false;
		
		[Bindable] public var availableExercises:ArrayCollection;
		[Bindable] public var availableExercisesRetrieved:Boolean = false;
		
		[Bindable] public var evaluationPendingResponses:ArrayCollection;
		[Bindable] public var evaluationPendingRetrieved:Boolean = false;
		
		//Exercise uploading related data
		[Bindable] public var server: String = "localhost";
		[Bindable] public var red5Port: String = "1935";
		[Bindable] public var uploadDomain:String = "http://"+server+"/";
		
		[Bindable] public var uploadURL:String = uploadDomain+"amfphp/services/babelia/upload.php";
		
		[Bindable] public var uploadFileReference:FileReference = null;
		[Bindable] public var uploadFileSelected:Boolean = false;
		
		[Bindable] public var uploadProgressUpdated:Boolean = false;
		[Bindable] public var uploadBytesLoaded: int;
		[Bindable] public var uploadBytesTotal: int;
		[Bindable] public var uploadFinished:Boolean = false;
		[Bindable] public var uploadFinishedData:Boolean = false;
		
		
		[Bindable] public var newExerciseData:ExerciseVO = null;
		[Bindable] public var newYoutubeData:ExerciseVO = null;
		[Bindable] public var youtubeTransferComplete:Boolean = false;
		[Bindable] public var youtubeProcessingComplete:Boolean = false;
		[Bindable] public var youtubeProcessUpdate:Boolean = false;
		[Bindable] public var youtubeProcessMessage:String;
		
		[Bindable] public var youtubeThumbnailsUrl:String = "http://img.youtube.com/vi/";
		
		//Rol related data    
		[Bindable] public var exerciseRoleSaveId:int;
		[Bindable] public var exerciseRoleSaved:Boolean = false;
		
		//Subtitle related data
		[Bindable] public var subtileSaveId:int;
		[Bindable] public var subtitleSaved:Boolean = false;
		[Bindable] public var subtitleGet:ArrayCollection;
		[Bindable] public var subtitleDp:ArrayCollection;
		[Bindable] public var subtitulosDp:ArrayCollection;	
		[Bindable] public var videoPlayerControlsViewStack:int;	
				
		//Used to store exercise's roles added by the user  
		[Bindable] public var availableExerciseRoles:ArrayCollection;
		
		//Used to store subtitle-lines and roles in the same DP
		[Bindable] public var availableSubtitlesAndRoles:ArrayCollection;
					
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
		
		// l10n
			
		[Bindable] public var locales:Array = [ "en_US" , "es_SP", "eu_EK", "fr_FR"];
	
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