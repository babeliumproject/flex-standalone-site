package components
{
	import mx.core.mx_internal;
	
	import spark.utils.LabelUtil;
	
	use namespace mx_internal;
	
	public class UserDropDownList extends EnhancedDropDownList
	{
		public function UserDropDownList()
		{
			super();
		}
		
		override mx_internal function updateLabelDisplay(displayItem:* = undefined):void{
			if (labelDisplay)
			{
				labelDisplay.text = prompt;
			}
		}
	}
}