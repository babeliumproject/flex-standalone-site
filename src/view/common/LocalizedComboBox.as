package view.common
{
	import flash.events.Event;
	
	import mx.controls.ComboBox;
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
	import mx.resources.ResourceManager;
	
	import spark.globalization.SortingCollator;
	
	public class LocalizedComboBox extends ComboBox
	{
		
		private var _displayPrompt:Boolean = true;
		private var _creationComplete:Boolean=false;
		private var _useCustomDataProvider:Boolean=false;
		private var _currentDataProvider:Array = new Array();
		private var _prefixedValue:Object;
		private var sorter:SortingCollator = new SortingCollator();
		
		public function LocalizedComboBox()
		{
			super();
			this.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
			ResourceManager.getInstance().addEventListener(Event.CHANGE, onLocaleChainChange);
		}
		
		public function onCreationComplete(event:FlexEvent):void
		{
			_creationComplete=true;
			
			this.setStyle('fontWeight', 'normal');
			
			this.labelFunction=localizedComboBoxLabelFunction;
			this.addEventListener(ListEvent.CHANGE, languageComboBoxChangeHandler);
			
			if(_displayPrompt){
				this.prompt=ResourceManager.getInstance().getString('myResources', 'PROMPT_SELECT_LANGUAGE');
			}
			updateLocalizedComboBox();
		}
		
		public function onLocaleChainChange(e:Event):void
		{
			updateLocalizedComboBox();	
		}
		
		public function set useCustomDataProvider(value:Boolean):void
		{
			_useCustomDataProvider=value;
		}
		
		public function set displayPrompt(value:Boolean):void{
			_displayPrompt = value;
		}
		
		public function set customDataProvider(data:Array):void
		{
			var newData:Array=new Array();
			for (var i:int=0; i < data.length; i++)
			{
				var comboitem:Object={'code':i,'label':ResourceManager.getInstance().getString('myResources',data[i])};
				if (comboitem)
					newData.push(comboitem);
			}
			_currentDataProvider=newData;
			if (_useCustomDataProvider && _creationComplete)
				this.dataProvider=null;
			this.dataProvider=_currentDataProvider;
		}
		
		// Custom ComboBox functions
		public function localizedComboBoxLabelFunction(item:Object):String
		{
			var rawlabel:String=String(item.label);
			var upperlabel:String=rawlabel.toUpperCase();
			return resourceManager.getString('myResources', upperlabel);
		}
		
		public function languageComboBoxChangeHandler(event:Event):void
		{
			updateLocalizedComboBox();
		}
		
		private function localeCompareFunction(item1:Object, item2:Object):int
		{
			var language1:String=localizedComboBoxLabelFunction(item1);
			var language2:String=localizedComboBoxLabelFunction(item2);
			
			
			sorter.setStyle('locale',resourceManager.localeChain[0]);
			sorter.ignoreCase=true;
			return sorter.compare(language1,language2);
			//return language1.localeCompare(language2);
		}
		
		private function updateLocalizedComboBox(value:Boolean=true):void
		{
			if(_displayPrompt)
				this.prompt = ResourceManager.getInstance().getString('myResources', 'PROMPT_SELECT_LANGUAGE');
			if (_currentDataProvider.length > 0)
			{
				var oldSelectedItem:Object=this.selectedItem;
				// Repopulate the combobox with locales,
				// re-sorting by localized language name.
				_currentDataProvider.sort(localeCompareFunction);
				this.dataProvider=_currentDataProvider;
				this.selectedItem=oldSelectedItem;
			}
		}
		
		public function set prefixedValue(value:Object):void{
			_prefixedValue = value;
		}
		
		public function get prefixedValue():Object{
			return _prefixedValue;
		}
	}
}