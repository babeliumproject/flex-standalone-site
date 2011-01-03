package skins
{
	import mx.core.FlexGlobals;
	import mx.styles.CSSStyleDeclaration;
	
	import spark.components.ButtonBarButton;
	
	[Style(name="icon", type="*")]
	
	[Style(name="isCorrectAnimate", type="Boolean")]
	
	[Style(name="isWrongAnimate", type="Boolean")]
	
	[Style(name="resetCorrectWrongStatus", type="Boolean")]
	
	public class IconButtonBarButton extends ButtonBarButton
	{
		
		// Define a static variable.
		private static var classConstructed:Boolean=classConstruct();
		
		public function IconButtonBarButton()
		{
			super();
		}
		
		// Define a static method.
		private static function classConstruct():Boolean
		{
			if (!FlexGlobals.topLevelApplication.styleManager.getStyleDeclaration("skins.IconButtonBarButton"))
			{
				// If there is no CSS definition for StyledRectangle, 
				// then create one and set the default value.
				var iconButtonStyles:CSSStyleDeclaration=new CSSStyleDeclaration();
				iconButtonStyles.defaultFactory=function():void
				{
					this.icon='';
				}
				FlexGlobals.topLevelApplication.styleManager.setStyleDeclaration("skins.IconButtonBarButton", iconButtonStyles, true);
				
			}
			return true;
		}
		
		
		// Define the flag to indicate that a style property changed.
		private var bStypePropChanged:Boolean=true;
		
		// Define the variable to hold the current icon path.
		private var iconPath:String;
		
		
		
		override public function styleChanged(styleProp:String):void
		{
			
			super.styleChanged(styleProp);
			
			// Check to see if style changed. 
			if (styleProp == "icon")
			{
				bStypePropChanged=true;
				invalidateDisplayList();
				return;
			}
		}
		
	}
}