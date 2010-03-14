package modules.extenders {
	// http://blog.strikefish.com/blog/index.cfm/2008/3/21/Flex-Smart-Combo-aka-look-ahead-combo
	import mx.controls.ComboBox;
	import flash.events.Event;
	
	public class ComboBoxEditable extends ComboBox {
		
		private var _inputText:String;
		
		public function ComboBoxEditable() {
			super();
			
		}
		
		override protected function textInput_changeHandler(event:Event):void {
			_inputText = this.textInput.text;
		}
		
		public function get inputText():String {
			return _inputText;
		}
		
	}
}