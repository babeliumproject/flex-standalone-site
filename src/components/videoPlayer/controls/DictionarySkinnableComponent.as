package components.videoPlayer.controls
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;

	import mx.core.UIComponent;
	import mx.utils.ObjectUtil;

	import components.IDisposableObject;

	/**
   *  The DictionarySkinnableComponent class is the base class for all dictionary-based
		*  skinnable components. Subclasses must override the methods to add their own skin
	 *  properties to the dictionary.
	 *
	 */
	public class DictionarySkinnableComponent extends UIComponent implements IDisposableObject
	{
		private var _skinProperties:Object;
		public var COMPONENT_NAME:String;

		public function DictionarySkinnableComponent(name:String="DictionarySkinnableComponent")
		{
			super();
			COMPONENT_NAME=name;
			_skinProperties=new Object();
		}

		/**
		 * Disposes any object that could remain pinned to the memory and therefore not get
		 * marked to be collected when the garbage collector is called.
		 *
		 * Override this method in subclasses to remove any possible memory pinnings,
		 * such as: event listeners, binded setters, binded properties or dictionaries.
		 */
		public function dispose():void
		{
			_skinProperties=null;
		}

		/**
		 * Removes the specified child DisplayObject instance from the child list of the DisplayObjectContainer instance.
		 * If the child parameter is not a child of this object nothing is removed and the error is suppressed.
		 *
		 * @param child
		 */
		protected function removeChildSuppressed(child:DisplayObject):void
		{
			try
			{
				if (child)
				{
					this.removeChild(child);
				}
			}
			catch (error:ArgumentError)
			{
				//Suppress error
			}
		}

		/**
		 * Shows available propertys
		 */
		public function availableProperties(obj:Array=null):void
		{
			trace(ObjectUtil.toString(obj));
		}

		/**
		 * Sets color for a skinProperty
		 */
		public function setSkinProperty(name:String, value:String):void
		{
			_skinProperties[name]=value;
		}

		/**
		 * Gets color from a skinProperty
		 */
		public function getSkinColor(propertyName:String):uint
		{
			if (!_skinProperties)
				return 0;

			if (!_skinProperties.hasOwnProperty(propertyName))
				return 0;

			return new uint(_skinProperties[propertyName]);
		}

		/**
		 * Returns the value of a property of this skin
		 */
		public function getSkinProperty(name:String):String
		{
			if (!_skinProperties)
				return null;

			if (!_skinProperties.hasOwnProperty(name))
				return null;

			return _skinProperties[name];
		}

		public function refresh():void
		{
			//updateDisplayList(0,0);
			invalidateDisplayList();
		}

	}
}
