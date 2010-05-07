package modules.main
{
	import flash.events.IEventDispatcher;
	
	import view.common.IconComboBox;
	
	import mx.containers.HBox;
	import mx.events.FlexEvent;
	import mx.events.ResourceEvent;
	
	public class LocalizationComboBoxClass extends HBox
	{
		
		[Bindable]
		[Embed(source="../../resources/images/flags/flag_united_kingdom.png")]
		public var FlagEnglish:Class;
		
		[Bindable]
		[Embed(source="../../resources/images/flags/flag_spain.png")]
		public var FlagSpanish:Class;
		
		[Bindable]
		[Embed(source="../../resources/images/flags/flag_basque_country.png")]
		public var FlagBasque:Class;
		
		[Bindable]
		[Embed(source="../../resources/images/flags/flag_france.png")]
		public var FlagFrench:Class;
		
		[Bindable]
		public var flaggedLanguageData:Array=new Array({code: 'en_US', icon: FlagEnglish}, 
													   {code: 'es_ES', icon: FlagSpanish},
													   {code: 'eu_ES', icon: FlagBasque},
													   {code: 'fr_FR', icon: FlagFrench});
		
		//Visual component declaration
		public var languageComboBox:IconComboBox;
		
		public function LocalizationComboBoxClass()
		{
			super();
			this.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
		}
		
		public function onCreationComplete(event:FlexEvent):void{
			updateLanguageComboBox();
		}
		
		// Localization combobox functions
		public function languageComboBoxLabelFunction(item:Object):String
		{
			var locale:String=String(item.code);
			var upperLocale:String=locale.toUpperCase();
			return resourceManager.getString('myResources', 'LOCALE_' + upperLocale);
		}
		
		public function languageComboBox_changeHandler(event:Event):void
		{
			var newLocale:String=String(languageComboBox.selectedItem.code);
			if (resourceManager.getLocales().indexOf(newLocale) != -1)
			{
				switchLocale();
			}
			else
			{
				var resourceModuleURL:String="Resources_" + newLocale + ".swf";
				var eventDispatcher:IEventDispatcher=resourceManager.loadResourceModule(resourceModuleURL);
				eventDispatcher.addEventListener(ResourceEvent.COMPLETE, resourceModule_completeHandler);
			}
		}
		
		private function resourceModule_completeHandler(event:ResourceEvent):void
		{
			switchLocale();
		}
		
		private function switchLocale():void
		{
			var newLocale:String=String(languageComboBox.selectedItem.code);
			resourceManager.localeChain=[newLocale];
			updateLanguageComboBox();
		}
		
		private function localeCompareFunction(item1:Object, item2:Object):int
		{
			var language1:String=languageComboBoxLabelFunction(item1);
			var language2:String=languageComboBoxLabelFunction(item2);
			if (language1 < language2)
				return -1;
			if (language1 > language2)
				return 1;
			return 0;
		}
		
		private function updateLanguageComboBox():void
		{
			var oldSelectedItem:Object=languageComboBox.selectedItem;
			// Repopulate the combobox with locales,
			// re-sorting by localized language name.
			flaggedLanguageData.sort(localeCompareFunction);
			languageComboBox.dataProvider=flaggedLanguageData;
			languageComboBox.selectedItem=oldSelectedItem;
		}
		
	}
}