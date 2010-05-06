package control {
	import com.adobe.cairngorm.control.FrontController;
	
	import commands.AddCreditEntryExAdvisingCommand;
	import commands.AddCreditsForExerciseAdvisingCommand;
	import commands.VideoStopCommand;
	import commands.autoevaluation.AutoEvaluateCommand;
	import commands.autoevaluation.CheckAutoevaluationSupportExerciseCommand;
	import commands.autoevaluation.CheckAutoevaluationSupportResponseCommand;
	import commands.autoevaluation.EnableAutoevaluationExerciseCommand;
	import commands.autoevaluation.EnableAutoevaluationResponseCommand;
	import commands.configuration.ViewConfigurationModuleCommand;
	import commands.evaluation.AddCreditEntryEvaluatingCommand;
	import commands.evaluation.AddCreditsForEvaluatingCommand;
	import commands.evaluation.ViewEvaluationModuleCommand;
	import commands.evaluation.ViewEvaluationSignedInCommand;
	import commands.evaluation.ViewEvaluationUnsignedCommand;
	import commands.exercises.AddCreditEntryEvalRequestCommand;
	import commands.exercises.ExerciseSelectedCommand;
	import commands.exercises.GetExerciseLocalesCommand;
	import commands.exercises.GetExerciseRolesCommand;
	import commands.exercises.MakeResponsePublicCommand;
	import commands.exercises.RateExerciseCommand;
	import commands.exercises.ReportInappropriateExerciseCommand;	
	import commands.exercises.SaveResponseCommand;
	import commands.exercises.SubCreditsForEvalRequestCommand;
	import commands.exercises.UserRatedExerciseCommand;
	import commands.exercises.UserReportedExerciseCommand;
	import commands.exercises.ViewExerciseEvaluationOptionsCommand;
	import commands.exercises.ViewExerciseHomeCommand;
	import commands.exercises.ViewExerciseModuleCommand;
	import commands.main.GetAppPreferencesCommand;
	import commands.main.GetExercisesCommand;
	import commands.main.GetTopTenCreditedCommand;
	import commands.main.ViewAboutModuleCommand;
	import commands.main.ViewHelpModuleCommand;
	import commands.main.ViewHomeModuleCommand;
	import commands.main.ViewPlayerModuleCommand;
	import commands.main.ViewRankingModuleCommand;
	import commands.main.WatchExerciseCommand;
	import commands.search.LaunchSearchCommand;
	import commands.search.GetTagCloudCommand;
	import commands.search.ViewSearchModuleCommand;
	import commands.subtitles.AddCreditEntrySubtitlingCommand;
	import commands.subtitles.AddCreditsForSubtitlingCommand;
	import commands.subtitles.GetExerciseSubtitleLinesCommand;
	import commands.subtitles.SaveSubtitlesCommand;
	import commands.userManagement.ActivateUserCommand;
	import commands.userManagement.GetAllTimeCreditHistoryCommand;
	import commands.userManagement.GetCurrentDayCreditHistoryCommand;
	import commands.userManagement.GetLastMonthCreditHistoryCommand;
	import commands.userManagement.GetLastWeekCreditHistoryCommand;
	import commands.userManagement.GetUserInfoCommand;
	import commands.userManagement.ProcessLoginCommand;
	import commands.userManagement.RegisterUserCommand;
	import commands.userManagement.RestorePassCommand;
	import commands.userManagement.SignOutCommand;
	import commands.userManagement.ViewAccountModuleCommand;
	import commands.userManagement.ViewActivationModuleCommand;
	import commands.userManagement.ViewRegisterModuleCommand;
	import commands.videoUpload.AddCreditEntryUploadingCommand;
	import commands.videoUpload.AddCreditsForUploadingCommand;
	import commands.videoUpload.AddExerciseCommand;
	import commands.videoUpload.AddUnprocessedExerciseCommand;
	import commands.videoUpload.UploadBrowseCommand;
	import commands.videoUpload.UploadCancelCommand;
	import commands.videoUpload.UploadStartCommand;
	import commands.videoUpload.ViewUploadModuleCommand;
	import commands.videoUpload.ViewUploadSignedInCommand;
	import commands.videoUpload.ViewUploadUnsignedCommand;
	import commands.videoUpload.YoutubeCheckStatusCommand;
	import commands.videoUpload.YoutubeUploadCommand;
	
	import events.CreditEvent;
	import events.EvaluationEvent;
	import events.ExerciseEvent;
	import events.ExerciseRoleEvent;
	import events.LoginEvent;
	import events.PreferenceEvent;
	import events.RegisterUserEvent;
	import events.ResponseEvent;
	import events.SearchEvent;
	import events.SubtitleEvent;
	import events.UploadEvent;
	import events.UserEvent;
	import events.VideoStopEvent;
	import events.ViewChangeEvent;

	public class Controller extends FrontController {
		//All the application's actions are managed from this controller
		public function Controller() {
			super();
			//Content ViewStack related commands
			addCommand(ViewChangeEvent.VIEW_HOME_MODULE, ViewHomeModuleCommand);
			addCommand(ViewChangeEvent.VIEW_EXERCISE_MODULE, ViewExerciseModuleCommand);
			addCommand(ViewChangeEvent.VIEW_EVALUATION_MODULE, ViewEvaluationModuleCommand);
			addCommand(ViewChangeEvent.VIEW_REGISTER_MODULE, ViewRegisterModuleCommand);
			addCommand(ViewChangeEvent.VIEW_ACCOUNT_MODULE, ViewAccountModuleCommand);
			addCommand(ViewChangeEvent.VIEW_UPLOAD_MODULE, ViewUploadModuleCommand);
			addCommand(ViewChangeEvent.VIEW_PLAYER_MODULE, ViewPlayerModuleCommand);
			addCommand(ViewChangeEvent.VIEW_RANKING_MODULE, ViewRankingModuleCommand);
			addCommand(ViewChangeEvent.VIEW_SEARCH_MODULE, ViewSearchModuleCommand);
			addCommand(ViewChangeEvent.VIEW_ABOUT_MODULE, ViewAboutModuleCommand);
			addCommand(ViewChangeEvent.VIEW_HELP_MODULE, ViewHelpModuleCommand);
			addCommand(ViewChangeEvent.VIEW_ACTIVATION_MODULE, ViewActivationModuleCommand);


			//Exercise ViewStack related commands
			addCommand(ViewChangeEvent.VIEW_EXERCISE_HOME, ViewExerciseHomeCommand);
			addCommand(ViewChangeEvent.VIEW_EXERCISE_EVALUATION_OPTIONS, ViewExerciseEvaluationOptionsCommand);

			//Upload ViewStack related commands
			addCommand(ViewChangeEvent.VIEW_UPLOAD_UNSIGNED, ViewUploadUnsignedCommand);
			addCommand(ViewChangeEvent.VIEW_UPLOAD_SIGNED_IN, ViewUploadSignedInCommand);
			
			//Evaluation ViewStack related commands
			addCommand(ViewChangeEvent.VIEW_EVALUATION_UNSIGNED, ViewEvaluationUnsignedCommand);
			addCommand(ViewChangeEvent.VIEW_EVALUATION_SIGNED_IN, ViewEvaluationSignedInCommand);

			//Credit management commands
			addCommand(CreditEvent.SUB_CREDITS_FOR_EVAL_REQUEST, SubCreditsForEvalRequestCommand);
			addCommand(CreditEvent.ADD_CREDITS_FOR_EVALUATING, AddCreditsForEvaluatingCommand);
			addCommand(CreditEvent.ADD_CREDITS_FOR_SUBTITLING, AddCreditsForSubtitlingCommand);
			addCommand(CreditEvent.ADD_CREDITS_FOR_EXERCISE_ADVISING, AddCreditsForExerciseAdvisingCommand);
			addCommand(CreditEvent.ADD_CREDITS_FOR_UPLOADING, AddCreditsForUploadingCommand);

			addCommand(CreditEvent.GET_ALL_TIME_CREDIT_HISTORY, GetAllTimeCreditHistoryCommand);
			addCommand(CreditEvent.GET_CURRENT_DAY_CREDIT_HISTORY, GetCurrentDayCreditHistoryCommand);
			addCommand(CreditEvent.GET_LAST_WEEK_CREDIT_HISTORY, GetLastWeekCreditHistoryCommand);
			addCommand(CreditEvent.GET_LAST_MONTH_CREDIT_HISTORY, GetLastMonthCreditHistoryCommand);
			addCommand(CreditEvent.ADD_CREDIT_ENTRY_EVAL_REQUEST, AddCreditEntryEvalRequestCommand);
			addCommand(CreditEvent.ADD_CREDIT_ENTRY_EVALUATING, AddCreditEntryEvaluatingCommand);
			addCommand(CreditEvent.ADD_CREDIT_ENTRY_EX_ADVISING, AddCreditEntryExAdvisingCommand);
			addCommand(CreditEvent.ADD_CREDIT_ENTRY_SUBTITLING, AddCreditEntrySubtitlingCommand);
			addCommand(CreditEvent.ADD_CREDIT_ENTRY_UPLOADING, AddCreditEntryUploadingCommand);

			//Preference management commands
			addCommand(PreferenceEvent.GET_APP_PREFERENCES, GetAppPreferencesCommand);

			//User management commands
			addCommand(UserEvent.GET_TOP_TEN_CREDITED, GetTopTenCreditedCommand);
			addCommand(UserEvent.GET_USER_INFO, GetUserInfoCommand);

			//Search management commands
			addCommand(SearchEvent.LAUNCH_SEARCH, LaunchSearchCommand);
			addCommand(SearchEvent.GET_TAG_CLOUD, GetTagCloudCommand);

			//Login management commands
			addCommand(LoginEvent.PROCESS_LOGIN, ProcessLoginCommand);
			addCommand(LoginEvent.SIGN_OUT, SignOutCommand);
			addCommand(LoginEvent.RESTORE_PASS, RestorePassCommand);

			// User Registration management
			addCommand(RegisterUserEvent.REGISTER_USER, RegisterUserCommand);
			addCommand(RegisterUserEvent.ACTIVATE_USER, ActivateUserCommand);

			//Upload management commands
			addCommand(UploadEvent.UPLOAD_BROWSE, UploadBrowseCommand);
			addCommand(UploadEvent.UPLOAD_START, UploadStartCommand);
			addCommand(UploadEvent.UPLOAD_CANCEL, UploadCancelCommand);
			addCommand(UploadEvent.YOUTUBE_UPLOAD, YoutubeUploadCommand);
			addCommand(UploadEvent.YOUTUBE_CHECK_VIDEO_STATUS, YoutubeCheckStatusCommand);
			addCommand(ExerciseEvent.ADD_UNPROCESSED_EXERCISE, AddUnprocessedExerciseCommand);

			//Exercise management commands
			addCommand(ExerciseEvent.ADD_EXERCISE, AddExerciseCommand);
			addCommand(ExerciseEvent.GET_EXERCISES, GetExercisesCommand);
			addCommand(ExerciseEvent.GET_EXERCISE_LOCALES, GetExerciseLocalesCommand);
			addCommand(ExerciseEvent.WATCH_EXERCISE, WatchExerciseCommand);
			addCommand(ExerciseEvent.EXERCISE_SELECTED, ExerciseSelectedCommand);
			addCommand(ExerciseEvent.RATE_EXERCISE, RateExerciseCommand);
			addCommand(ExerciseEvent.REPORT_EXERCISE, ReportInappropriateExerciseCommand);
			addCommand(ExerciseEvent.USER_RATED_EXERCISE, UserRatedExerciseCommand);
			addCommand(ExerciseEvent.USER_REPORTED_EXERCISE, UserReportedExerciseCommand);
			
			//Response management commands
			addCommand(ResponseEvent.SAVE_RESPONSE, SaveResponseCommand);
			addCommand(ResponseEvent.MAKE_RESPONSE_PUBLIC, MakeResponsePublicCommand);

			
			//Roles management commands
			addCommand(ExerciseRoleEvent.GET_EXERCISE_ROLES, GetExerciseRolesCommand);


			//Subtitle management commands
			addCommand(SubtitleEvent.SAVE_SUBTITLE_AND_SUBTITLE_LINES, SaveSubtitlesCommand);
			addCommand(SubtitleEvent.GET_EXERCISE_SUBTITLE_LINES, GetExerciseSubtitleLinesCommand);

			//Evaluation management commands
			addCommand(EvaluationEvent.AUTOMATIC_EVAL_RESULTS, AutoEvaluateCommand);
			addCommand(EvaluationEvent.ENABLE_TRANSCRIPTION_TO_EXERCISE, EnableAutoevaluationExerciseCommand);
			addCommand(EvaluationEvent.ENABLE_TRANSCRIPTION_TO_RESPONSE, EnableAutoevaluationResponseCommand);
			addCommand(EvaluationEvent.CHECK_AUTOEVALUATION_SUPPORT_EXERCISE, CheckAutoevaluationSupportExerciseCommand);
			addCommand(EvaluationEvent.CHECK_AUTOEVALUATION_SUPPORT_RESPONSE, CheckAutoevaluationSupportResponseCommand);
		
			// Video stop after tab changing
			addCommand(VideoStopEvent.STOP_ALL_VIDEOS, VideoStopCommand);
			
			//Configuration ViewStack related commands
			addCommand(ViewChangeEvent.VIEW_CONFIGURATION_MODULE, ViewConfigurationModuleCommand);
		}

	}
}