package control
{
	import events.CloseConnectionEvent;
	import events.ViewChangeEvent;
	
	import flash.utils.Dictionary;
	
	import model.DataModel;
	
	import modules.configuration.ConfigurationContainer;
	import modules.configuration.ConfigurationMain;
	import modules.evaluation.EvaluationContainer;
	import modules.exercises.Exercises;
	import modules.home.HomeMain;
	import modules.main.About;
	import modules.main.HelpFAQMain;
	import modules.search.Search;
	import modules.subtitles.SubtitleMain;
	import modules.userManagement.AccountActivation;
	import modules.userManagement.AccountMain;
	import modules.userManagement.SignUpForm;
	import modules.videoUpload.UploadContainer;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.events.BrowserChangeEvent;
	import mx.managers.BrowserManager;
	import mx.managers.IBrowserManager;
	import mx.rpc.CallResponder;
	import mx.utils.ObjectUtil;
	
	import spark.components.Group;


	/**
	 * Default URL Format: http://babelia/#/module/action/target
	 */
	public class BabeliaBrowserManager
	{
		/** Constants **/
		public static const DELIMITER:String="/";
		public static const TARGET_DELIMITER:String="&";

		/** Variables **/
		public static var instance:BabeliaBrowserManager=new BabeliaBrowserManager();
		private var _isParsing:Boolean;
		private var _browserManager:IBrowserManager;

		/**
		 * URL Related Constants
		 **/
		private var _modulesFragments:Dictionary;

		[Bindable]
		public var moduleClass:Class;
		[Bindable]
		public var actionFragment:String;
		[Bindable]
		public var targetFragment:String;

		/**
		 * ACTION CONSTANTS
		 **/
		public static const ACTIVATE:String="activate";
		public static const SUBTITLE:String="edit";
		public static const VIEW:String="view";
		public static const RECORD:String="rec";
		public static const REVISE:String="revise";
		public static const EVALUATE:String="evaluate";

		/**
		 * Constructor
		 **/
		public function BabeliaBrowserManager()
		{
			if (instance)
				throw new Error("BabeliaBrowserManager is already running");

			_browserManager=BrowserManager.getInstance();
			_browserManager.init();
			_browserManager.addEventListener(BrowserChangeEvent.BROWSER_URL_CHANGE, parseURL);

			_isParsing=false;

			// viewstack-> url href
			_modulesFragments=new Dictionary();

			// fill array
//			for ( var i:int = 0; i < 20; i++ )
//				_modulesFragments.addItem(null);

			_modulesFragments[About]="about";
			_modulesFragments[AccountMain]="account";
			_modulesFragments[ConfigurationContainer]="config";
			_modulesFragments[EvaluationContainer]="evaluation";
			_modulesFragments[Exercises]="exercises";
			_modulesFragments[HomeMain]="home";
			_modulesFragments[SignUpForm]="register";
			_modulesFragments[Search]="search";
			_modulesFragments[UploadContainer]="upload";
			_modulesFragments[HelpFAQMain]="help";
			_modulesFragments[AccountActivation]="activation";
			_modulesFragments[SubtitleMain]="subtitles";
		}

		// Get instance
		public static function getInstance():BabeliaBrowserManager
		{
			return instance;
		}

		/**
		 * Parse function
		 **/
		public function parseURL(e:BrowserChangeEvent=null):void
		{
			_isParsing=true;

			clearFragments();

			var params:Array=_browserManager.fragment.split(DELIMITER);
			var length:Number=params.length;

			if (length <= 1)
				updateURL(index2fragment(ViewChangeEvent.VIEWSTACK_HOME_MODULE_INDEX));

			if (length > 1) // module
				if (!changeModule(params[1]))
					return;

			if (length > 2) // action
				actionFragment=params[2];

			if (length > 3) // target
				targetFragment=params[3];

			_isParsing=false;
		}


		/**
		 * Update URL function
		 **/
		public function updateURL(module:String, action:String=null, target:String=null):void
		{
			// default url format: /module/action/target

			clearFragments();

			if (action == null)
				_browserManager.setFragment(DELIMITER + module);
			else if (target == null)
				_browserManager.setFragment(DELIMITER + module + DELIMITER + action);
			else
				_browserManager.setFragment(DELIMITER + module + DELIMITER + action + DELIMITER + target);
		}


		/**
		 * From index to fragment
		 **/
		public static function index2fragment(module:Class):String
		{
			return instance._modulesFragments[module] as String;
		}


		/**
		 * Change module
		 **/
		private function changeModule(moduleName:String):Boolean
		{
			moduleClass=null;
			for (var modClass:Object in _modulesFragments)
			{
				if (_modulesFragments[modClass] == moduleName)
				{
					moduleClass=modClass as Class;
					break;
				}
			}

			if (moduleClass == SignUpForm && !DataModel.getInstance().isLoggedIn)
			{
				//		DataModel.getInstance().currentContentViewStackIndex = 0;
				addModuleAsChild(HomeMain);
				updateURL("home");
			}

			if (moduleClass != null)
			{
				addModuleAsChild(moduleClass);
				return true;
			}

			return false;
		}
		
		private function addModuleAsChild(moduleClass:Class):void{
			if (DataModel.getInstance().appBody.numElements > 0)
			{
				new CloseConnectionEvent().dispatch();
				removeAllChildrenFromComponent(DataModel.getInstance().appBody)
			}
			DataModel.getInstance().appBody.addElement(new moduleClass());
		}
		
		protected function removeAllChildrenFromComponent(component:Group):void
		{
			for (var i:uint=0; i < component.numElements; i++)
				component.removeElementAt(i);
		}

		/**
		 * Clear Fragments
		 **/
		private function clearFragments():void
		{
			moduleClass=null;
			actionFragment=null;
			targetFragment=null;
		}
	}
}