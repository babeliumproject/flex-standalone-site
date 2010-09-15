package control {
	import com.adobe.cairngorm.control.FrontController;
	
	import commands.VideoStopCommand;
	import commands.autoevaluation.*;
	import commands.configuration.*;
	import commands.evaluation.*;
	import commands.exercises.*;
	import commands.main.*;
	import commands.search.*;
	import commands.subtitles.*;
	import commands.userManagement.*;
	import commands.videoUpload.*;
	
	import events.*;

	public class Controller extends FrontController {
		//All the application's actions are managed from this controller
		public function Controller() {
			super();
			
			//Connection management commands
			addCommand(SetupConnectionEvent.EVENT_SETUP_CONNECTION, SetupConnectionCommand);
			addCommand(StartConnectionEvent.EVENT_START_CONNECTION, StartConnectionCommand);
			addCommand(CloseConnectionEvent.EVENT_CLOSE_CONNECTION, CloseConnectionCommand);
			
			
			//Content ViewStack related commands
			addCommand(ViewChangeEvent.VIEW_HOME_MODULE, ViewHomeModuleCommand);
			addCommand(ViewChangeEvent.VIEW_EXERCISE_MODULE, ViewExerciseModuleCommand);
			addCommand(ViewChangeEvent.VIEW_EVALUATION_MODULE, ViewEvaluationModuleCommand);
			addCommand(ViewChangeEvent.VIEW_REGISTER_MODULE, ViewRegisterModuleCommand);
			addCommand(ViewChangeEvent.VIEW_ACCOUNT_MODULE, ViewAccountModuleCommand);
			addCommand(ViewChangeEvent.VIEW_UPLOAD_MODULE, ViewUploadModuleCommand);
			addCommand(ViewChangeEvent.VIEW_SUBTITLE_MODULE, ViewPlayerModuleCommand);
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
			
			//Configuration ViewStack related commands
			addCommand(ViewChangeEvent.VIEW_CONFIG_UNSIGNED, ViewConfigUnsignedCommand);
			addCommand(ViewChangeEvent.VIEW_CONFIG_SIGNED, ViewConfigSignedCommand);

			//Credit management commands
			addCommand(CreditEvent.SUB_CREDITS_FOR_EVAL_REQUEST, SubCreditsForEvalRequestCommand);
			addCommand(CreditEvent.ADD_CREDITS_FOR_EVALUATING, AddCreditsForEvaluatingCommand);
			addCommand(CreditEvent.ADD_CREDITS_FOR_SUBTITLING, AddCreditsForSubtitlingCommand);
			addCommand(CreditEvent.ADD_CREDITS_FOR_UPLOADING, AddCreditsForUploadingCommand);

			addCommand(CreditEvent.GET_ALL_TIME_CREDIT_HISTORY, GetAllTimeCreditHistoryCommand);
			addCommand(CreditEvent.GET_CURRENT_DAY_CREDIT_HISTORY, GetCurrentDayCreditHistoryCommand);
			addCommand(CreditEvent.GET_LAST_WEEK_CREDIT_HISTORY, GetLastWeekCreditHistoryCommand);
			addCommand(CreditEvent.GET_LAST_MONTH_CREDIT_HISTORY, GetLastMonthCreditHistoryCommand);
			addCommand(CreditEvent.ADD_CREDIT_ENTRY_EVAL_REQUEST, AddCreditEntryEvalRequestCommand);
			addCommand(CreditEvent.ADD_CREDIT_ENTRY_EVALUATING, AddCreditEntryEvaluatingCommand);
			addCommand(CreditEvent.ADD_CREDIT_ENTRY_SUBTITLING, AddCreditEntrySubtitlingCommand);
			addCommand(CreditEvent.ADD_CREDIT_ENTRY_UPLOADING, AddCreditEntryUploadingCommand);
			
			//Video history management commands
			addCommand(UserVideoHistoryEvent.STAT_EXERCISE_WATCH, VideoHistoryWatchCommand);
			addCommand(UserVideoHistoryEvent.STAT_ATTEMPT_RESPONSE, VideoHistoryAttemptCommand);
			addCommand(UserVideoHistoryEvent.STAT_SAVE_RESPONSE, VideoHistorySaveCommand);

			//Preference management commands
			addCommand(PreferenceEvent.GET_APP_PREFERENCES, GetAppPreferencesCommand);

			//User management commands
			addCommand(UserEvent.GET_TOP_TEN_CREDITED, GetTopTenCreditedCommand);
			addCommand(UserEvent.GET_USER_INFO, GetUserInfoCommand);
			addCommand(UserEvent.KEEP_SESSION_ALIVE, KeepSessionAliveCommand);

			//Search management commands
			addCommand(SearchEvent.LAUNCH_SEARCH, LaunchSearchCommand);
			addCommand(SearchEvent.GET_TAG_CLOUD, GetTagCloudCommand);

			//Login management commands
			addCommand(LoginEvent.PROCESS_LOGIN, ProcessLoginCommand);
			addCommand(LoginEvent.SIGN_OUT, SignOutCommand);
			addCommand(LoginEvent.RESTORE_PASS, RestorePassCommand);
			addCommand(LoginEvent.RESEND_ACTIVATION_EMAIL, ResendActivationEmailCommand);
			addCommand(ModifyUserEvent.CHANGE_PASS, ChangePassCommand);
			
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
			addCommand(ExerciseEvent.ADD_WEBCAM_EXERCISE, AddWebcamExerciseCommand);

			//Exercise management commands
			addCommand(ExerciseEvent.ADD_EXERCISE, AddExerciseCommand);
			addCommand(ExerciseEvent.GET_EXERCISES, GetExercisesCommand);
			addCommand(ExerciseEvent.GET_RECORDABLE_EXERCISES, GetRecordableExercisesCommand);
			addCommand(ExerciseEvent.GET_EXERCISE_LOCALES, GetExerciseLocalesCommand);
			addCommand(ExerciseEvent.WATCH_EXERCISE, WatchExerciseCommand);
			addCommand(ExerciseEvent.EXERCISE_SELECTED, ExerciseSelectedCommand);
			addCommand(ExerciseEvent.RATE_EXERCISE, RateExerciseCommand);
			addCommand(ExerciseEvent.REPORT_EXERCISE, ReportInappropriateExerciseCommand);
			addCommand(ExerciseEvent.USER_RATED_EXERCISE, UserRatedExerciseCommand);
			addCommand(ExerciseEvent.USER_REPORTED_EXERCISE, UserReportedExerciseCommand);
			
			//Evaluation management commands
			addCommand(EvaluationEvent.GET_RESPONSES_WAITING_ASSESSMENT, GetResponsesWaitingAssessmentCommand);
			addCommand(EvaluationEvent.GET_RESPONSES_ASSESSED_TO_CURRENT_USER, GetResponsesAssessedToCurrentUserCommand);
			addCommand(EvaluationEvent.GET_RESPONSES_ASSESSED_BY_CURRENT_USER, GetResponsesAssessedByCurrentUserCommand);
			addCommand(EvaluationEvent.ADD_ASSESSMENT, AddAssessmentCommand);
			addCommand(EvaluationEvent.ADD_VIDEO_ASSESSMENT, AddVideoAssessmentCommand);
			addCommand(EvaluationEvent.DETAILS_OF_ASSESSED_RESPONSE, DetailsOfAssessedResponseCommand);
			addCommand(EvaluationEvent.UPDATE_RESPONSE_RATING_AMOUNT, UpdateResponseRatingAmountCommand);
			addCommand(EvaluationEvent.GET_EVALUATION_CHART_DATA, GetEvaluationChartDataCommand);
			
			//Autoevaluation management commands
			addCommand(EvaluationEvent.AUTOMATIC_EVAL_RESULTS, AutoEvaluateCommand);
			addCommand(EvaluationEvent.ENABLE_TRANSCRIPTION_TO_EXERCISE, EnableAutoevaluationExerciseCommand);
			addCommand(EvaluationEvent.ENABLE_TRANSCRIPTION_TO_RESPONSE, EnableAutoevaluationResponseCommand);
			addCommand(EvaluationEvent.CHECK_AUTOEVALUATION_SUPPORT_EXERCISE, CheckAutoevaluationSupportExerciseCommand);
			addCommand(EvaluationEvent.CHECK_AUTOEVALUATION_SUPPORT_RESPONSE, CheckAutoevaluationSupportResponseCommand);
			
			//Response management commands
			addCommand(ResponseEvent.SAVE_RESPONSE, SaveResponseCommand);
			addCommand(ResponseEvent.MAKE_RESPONSE_PUBLIC, MakeResponsePublicCommand);
			
			//Roles management commands
			addCommand(ExerciseRoleEvent.GET_EXERCISE_ROLES, GetExerciseRolesCommand);

			//Subtitle management commands
			addCommand(SubtitleEvent.SAVE_SUBTITLE_AND_SUBTITLE_LINES, SaveSubtitlesCommand);
			addCommand(SubtitleEvent.GET_EXERCISE_SUBTITLE_LINES, GetExerciseSubtitleLinesCommand);
			
			// Video stop after tab changing
			addCommand(VideoStopEvent.STOP_ALL_VIDEOS, VideoStopCommand);
			
			//Configuration ViewStack related commands
			addCommand(ViewChangeEvent.VIEW_CONFIGURATION_MODULE, ViewConfigurationModuleCommand);
		}

	}
}