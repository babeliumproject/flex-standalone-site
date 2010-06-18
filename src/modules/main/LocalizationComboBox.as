package modules.main
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	import model.DataModel;
	
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
	import mx.events.ResourceEvent;
	
	import view.common.IconComboBox;
	
	public class LocalizationComboBox extends IconComboBox
	{
		
		private var _availableLocales:Array=DataModel.getInstance().localesAndFlags.availableLanguages;
		
		public function LocalizationComboBox()
		{
			super();
			this.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
		}
		
		public function onCreationComplete(event:FlexEvent):void{
			
			this.setStyle('fontWeight', 'normal');
			
			this.dataProvider=_availableLocales;
			
			this.labelFunction=localeComboBoxLabelFunction;
			this.addEventListener(ListEvent.CHANGE, localeComboBoxChangeHandler);
			updateLocaleComboBox();
		}
		
		// Localization combobox functions
		public function localeComboBoxLabelFunction(item:Object):String
		{
			var locale:String=String(item.code);
			var upperLocale:String=locale.toUpperCase();
			return resourceManager.getString('myResources', 'LOCALE_' + upperLocale);
		}
		
		public function localeComboBoxChangeHandler(event:Event):void
		{
			var newLocale:String=String(this.selectedItem.code);
			if (resourceManager.getLocales().indexOf(newLocale) != -1)
			{
				switchLocale();
			}
			else
			{
				var resourceModuleURL:String="Resources_" + newLocale + ".swf";
				var eventDispatcher:IEventDispatcher=resourceManager.loadResourceModule(resourceModuleURL);
				eventDispatcher.addEventListener(ResourceEvent.COMPLETE, resourceModuleCompleteHandler);
			}
		}
		
		private function resourceModuleCompleteHandler(event:ResourceEvent):void
		{
			switchLocale();
		}
		
		private function switchLocale():void
		{
			var newLocale:String=String(this.selectedItem.code);
			resourceManager.localeChain=[newLocale];
			updateLocaleComboBox();
			//Updating changes in DataModel, used in Search.mxml 
			DataModel.getInstance().languageChanged=true;
		}
		
		private function localeCompareFunction(item1:Object, item2:Object):int
		{
			var language1:String=localeComboBoxLabelFunction(item1);
			var language2:String=localeComboBoxLabelFunction(item2);
			if (language1 < language2)
				return -1;
			if (language1 > language2)
				return 1;
			return 0;
		}
		
		private function updateLocaleComboBox():void
		{
			var oldSelectedItem:Object=this.selectedItem;
			// Repopulate the combobox with locales,
			// re-sorting by localized language name.
			_availableLocales.sort(localeCompareFunction);
			this.dataProvider=_availableLocales;
			this.selectedItem=oldSelectedItem;
		}
		
	}
}