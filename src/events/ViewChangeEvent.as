package events
{
	import com.adobe.cairngorm.control.CairngormEvent;


	public class ViewChangeEvent extends CairngormEvent
	{
		//This views belong to the application's content ViewStack
		public static const VIEW_EVALUATION_MODULE:String="viewEvaluationModule";
		public static const VIEW_EXERCISE_MODULE:String="viewExerciseModule";
		public static const VIEW_HOME_MODULE:String="viewHomeModule";
		public static const VIEW_UPLOAD_MODULE:String="viewUploadModule";
		public static const VIEW_PLAYER_MODULE:String="viewPlayerModule";
		public static const VIEW_CONFIGURATION_MODULE:String="viewConfigurationModule";
		public static const VIEW_RANKING_MODULE:String="viewRankingModule";
		public static const VIEW_ABOUT_MODULE:String="viewAboutModule";
		public static const VIEW_SEARCH_MODULE:String="viewSearchModule";
		public static const VIEW_HELP_MODULE:String="viewHelpModule";


		//User related views
		public static const VIEW_REGISTER_MODULE:String="viewRegisterModule";
		public static const VIEW_ACCOUNT_MODULE:String="viewAccountModule";
		public static const VIEW_ACTIVATION_MODULE:String="viewActivationModule";

		//This views belong to the application's exercise module's ViewStack
		public static const VIEW_EXERCISE_HOME:String="viewExerciseHome";
		public static const VIEW_EXERCISE_VIDEO_PLAY:String="viewExerciseVideoPlay";
		public static const VIEW_EXERCISE_VIDEO_RECORD:String="viewExerciseVideoRecord";
		public static const VIEW_EXERCISE_VIDEO_PLAY_BOTH:String="viewExerciseVideoPlayBoth";
		public static const VIEW_EXERCISE_VIDEO_PLAY_RECORDED:String="viewExerciseVideoPlayRecorded";
		public static const VIEW_EXERCISE_AVAILABLE_OPTIONS:String="viewExerciseAvailableOptions";
		public static const VIEW_EXERCISE_EVALUATION_OPTIONS:String="viewExerciseEvaluationOptions";

		//Upload related views
		public static const VIEW_UPLOAD_UNSIGNED:String="viewUploadUnsigned";
		public static const VIEW_UPLOAD_SIGNED_IN:String="viewUploadSignedIn";
		
		//Evaluation related views
		public static const VIEW_EVALUATION_UNSIGNED:String="viewEvaluationUnsigned";
		public static const VIEW_EVALUATION_SIGNED_IN:String="viewEvaluationSignedIn";
		
		//Index of application's content ViewStack
		public static const VIEWSTACK_HOME_MODULE_INDEX:int = 0;
		public static const VIEWSTACK_EXERCISE_MODULE_INDEX:int = 1;
		public static const VIEWSTACK_EVALUATION_MODULE_INDEX:int = 2;
		public static const VIEWSTACK_REGISTER_MODULE_INDEX:int = 3;
		public static const VIEWSTACK_ACCOUNT_MODULE_INDEX:int = 4;
		public static const VIEWSTACK_UPLOAD_MODULE_INDEX:int = 5;
		public static const VIEWSTACK_PLAYER_MODULE_INDEX:int = 6;
		public static const VIEWSTACK_CONFIGURATION_MODULE_INDEX:int = 7;
		//public static const VIEWSTACK_RANKING_MODULE_INDEX:int = 8;
		public static const VIEWSTACK_ABOUT_MODULE_INDEX:int = 8;
		public static const VIEWSTACK_SEARCH_MODULE_INDEX:int = 9;
		public static const VIEWSTACK_HELP_MODULE_INDEX:int = 10;
		public static const VIEWSTACK_ACTIVATION_MODULE_INDEX:int = 11;

		public function ViewChangeEvent(type:String)
		{
			super(type);
		}

	}
}