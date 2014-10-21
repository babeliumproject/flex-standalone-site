package control
{
	//import events.ViewChangeEvent;

	import flash.events.Event;
	
	import model.DataModel;
	
	import mx.collections.ArrayCollection;
	import mx.events.BrowserChangeEvent;
	import mx.managers.BrowserManager;
	import mx.managers.IBrowserManager;
	import mx.utils.ObjectUtil;
	import mx.utils.StringUtil;
	import mx.utils.URLUtil;


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
		public var module:String;
		[Bindable]
		public var action:String;
		[Bindable]
		public var parameters:String;

		/**
		 * Constructor
		 **/
		public function BabeliaBrowserManager()
		{
			if (instance)
				throw new Error("BabeliaBrowserManager is already running");

			_browserManager=BrowserManager.getInstance();
			
			_browserManager.addEventListener(BrowserChangeEvent.URL_CHANGE, this.parseURL);
			_browserManager.addEventListener(BrowserChangeEvent.BROWSER_URL_CHANGE, this.parseURL);
			_browserManager.init();

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
		 * Listens for changes in the fragment property of the BrowserManager and parses the fragment
		 * to notify all associated listeners of the degree of the change. The fragment property can be changed
		 * by either the browser or calls to the redirect() function.
		 * 
		 * @param e
		 * 
		 */		
		public function parseURL(event:BrowserChangeEvent=null):void
		{
			_isParsing=true;
			_lastURL=event ? event.lastURL : null;
			
			if(event && event.type == BrowserChangeEvent.BROWSER_URL_CHANGE){
				trace("Browser URL change: "+_browserManager.fragment);
			}else{
				trace("Programmatic URL change: "+_browserManager.fragment);
			}

			var modparam:String=null;
			var actionparam:String=null;
			var valueparam:String=null;

			//Fixes a bug caused by email clients that escape url sequences
			var uescparams:String=unescape(_browserManager.fragment);

			var fragments:Array=uescparams.split(DELIMITER);
			var numfragments:Number=fragments.length;

			if (isNaN(numfragments) || numfragments <= 1)
				redirect('/home');

			if (numfragments > 1)
			{ // module
				modparam=fragments[1];
				switch (modparam)
				{
					case 'exercises':
					{
						module='modules/exercise/ExerciseModule.swf';
						break;
					}
					case 'course':
					{
						module='modules/dashboard/CourseModule.swf';
						break;
					}
					case 'create':
					{
						module='modules/create/CreateModule.swf';
						break;
					}
					case 'login':
					{
						module='modules/login/LoginModule.swf';
						break;
					}
					case 'signup':
					{
						module='modules/signup/SignupModule.swf';
						break;
					}
					case 'subtitle':
					{
						module='modules/subtitle/SubtitleModule.swf';
						break;
					}
					default:
					{
						module='modules/home/HomeModule.swf';
						break;
					}
				}
			}

			if (numfragments > 2)
			{
				actionparam=fragments[2];
			}

			if (numfragments > 3)
			{
				valueparam=fragments[3];
				var pattern:RegExp = /[^\?]*\?(.+)/;
				var matches:Array = valueparam.match(pattern);
				if(matches && matches[1]){
					URLUtil.stringToObject(matches[1],'&',true);
				}
			}

			parameters=valueparam;
			action=actionparam;

			_isParsing=false;
		}

		public function redirect(url:String=null):void
		{
			var base:String = _browserManager.base + "#";
			trace("Base to remove: "+base);
			var turl:String = url;
			turl = turl.replace(base,'');
			turl = '/'+this.ltrim(turl,'/');
			_browserManager.setFragment(turl);
		}

		public function getLastURL():String
		{
			return _lastURL;
		}
		
		private function ltrim(str:String,character_mask:String):String{
			if (str == null) return '';
			
			var startIndex:int = 0;
			var endIndex:int = str.length - 1;
			while (character_mask === str.charAt(startIndex))
				++startIndex;
			
			if (endIndex >= startIndex)
				return str.slice(startIndex, endIndex + 1);
			else
				return "";
		}

	}
}