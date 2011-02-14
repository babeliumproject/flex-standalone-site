package view
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	
	import mx.controls.NumericStepper;
	import mx.events.FlexEvent;
	import mx.formatters.Formatter;
	import mx.core.mx_internal;
	use namespace mx_internal;
	
	public class FormattedStepper extends NumericStepper {
		// formatter
		private var _formatter:Formatter;
		
		public function FormattedStepper() {
			super();
		}
		
		override protected function createChildren():void {
			super.createChildren();
			
			// un-restrict text input and set initial format
			mx_internal::inputField.restrict = null;
			doFormat();
			
			// event listeners
			addEventListener(FlexEvent.VALUE_COMMIT, doFormat);
			addEventListener(FocusEvent.FOCUS_OUT, doFormat);
			mx_internal::nextButton.addEventListener(MouseEvent.CLICK, doFormat);
			mx_internal::prevButton.addEventListener(MouseEvent.CLICK, doFormat);
			mx_internal::inputField.addEventListener(MouseEvent.CLICK, unFormat);
		}
		
		private function doFormat(event:Event = null):void {
			if (_formatter) mx_internal::inputField.text = _formatter.format(value);
		}
		
		private function unFormat(event:Event = null):void {
			if (_formatter) mx_internal::inputField.text = String(value);
		}
		
		public function set formatter(formatter:Formatter):void {
			_formatter = formatter;
			doFormat();
		}
	}
}