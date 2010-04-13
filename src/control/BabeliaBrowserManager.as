package control
{
	import events.ViewChangeEvent;
	
	import flash.events.Event;
	
	import model.DataModel;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.events.BrowserChangeEvent;
	import mx.managers.BrowserManager;
	import mx.managers.IBrowserManager;
	
	
	/**
	 * Default URL Format: http://babelia/#/module/action/target
	 */
	public class BabeliaBrowserManager
	{
		/** Constants **/
		public static const DELIMITER:String="/";
		
		/** Variables **/
		public static var instance:BabeliaBrowserManager = new BabeliaBrowserManager();
		private var _isParsing:Boolean;
		private var _browserManager:IBrowserManager;
		
		/**
		 * URL Related Constants
		 **/
		private var _modulesFragments:ArrayCollection;
		
		/**
		 * Constructor
		 **/
		public function BabeliaBrowserManager()
		{	
			if ( instance )
				throw new Error("BabeliaBrowserManager is already running");
			
			_browserManager = BrowserManager.getInstance();
			_browserManager.init();
			_browserManager.addEventListener(BrowserChangeEvent.BROWSER_URL_CHANGE, parseURL);
			
			_isParsing = false;
			
			// viewstack-> url href
			_modulesFragments = new ArrayCollection();
			
			// fill array
			for ( var i:int = 0; i < 11; i++ )
				_modulesFragments.addItem(null);
			
			_modulesFragments.setItemAt("about", ViewChangeEvent.VIEWSTACK_ABOUT_MODULE_INDEX);
			_modulesFragments.setItemAt("account", ViewChangeEvent.VIEWSTACK_ACCOUNT_MODULE_INDEX);
			_modulesFragments.setItemAt("config", ViewChangeEvent.VIEWSTACK_CONFIGURATION_MODULE_INDEX);
			_modulesFragments.setItemAt("evaluation", ViewChangeEvent.VIEWSTACK_EVALUATION_MODULE_INDEX);
			_modulesFragments.setItemAt("exercises", ViewChangeEvent.VIEWSTACK_EXERCISE_MODULE_INDEX);
			_modulesFragments.setItemAt("home", ViewChangeEvent.VIEWSTACK_HOME_MODULE_INDEX);
			_modulesFragments.setItemAt("register", ViewChangeEvent.VIEWSTACK_REGISTER_MODULE_INDEX);
			_modulesFragments.setItemAt("search", ViewChangeEvent.VIEWSTACK_SEARCH_MODULE_INDEX);
			_modulesFragments.setItemAt("upload", ViewChangeEvent.VIEWSTACK_UPLOAD_MODULE_INDEX);
		}
		
		// Get instance
		public static function getInstance() : BabeliaBrowserManager
		{
			return instance;
		}
		
		/**
		 * Parse function
		 **/
		public function parseURL(e:Event = null) : void
		{
			_isParsing = true;
			
			var params:Array = _browserManager.fragment.split(DELIMITER);
			var length:Number = params.length;
			
			if ( length <= 1 )
				updateURL(index2fragment(ViewChangeEvent.VIEWSTACK_HOME_MODULE_INDEX));
			
			if ( length > 1 ) // module
			{
				changeModule(params[1]);
			}
			
			if ( length > 2 ) // action
			{
				
			}
			
			if ( length > 3 ) // target
			{
				
			}
			
			_isParsing = false;
		}
		
		
		/**
		 * Update URL function
		 **/
		public function updateURL(module:String, action:String = null, target:String = null) : void
		{
			// default url format: /module/action/target
			
			if ( action == null )
				_browserManager.setFragment(DELIMITER+module+DELIMITER);
			else if ( target == null )
				_browserManager.setFragment(DELIMITER+module+DELIMITER+action+DELIMITER);
			else
				_browserManager.setFragment(DELIMITER+module+DELIMITER+action+DELIMITER+target+DELIMITER);
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
		private function changeModule(module:String) : void
		{
			var index:int = _modulesFragments.getItemIndex(module);
			
			if ( index >= 0 )
				DataModel.getInstance().viewContentViewStackIndex = index;
		}
		
	}
}