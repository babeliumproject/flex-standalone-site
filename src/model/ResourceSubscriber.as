package model
{
	import flash.events.Event;
	
	import mx.core.IVisualElement;
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	import mx.resources.ResourceManager;

	public class ResourceSubscriber
	{
		
		private static var instance:ResourceSubscriber;
		
		private var subscribedElements:Array;
		
		public static function getInstance():ResourceSubscriber
		{
			if(!instance){
				instance = new ResourceSubscriber();
			}
			return instance;
		}
		
		public function ResourceSubscriber()
		{
			if(!instance)
				ResourceManager.getInstance().addEventListener(Event.CHANGE, onLocaleChainChange);
		}
		
		public function onLocaleChainChange(e:Event):void
		{
			for each(var item:Object in subscribedElements){
				var element:UIComponent = item.element as UIComponent;
				var property:String = item.property as String;
				var resourceBundle:String = item.resourceBundle as String;
				var resourceName:String = item.resourceName as String;
				element[property] = ResourceManager.getInstance().getString(resourceBundle,resourceName);
			}
		}
		
		/**
		 * Subscribes a visual element's public property to the locale changes in the ResourceManager.
		 * Only one property can be subscribed for each element.
		 * 
		 * @param element
		 * 		A visual element that needs to be notified of a locale change in the ResourceManager
		 * @param property
		 * 		The public property of the visual element that should be affected by the locale change
		 * @param resourceBundle
		 * 		Which resource bundle should have the localized resource for this element
		 * @param resourceName
		 * 		The name of the localized resource inside a resource bundle
		 * @return 
		 * 		True if the element was added to the subscriber list. False otherwise.
		 */		
		public function subscribeElement(element:UIComponent, property:String, resourceBundle:String, resourceName:String):Boolean
		{
			if(element.hasOwnProperty(property) && ResourceManager.getInstance().getResourceBundle("en_US",resourceBundle)){
				var subscriber:Object = new Object();
				subscriber.element = element;
				subscriber.property = property;
				subscriber.resourceBundle = resourceBundle;
				subscriber.resourceName = resourceName;
				if(!subscribedElements)
					subscribedElements = new Array();
				if(findSubscribedElement(element) == -1)
					subscribedElements.push(subscriber);
				return true;
			} else {
				return false;
			}
		}
		
		public function unsubscribeElement(element:IVisualElement):Boolean
		{
			var removed:Boolean=false;
			for (var index:Object in subscribedElements){
				var subscribedElement:UIComponent = subscribedElements[index as Number].element as UIComponent;
				if(subscribedElement == element){
					delete subscribedElements[index as Number];
					removed=true;
					//trace("Deleted the element with index "+index+" and id "+subscribedElement.id);
					break;
				}
			}
			return removed;
		}
		
		public function unsubscribeContainerElements(container:IVisualElementContainer):void
		{
			if(container.numElements){
				for(var i:uint; i<container.numElements; i++){
					unsubscribeElement(container.getElementAt(i));
				}
			}
		}
		
		private function findSubscribedElement(element:UIComponent):int{
			var index:int=-1;
			for (var i:Object in subscribedElements){
				var subscribedElement:UIComponent = subscribedElements[i as int].element as UIComponent;
				if(subscribedElement == element){
					index=i as int;
					break;
				}
			}
			return index;
		}
	}
}