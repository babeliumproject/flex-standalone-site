package modules.userManagement
{
	import flash.geom.Point;
	
	import mx.controls.TextInput;
	import mx.controls.ToolTip;
	import mx.managers.ToolTipManager;
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;

	[ResourceBundle("myResources")]
	
	public class FieldValidator
	{
		// Variables
		public static var MAIL_PATTERN:RegExp=/^[a-zA-Z]\w+([.]\w+)*[@]\w+([.]\w+)*[.][a-zA-Z]{2,4}$/;
		//Only one @ and one or more non-@ characters at each side of it
		public static var MAIL_PATTERN_LAX:RegExp=/^[^@]+@[^@]+$/;
		public static var MAIL_PATTERN_LAX_NO_SPACE:RegExp=/^[^@ ]+@[^@ ]+$/;
		public static var FIELD_PATTERN:RegExp=/^[a-zA-Z_]\w*$/;
		public static var ANY_PATTERN:RegExp=/^\w*$/s;
		
		// Empty Constructor
		public function FieldValidator()
		{
			throw new Error("This class cannot be instantiated");
		}
		
		public static function validateTextInput(errorMessageToolTips:Array,
										   target:TextInput, fieldName:String, 
										   matchPattern:RegExp, checkEmpty:Boolean = true, 
										   checkLength:Boolean = true, checkPattern:Boolean = true, 
										   checkString:Boolean = false, minLength:int = 1, 
										   maxLength:int = 200, matchString:String=''):Boolean
		{
			var resourceManager:IResourceManager = ResourceManager.getInstance();
			// Has the error message ToolTip already been created?
			// (A reference to created ToolTip instances is saved in a hash called errorMessageToolTips.)
			var toolTipExists:Boolean=errorMessageToolTips.hasOwnProperty(target.name);
			var errorMessage:String='';
			
			if (toolTipExists)
			{
				trace("error corrected removing tooltip");
				ToolTipManager.destroyToolTip(errorMessageToolTips[target.name] as ToolTip);
				delete errorMessageToolTips[target.name];
			}
			
			if (checkEmpty && target.text == "")
			{
				errorMessage=resourceManager.getString("myResources", "EMPTY_"+fieldName.toUpperCase());
			}
			else if (checkLength && (target.text.length < minLength))
			{
				errorMessage=resourceManager.getString("myResources", "SHORT_"+fieldName.toUpperCase());
			}
			else if (checkLength && (target.text.length > maxLength))
			{
				errorMessage=resourceManager.getString("myResources", "LONG_"+fieldName.toUpperCase());
			}
			else if (checkPattern && (!matchPattern.test(target.text)))
			{
				errorMessage=resourceManager.getString("myResources", "INVALID_"+fieldName.toUpperCase());
			}
			else if (checkString && (target.text != matchString)){
				errorMessage=resourceManager.getString("myResources", "INVALID_"+fieldName.toUpperCase());
			}
			
			if (errorMessage != '')
			{
				// Create the ToolTip instance.
				var pt:Point=new Point(target.x, target.y);
				pt=target.contentToGlobal(pt);
				var errorTip:ToolTip=ToolTipManager.createToolTip(errorMessage, pt.x + target.width + 5, pt.y) as ToolTip;
				errorTip.setStyle("styleName", "errorTip");
				
				// Save a reference to the error message ToolTip in a hash for later use.
				errorMessageToolTips[target.name]=errorTip;
				(errorMessageToolTips[target.name] as ToolTip).visible=true;
				
				return false; //The filed has errors, so we return false
			} 
			else 
			{
				return true; //The field has valid input, so we return true
			}
		}
	}
}