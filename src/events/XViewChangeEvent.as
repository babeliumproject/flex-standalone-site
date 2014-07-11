package events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import components.configuration.ConfigurationContainer;
	import components.configuration.ConfigurationMain;
	import components.evaluation.EvaluationContainer;
	import modules.exercises.Exercises;
	import components.home.HomeMain;
	import components.main.About;
	import components.main.HelpFAQMain;
	import components.search.Search;
	import components.subtitles.SubtitleMain;
	import modules.login.view.LoginActivate;
	import components.userManagement.AccountMain;
	import components.userManagement.SignUpForm;
	import components.videoUpload.UploadContainer;


	public class XViewChangeEvent extends CairngormEvent
	{
		//This views belong to the application's content ViewStack
		public static const VIEW_EVALUATION_MODULE:String="viewEvaluationModule";
		public static const VIEW_EXERCISE_MODULE:String="viewExerciseModule";
		public static const VIEW_HOME_MODULE:String="viewHomeModule";
		public static const VIEW_UPLOAD_MODULE:String="viewUploadModule";
		public static const VIEW_SUBMODULE:String="viewSubtitleModule";
		public static const VIEW_CONFIGURATION_MODULE:String="viewConfigurationModule";
		public static const VIEW_RANKING_MODULE:String="viewRankingModule";
		public static const VIEW_ABOUT_MODULE:String="viewAboutModule";
		public static const VIEW_SEARCH_MODULE:String="viewSearchModule";
		public static const VIEW_HELP_MODULE:String="viewHelpModule";
		public static const VIEW_COURSE_MODULE:String="viewCourseModule";
		
		public static const VIEW_LOGIN_MODULE:String="viewLoginModule";

		//User related views
		public static const VIEW_REGISTER_MODULE:String="viewRegisterModule";
		public static const VIEW_ACCOUNT_MODULE:String="viewAccountModule";
		public static const VIEW_ACTIVATION_MODULE:String="viewActivationModule";
		
		//Home related views
		public static const VIEW_HOME_UNSIGNED:String="viewHomeUnsigned";
		public static const VIEW_HOME_SIGNED_IN:String="viewHomeSignedIn";
		
		//Upload related views
		public static const VIEW_UPLOAD_UNSIGNED:String="viewUploadUnsigned";
		public static const VIEW_UPLOAD_SIGNED_IN:String="viewUploadSignedIn";
		
		//Configuration related views
		public static const VIEW_CONFIG_UNSIGNED:String="viewConfigUnsigned";
		public static const VIEW_CONFIG_SIGNED:String="viewConfigSigned";
		
		//Evaluation related views
		public static const VIEW_EVALUATION_UNSIGNED:String="viewEvaluationUnsigned";
		public static const VIEW_EVALUATION_SIGNED_IN:String="viewEvaluationSignedIn";
		
		//Subtitle related views
		public static const VIEW_SUBTITLES_UNSIGNED:String="viewSubtitlesUnsigned";
		public static const VIEW_SUBTITLES_SIGNED_IN:String="viewSubtitlesSignedIn";
		public static const VIEW_SUBEDITOR:String="viewSubtitleEditor";
		
		//User account related views
		public static const VIEW_ACCOUNT_UNSIGNED:String="viewAccountUnsigned";
		public static const VIEW_ACCOUNT_SIGNED:String="viewAccountSigned";
		
		public static const VIEW_COURSE_UNSIGNED:String="viewCourseUnsigned";
		public static const VIEW_COURSE_SIGNED:String="viewCourseSigned";
		
		
		//Indexes of application's content ViewStack
		public static const VIEWSTACK_HOME_MODULE_INDEX:uint = 0;
		public static const VIEWSTACK_EXERCISE_MODULE_INDEX:uint = 1;
		public static const VIEWSTACK_EVALUATION_MODULE_INDEX:uint = 2;
		public static const VIEWSTACK_REGISTER_MODULE_INDEX:uint = 3;
		public static const VIEWSTACK_ACCOUNT_MODULE_INDEX:uint = 4;
		public static const VIEWSTACK_UPLOAD_MODULE_INDEX:uint = 5;
		public static const VIEWSTACK_SUBMODULE_INDEX:uint = 6;
		public static const VIEWSTACK_CONFIGURATION_MODULE_INDEX:uint = 7;
		public static const VIEWSTACK_ABOUT_MODULE_INDEX:uint = 8;
		public static const VIEWSTACK_SEARCH_MODULE_INDEX:uint = 9;
		public static const VIEWSTACK_HELP_MODULE_INDEX:uint = 10;
		public static const VIEWSTACK_ACTIVATION_MODULE_INDEX:uint = 11;
		public static const VIEWSTACK_COURSE_MODULE_INDEX:uint = 12;
		public static const VIEWSTACK_LOGIN_MODULE_INDEX:uint = 13;

		public function XViewChangeEvent(type:String)
		{
			super(type);
		}

	}
}