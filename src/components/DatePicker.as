package components
{
	import mx.controls.DateField;
	import mx.core.ITextInput;
	import mx.core.mx_internal;
	
	use namespace mx_internal;
	
	public class DatePicker extends DateField
	{
		public function DatePicker()
		{
			super();
		}
		
		override protected function measure():void{
			
			var buttonWidth:Number = downArrowButton.getExplicitOrMeasuredWidth();
			var buttonHeight:Number = downArrowButton.getExplicitOrMeasuredHeight();
			
			measuredMinWidth = measuredWidth = buttonWidth;
			measuredMinWidth = measuredWidth += getStyle("paddingLeft") + getStyle("paddingRight");
			measuredMinHeight = measuredHeight = buttonHeight;
			
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			textInput.visible=false;
			textInput.includeInLayout=false;
		}
	}
}