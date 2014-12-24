package components.videoPlayer.controls
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;

	public class XMLSkinableComponent extends SkinableComponent
	{
		
		public static const XML_COMPONENT:String='Component';
		public static const XML_PROPERTY:String='Property';
		public static const XML_NAME:String='name';
		
		protected var _skinableComponents:Dictionary;
		protected var _skinUrl:String;
		protected var _skinLoader:URLLoader;
		protected var _loadingSkin:Boolean;
		
		private var skinUrlChanged:Boolean;
		
		[Bindable("skinUrlChanged")]
		
		public function XMLSkinableComponent(name:String="SkinableComponent")
		{
			super(name);
			_skinableComponents = new Dictionary();
		}
		
		/**
		 * Skin HashMap related commands
		 */
		protected function putSkinableComponent(name:String, cmp:SkinableComponent):void
		{
			_skinableComponents[name]=cmp;
		}
		
		protected function getSkinableComponent(name:String):SkinableComponent
		{
			return _skinableComponents[name];
		}
		
		public function set skinUrl(value:String):void
		{
			if (skinUrl === value)
				return;
			_skinUrl=value;
			skinUrlChanged=true;
			
			dispatchEvent(new Event("skinUrlChanged"));
			
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
				var cmp:SkinableComponent=getSkinableComponent(componentName);
				
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
			invalidateDisplayList();
		}
		
		protected function onSkinFileReadingError(e:IOErrorEvent):void
		{
			_loadingSkin=false;
			trace("Error ["+e.errorID+"] "+e.text);
		}
	}
}