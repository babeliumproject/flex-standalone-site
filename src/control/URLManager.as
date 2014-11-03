package control
{
	//import events.ViewChangeEvent;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import model.DataModel;
	
	import mx.collections.ArrayCollection;
	import mx.events.BrowserChangeEvent;
	import mx.managers.BrowserManager;
	import mx.managers.IBrowserManager;
	import mx.utils.ObjectUtil;
	import mx.utils.StringUtil;
	import mx.utils.URLUtil;
	
	[Event(name="change", type="control.URLChangeEvent")]

	public class URLManager extends EventDispatcher
	{
		
		public static const DELIMITER:String="/";
		public static const TARGET_DELIMITER:String="&";

		public static var instance:URLManager=new URLManager();
		private var _isParsing:Boolean;
		private var _lastURL:String;
		private var _browserManager:IBrowserManager;


		private var _moduleUrls:Object = {
			exercises: 'modules/exercise/ExerciseModule.swf',
			course: 'modules/dashboard/CourseModule.swf',
			create: 'modules/create/CreateModule.swf',
			login: 'modules/login/LoginModule.swf',
			signup: 'modules/signup/SignupModule.swf',
			subtitle: 'modules/subtitle/SubtitleModule.swf',
			home: 'modules/home/HomeModule.swf'
		};

		[Bindable] public var moduleName:String;
		[Bindable] public var module:String;
		[Bindable] public var action:String;
		[Bindable] public var parameters:String;
		
		public var parsedParams:Object;

		/**
		 * Constructor
		 **/
		public function URLManager()
		{
			if (instance)
				throw new Error("BabeliaBrowserManager is already running");
		}

		// Get instance
		public static function getInstance():URLManager
		{
			return instance;
		}
		
		public function init():void{
			_browserManager=BrowserManager.getInstance();
			
			_browserManager.addEventListener(BrowserChangeEvent.URL_CHANGE, this.parseURL);
			_browserManager.addEventListener(BrowserChangeEvent.BROWSER_URL_CHANGE, this.parseURL);
			_browserManager.init();
			
			_isParsing=false;
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
			var modtmp:String='home';
			var actiontmp:String='index';
			var paramtmp:String;
			
			parsedParams=null;
			
			_isParsing=true;
			_lastURL=event ? event.lastURL : null;
			
			if(event && event.type == BrowserChangeEvent.BROWSER_URL_CHANGE){
				trace("Browser URL change: "+_browserManager.fragment);
			}else{
				trace("Programmatic URL change: "+_browserManager.fragment);
			}

			//Fixes a bug caused by email clients that escape url sequences
			var uescparams:String=unescape(_browserManager.fragment);

			var fragments:Array=uescparams.split(DELIMITER);
			var numfragments:Number=fragments.length;

			if (isNaN(numfragments) || numfragments <= 1)
				redirect('/home');

			if (numfragments > 1)
			{
				var tmp:String = fragments[1];
				for (var name:String in _moduleUrls){
					if(tmp == name){
						moduleName = name;
						modtmp=_moduleUrls[name];
						break;
					}
				}
				if(!modtmp) redirect('/home');
			}

			if (numfragments > 2)
			{
				actiontmp=fragments[2];
			}

			if (numfragments > 3)
			{
				paramtmp=fragments[3];
				var pattern:RegExp = /([^\?]*)\?(.+)?/;
				var matches:Array = paramtmp.match(pattern);
				if(matches){
					if(matches[2]){
						parsedParams = URLUtil.stringToObject(matches[2],'&',true);
					}
					if(matches[1]){
						parsedParams['id'] = matches[1];
					}
				}
			}

			module=modtmp;
			action=actiontmp;
			parameters=paramtmp;

			_isParsing=false;
			dispatchEvent(new URLChangeEvent(URLChangeEvent.CHANGE, false, false, moduleName, action, parsedParams));
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
		
		public function getParsedURL():Object{
			var urlobj:Object=new Object();
			urlobj.module = moduleName;
			urlobj.action = action;
			urlobj.parameters = parsedParams;
			return urlobj;
		}
		
		public function getModuleFileURL(modulename:String):String{
			var fileurl:String;
			for (var name:String in _moduleUrls){
				if(modulename == name){
					fileurl=_moduleUrls[name];
					break;
				}
			}
			return fileurl;
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