package skins
{
	import flash.events.MouseEvent;
	
	import mx.core.FlexGlobals;
	import mx.styles.CSSStyleDeclaration;
	
	import spark.components.ToggleButton;

	[Style(name="backgroundImage", type="*")]

	public class NavigationToggleButton extends ToggleButton
	{

		// Define a static variable.
		private static var classConstructed:Boolean=classConstruct();

		public function NavigationToggleButton()
		{
			super();
		}

		// Define a static method.
		private static function classConstruct():Boolean
		{
			if (!FlexGlobals.topLevelApplication.styleManager.getStyleDeclaration("skins.NavigationToggleButtonSkin"))
			{
				// If there is no CSS definition for StyledRectangle, 
				// then create one and set the default value.
				var navButtonStyles:CSSStyleDeclaration=new CSSStyleDeclaration();
				navButtonStyles.defaultFactory=function():void
				{
					this.icon='';
				}
				FlexGlobals.topLevelApplication.styleManager.setStyleDeclaration("skins.NavigationToggleButtonSkin", navButtonStyles, true);

			}
			return true;
		}


		// Define the flag to indicate that a style property changed.
		private var bStypePropChanged:Boolean=true;

		// Define the variable to hold the current icon path.
		private var backgroundPath:String;



		override public function styleChanged(styleProp:String):void
		{

			super.styleChanged(styleProp);

			// Check to see if style changed. 
			if (styleProp == "backgroundImage")
			{
				bStypePropChanged=true;
				invalidateDisplayList();
				return;
			}
		}

		override protected function clickHandler(event:MouseEvent):void
		{
		}


	}
}