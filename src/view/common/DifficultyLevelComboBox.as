package view.common
{
	import flash.events.Event;
	
	import mx.controls.ComboBox;
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
	
	public class DifficultyLevelComboBox extends ComboBox
	{
		
		[Bindable]
		private var difficultyLevels:Array=new Array('LEVEL_A1', 'LEVEL_A2', 'LEVEL_B1', 'LEVEL_B2', 'LEVEL_C1');
		
		private var _prefixedLevel:uint;
		
		public function DifficultyLevelComboBox()
		{
			super();
			this.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
		}
		
		private function onCreationComplete(event:FlexEvent):void{
			this.setStyle('fontWeight', 'normal');
			this.dataProvider=difficultyLevels;
			this.labelFunction=difficultyComboBoxLabelFunction;
			this.addEventListener(ListEvent.CHANGE, difficultyComboBoxChangeHandler);
		}
		
		// Localization combobox functions
		private function difficultyComboBoxLabelFunction(item:Object):String
		{
			var locale:String=String(item);
			return resourceManager.getString('myResources', locale);
		}
		
		private function difficultyComboBoxChangeHandler(event:Event):void
		{
			updateDifficultyLevelComboBox();
		}
		
		private function updateDifficultyLevelComboBox():void
		{
			var oldSelectedItem:Object=this.selectedItem;
			// Repopulate the combobox with locales
			this.dataProvider=difficultyLevels;
			this.selectedItem=oldSelectedItem;
		}
		
		public function set prefixedLevel(level:uint):void{
			_prefixedLevel = level;
		}
		
		public function get prefixedLevel():uint{
			return _prefixedLevel;
		}
		
	}
}