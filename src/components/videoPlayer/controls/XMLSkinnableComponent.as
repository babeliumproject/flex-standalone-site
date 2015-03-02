package components.videoPlayer.controls
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import components.videoPlayer.events.XMLSkinnableComponentEvent;

	public class XMLSkinnableComponent extends DictionarySkinnableComponent
	{
		public static const XML_COMPONENT:String='Component';
		public static const XML_PROPERTY:String='Property';
		public static const XML_NAME:String='name';
		
		//Don't use Dictionary unless the keys are objects
		protected var _skinableComponents:Object;
		protected var _skinUrl:String;
		protected var _skinLoader:URLLoader;
		protected var _loadingSkin:Boolean;
		
		private var skinUrlChanged:Boolean;
		
		public function XMLSkinnableComponent(name:String="DictionarySkinnableComponent")
		{
			super(name);
			_skinableComponents = new Object();
		}
		
		override public function dispose():void{
			super.dispose();
			if(_skinLoader){
				_skinLoader.removeEventListener(Event.COMPLETE, onSkinFileRead);
				_skinLoader.removeEventListener(IOErrorEvent.IO_ERROR, onSkinFileReadingError);
			}
			_skinLoader=null;
			_skinableComponents=null;
		}
		
		/**
		 * Skin HashMap related commands
		 */
		protected function putSkinableComponent(name:String, cmp:DictionarySkinnableComponent):void
		{
			_skinableComponents[name]=cmp;
		}
		
		protected function getSkinableComponent(name:String):DictionarySkinnableComponent
		{
			return _skinableComponents[name];
		}
		
		public function set skinUrl(value:String):void
		{
			if (skinUrl === value)
				return;
			_skinUrl=value;
			skinUrlChanged=true;
			
			dispatchEvent(new XMLSkinnableComponentEvent(XMLSkinnableComponentEvent.SKIN_FILE_URL_CHANGED));
			loadSkinFile(_skinUrl);
		}
		
		public function get skinUrl():String
		{
			return _skinUrl;
		}
		
		protected function loadSkinFile(skinFileUrl:String):void
		{			
			var xmlURL:URLRequest=new URLRequest(skinFileUrl);
			_skinLoader=new URLLoader(xmlURL);
			_skinLoader.addEventListener(Event.COMPLETE, onSkinFileRead, false, 0, true);
			_skinLoader.addEventListener(IOErrorEvent.IO_ERROR, onSkinFileReadingError, false, 0, true);
			_loadingSkin=true;
		}
		
		protected function onSkinFileRead(e:Event):void
		{
			var xml:XML=new XML(_skinLoader.data);
			
			for each (var xChild:XML in xml.child(XML_COMPONENT))
			{
				var componentName:String=xChild.attribute(XML_NAME).toString();
				var cmp:DictionarySkinnableComponent=getSkinableComponent(componentName);
				
				if (cmp == null)
					continue;
				for each (var xElement:XML in xChild.child(XML_PROPERTY))
				{
					var propertyName:String=xElement.attribute(XML_NAME).toString();
					var propertyValue:String=xElement.toString();
					cmp.setSkinProperty(propertyName, propertyValue);
				}
			}
			_loadingSkin=false;
			
			dispatchEvent(new XMLSkinnableComponentEvent(XMLSkinnableComponentEvent.SKIN_FILE_LOADED));
			invalidateDisplayList();
		}
		
		protected function onSkinFileReadingError(e:IOErrorEvent):void
		{
			_loadingSkin=false;
			dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR,false,false,e.text,e.errorID));
			trace("Error ["+e.errorID+"] "+e.text);
		}
	}
}