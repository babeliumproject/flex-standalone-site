package model
{
	public class LocalesAndFlags
	{
		
		[Bindable]
		[Embed(source="/../resources/images/flags/flag_united_kingdom.png")]
		private var FlagEnglish:Class;
		private var en_US:Object = {code: 'en_US', icon: FlagEnglish};
		
		[Bindable]
		[Embed(source="/../resources/images/flags/flag_spain.png")]
		public var FlagSpanish:Class;
		private var es_ES:Object = {code: 'es_ES', icon: FlagSpanish};
		
		[Bindable]
		[Embed(source="/../resources/images/flags/flag_basque_country.png")]
		public var FlagBasque:Class;
		private var eu_ES:Object = {code: 'eu_ES', icon: FlagBasque};
		
		[Bindable]
		[Embed(source="/../resources/images/flags/flag_france.png")]
		public var FlagFrench:Class;
		private var fr_FR:Object = {code: 'fr_FR', icon: FlagFrench};
		
		[Bindable]
		public var availableLanguages:Array=new Array(en_US, es_ES, eu_ES, fr_FR);
		
		public function getLocaleAndFlagGivenLocaleCode(code:String):Object{
			var localeAndFlag:Object = null;
			switch(code){
				case 'en_US':
					localeAndFlag = en_US;
					break;
				case 'es_ES':
					localeAndFlag = es_ES;
					break;
				case 'eu_ES':
					localeAndFlag = eu_ES;
					break;
				case 'fr_FR':
					localeAndFlag = fr_FR;
					break;
				default:
					break;
			}
			return localeAndFlag;
		}
		
	}
}