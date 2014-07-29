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
		public static var instance:BabeliaBrowserManager=new BabeliaBrowserManager();
		private var _isParsing:Boolean;
		private var _lastURL:String;
		private var _browserManager:IBrowserManager;

		/**
		 * URL Related Constants
		 **/
		private var _modulesFragments:ArrayCollection;

		[Bindable]
		public var moduleIndex:int;
		[Bindable]
		public var moduleName:String;
		[Bindable]
		public var moduleURL:String;
		[Bindable]
		public var actionFragment:String;
		[Bindable]
		public var targetFragment:String;

		/**
		 * Constructor
		 **/
		public function BabeliaBrowserManager()
		{
			if (instance)
				throw new Error("BabeliaBrowserManager is already running");

			_browserManager=BrowserManager.getInstance();
			_browserManager.init();
			_browserManager.addEventListener(BrowserChangeEvent.URL_CHANGE, parseURL);

			_isParsing=false;
		}

		// Get instance
		public static function getInstance():BabeliaBrowserManager
		{
			return instance;
		}

		public function addBrowserChangeListener(listenerFunction:Function):void
		{
			_browserManager.addEventListener(BrowserChangeEvent.BROWSER_URL_CHANGE, listenerFunction);
		}

		public function removeBrowseChangeListener(listenerFunction:Function):void
		{
			_browserManager.removeEventListener(BrowserChangeEvent.BROWSER_URL_CHANGE, listenerFunction);
		}

		/**
		 * Parse function
		 **/
		public function parseURL(e:BrowserChangeEvent=null):void
		{
			_isParsing=true;
			_lastURL=e ? e.lastURL : null;

			var modparam:String=null;
			var actionparam:String=null;
			var valueparam:String=null;

			//Fixes a bug caused by email clients that escape url sequences
			var uescparams:String=unescape(_browserManager.fragment);

			var params:Array=uescparams.split(DELIMITER);
			var length:Number=params.length;

			if (length <= 1)
				redirect('home');

			if (length > 1)
			{ // module
				modparam=params[1];
				switch (modparam)
				{
					case 'exercises':
					{
						moduleURL='modules/exercise/ExerciseModule.swf';
						break;
					}
					case 'course':
					{
						moduleURL='modules/dashboard/CourseModule.swf';
						break;
					}
					case 'create':
					{
						moduleURL='modules/create/CreateModule.swf';
						break;
					}
					case 'login':
					{
						moduleURL='modules/login/LoginModule.swf';
						break;
					}
					case 'signup':
					{
						moduleURL='modules/signup/SignupModule.swf';
					}
					case 'subtitle':
					{
						moduleURL='modules/subtitle/SubtitleModule.swf';
					}
					default:
					{
						moduleURL='modules/home/HomeModule.swf';
						break;
					}
				}
			}

			if (length > 2)
			{
				actionparam=params[2];
			}

			if (length > 3) // target
				valueparam=params[3];

			targetFragment=valueparam;
			actionFragment=actionparam;

			_isParsing=false;
		}


		/**
		 * Update URL function
		 **/
		public function redirect(module:String, action:String=null, target:String=null):void
		{
			// default url format: /module/action/target

			//clearFragments();

			var url:String;
			if(!url)
				return;
			
			//Absolute URL, take into account for module change
			if (url.indexOf('/') == 0)
			{

			} else { //Relative url, change within the current module

			}

			if (action == null)
				_browserManager.setFragment(DELIMITER + module);
			else if (target == null)
				_browserManager.setFragment(DELIMITER + module + DELIMITER + action);
			else
				_browserManager.setFragment(DELIMITER + module + DELIMITER + action + DELIMITER + target);

			trace("BrowserManager current fragment: " + _browserManager.fragment);
		}

		public function getLastURL():String
		{
			return _lastURL;
		}

	}
}