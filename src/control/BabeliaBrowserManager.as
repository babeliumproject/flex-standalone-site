package control
{
	//import events.ViewChangeEvent;
	
	import model.DataModel;
	
	import mx.collections.ArrayCollection;
	import mx.events.BrowserChangeEvent;
	import mx.managers.BrowserManager;
	import mx.managers.IBrowserManager;
	import mx.utils.ObjectUtil;
	
	
	/**
	 * Default URL Format: http://babelia/#/module/action/target
	 */
	public class BabeliaBrowserManager
	{
		/** Constants **/
		public static const DELIMITER:String="/";
		public static const TARGET_DELIMITER:String="&";
		
		/** Variables **/
		public static var instance:BabeliaBrowserManager = new BabeliaBrowserManager();
		private var _isParsing:Boolean;
		private var _lastURL:String;
		private var _browserManager:IBrowserManager;
		
		/**
		 * URL Related Constants
		 **/
		private var _modulesFragments:ArrayCollection;
		
		[Bindable] public var moduleIndex:int;
		[Bindable] public var moduleName:String;
		[Bindable] public var moduleURL:String;
		[Bindable] public var actionFragment:String;
		[Bindable] public var targetFragment:String;
		
		/**
		 * ACTION CONSTANTS
		 **/
		public static const LEARN:String="learn";
		public static const TEACH:String="teach";
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
			if ( instance )
				throw new Error("BabeliaBrowserManager is already running");
			
			_browserManager = BrowserManager.getInstance();
			_browserManager.init();
			_browserManager.addEventListener(BrowserChangeEvent.URL_CHANGE, parseURL);
			//_browserManager.addEventListener(BrowserChangeEvent.APPLICATION_URL_CHANGE, urlchanged);
			//_browserManager.addEventListener(BrowserChangeEvent.BROWSER_URL_CHANGE, urlchanged);
			//_browserManager.addEventListener(BrowserChangeEvent.URL_CHANGE, urlchanged);
			
			_isParsing = false;
			
			// viewstack-> url href
			_modulesFragments = new ArrayCollection();
			
			// fill array
			for ( var i:int = 0; i < 20; i++ )
				_modulesFragments.addItem(null);
			/*
			_modulesFragments.setItemAt("about", ViewChangeEvent.VIEWSTACK_ABOUT_MODULE_INDEX);
			_modulesFragments.setItemAt("account", ViewChangeEvent.VIEWSTACK_ACCOUNT_MODULE_INDEX);
			_modulesFragments.setItemAt("config", ViewChangeEvent.VIEWSTACK_CONFIGURATION_MODULE_INDEX);
			_modulesFragments.setItemAt("evaluation", ViewChangeEvent.VIEWSTACK_EVALUATION_MODULE_INDEX);
			_modulesFragments.setItemAt("exercises", ViewChangeEvent.VIEWSTACK_EXERCISE_MODULE_INDEX);
			_modulesFragments.setItemAt("home", ViewChangeEvent.VIEWSTACK_HOME_MODULE_INDEX);
			_modulesFragments.setItemAt("register", ViewChangeEvent.VIEWSTACK_REGISTER_MODULE_INDEX);
			_modulesFragments.setItemAt("search", ViewChangeEvent.VIEWSTACK_SEARCH_MODULE_INDEX);
			_modulesFragments.setItemAt("upload", ViewChangeEvent.VIEWSTACK_UPLOAD_MODULE_INDEX);
			_modulesFragments.setItemAt("help", ViewChangeEvent.VIEWSTACK_HELP_MODULE_INDEX);
			_modulesFragments.setItemAt("activation", ViewChangeEvent.VIEWSTACK_ACTIVATION_MODULE_INDEX);
			_modulesFragments.setItemAt("subtitles", ViewChangeEvent.VIEWSTACK_SUBTITLE_MODULE_INDEX);
			_modulesFragments.setItemAt("course", ViewChangeEvent.VIEWSTACK_COURSE_MODULE_INDEX);
			_modulesFragments.setItemAt("login", ViewChangeEvent.VIEWSTACK_LOGIN_MODULE_INDEX);*/
			
			_modulesFragments.setItemAt("about", 8);
			_modulesFragments.setItemAt("account", 4);
			_modulesFragments.setItemAt("config", 7);
			_modulesFragments.setItemAt("evaluation", 2);
			_modulesFragments.setItemAt("exercises", 1);
			_modulesFragments.setItemAt("home", 0);
			_modulesFragments.setItemAt("register", 3);
			_modulesFragments.setItemAt("search", 9);
			_modulesFragments.setItemAt("upload", 5);
			_modulesFragments.setItemAt("help", 10);
			_modulesFragments.setItemAt("activation", 11);
			_modulesFragments.setItemAt("subtitles", 6);
			_modulesFragments.setItemAt("course", 12);
			_modulesFragments.setItemAt("login", 13);
			
		}
		
		// Get instance
		public static function getInstance() : BabeliaBrowserManager
		{
			return instance;
		}
		
		public function urlchanged(event:BrowserChangeEvent=null):void{
			_lastURL = event ? event.lastURL : null;
			trace("Last url: "+_lastURL);
			trace("Event Object: "+ObjectUtil.toString(event));
			trace("Module ID: "+this.moduleIndex);
		}
		
		public function addBrowserChangeListener(listenerFunction:Function):void{
			_browserManager.addEventListener(BrowserChangeEvent.BROWSER_URL_CHANGE, listenerFunction);
		}
		
		public function removeBrowseChangeListener(listenerFunction:Function):void{
			_browserManager.removeEventListener(BrowserChangeEvent.BROWSER_URL_CHANGE, listenerFunction);
		}
		
		/**
		 * Parse function
		 **/
		public function parseURL(e:BrowserChangeEvent = null) : void
		{
			_isParsing = true;
			_lastURL = e ? e.lastURL : null;
			
			clearFragments();
			
			//Fixes a bug caused by email clients that escape url sequences
			var uescparams:String = unescape(_browserManager.fragment);
			
			var params:Array = uescparams.split(DELIMITER);
			var length:Number = params.length;
			
			if ( length <= 1 )
				//updateURL(index2fragment(ViewChangeEvent.VIEWSTACK_HOME_MODULE_INDEX));
				updateURL('home');
			
			if ( length > 1 ){ // module
				
				//if ( !changeModule(params[1]) ) return;
				var modulefragment:String = params[1];
				switch(modulefragment)
				{
					case 'exercises':
					{
						moduleURL = 'modules/exercise/ExerciseModule.swf';
						break;
					}
					case 'course':
					{
						moduleURL = 'modules/course/CourseModule.swf';
						break;
					}
					default:
					{
						moduleURL = 'modules/home/HomeModule.swf';
						break;
					}
				}
				
				
			}
			
			if ( length > 2 ) // action
				actionFragment = params[2];
			
			if ( length > 3 ) // target
				targetFragment = params[3];
			
			_isParsing = false;
		}
		
		
		/**
		 * Update URL function
		 **/
		public function updateURL(module:String, action:String = null, target:String = null) : void
		{
			// default url format: /module/action/target
			
			clearFragments();
			
			if ( action == null )
				_browserManager.setFragment(DELIMITER+module);
			else if ( target == null )
				_browserManager.setFragment(DELIMITER+module+DELIMITER+action);
			else
				_browserManager.setFragment(DELIMITER+module+DELIMITER+action+DELIMITER+target);
		}
		
		
		/**
		 * From index to fragment
		 **/
		public static function index2fragment(index:int) : String
		{
			return instance._modulesFragments.getItemAt(index) as String;
		}
		
		
		/**
		 * Change module
		 **/
		private function changeModule(module:String) : Boolean
		{
			moduleIndex = _modulesFragments.getItemIndex(module);
			
			if ( moduleIndex == 4 && !DataModel.getInstance().isLoggedIn )
			{
				DataModel.getInstance().currentContentViewStackIndex = 0;
				updateURL("home");
			}
			
			if ( moduleIndex >= 0 )
			{
				DataModel.getInstance().currentContentViewStackIndex = moduleIndex;
				trace("Current content viewstack index: "+DataModel.getInstance().currentContentViewStackIndex);
				return true;
			}
			
			return false;
		}
		
		
		/**
		 * Clear Fragments
		 **/
		private function clearFragments() : void
		{
			moduleIndex = -1;
			actionFragment = null;
			targetFragment = null;
		}
	}
}