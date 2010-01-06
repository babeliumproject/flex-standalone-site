package modules.videoPlayer.controls
{
	import mx.controls.Alert;
	import mx.core.UIComponent;
	import mx.utils.ObjectUtil;
	import flash.utils.Dictionary;

	public class SkinableComponent extends UIComponent
	{
		private var skinColors:Dictionary;
		public var COMPONENT_NAME:String;
		
		public function SkinableComponent(name:String = "SkinableComponent" )
		{
			super();
			COMPONENT_NAME = name;
			skinColors = new Dictionary();
		}
		
		/**
		 * Shows available propertys
		 */
		public function availableProperties(obj:Array = null) : void
		{
			Alert.show(ObjectUtil.toString(obj));
		}
		
		/**
		 * Sets color for a skinProperty
		 */
		public function setSkinColor(propertyName:String, color:uint) : void
		{
			skinColors[propertyName] = color;
			//Alert.show(COMPONENT_NAME + ": " + color);
		}
		
		/**
		 * Gets color from a skinProperty
		 */
		public function getSkinColor(propertyName:String) : uint
		{
			return skinColors[propertyName] as uint;
		}
		
		public function refresh() : void
		{
			updateDisplayList(0,0);
		}
		
	}
}