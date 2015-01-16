package model
{
	import assets.CountryFlags;
	
	import flash.utils.getDefinitionByName;
	
	import mx.collections.ArrayCollection;
	import mx.formatters.NumberBaseRoundType;
	import mx.formatters.NumberFormatter;
	import mx.resources.ResourceManager;

	public class LocalesAndFlags
	{
		public static var SOURCE_LOCALE:String="en_US";
		
		//This array contains the selectable languages for the exercises
		[Bindable] public var availableLanguages:Array = new Array();
		
		//The selectable GUI languages
		[Bindable] public var guiLanguages:Array = new Array;

		//Country subdivision language codes
		private var exceptions:ArrayCollection=new ArrayCollection(['ca_ES','eu_ES','gl_ES']);
		
		public function LocalesAndFlags()
		{
			getLocaleCodesFromResourceFile();
			
			for each(var code:String in ResourceManager.getInstance().getLocales()){
				guiLanguages.push(getLocaleAndFlagGivenLocaleCode(code));
			}
		}

		public function getLocaleAndFlagGivenLocaleCode(code:String):Object
		{
			var localeAndFlag:Object = null;
			for each(var language:Object in availableLanguages){
				if(language.code == code){
					localeAndFlag = language;
					break;
				}
			}
			return localeAndFlag;
		}
		
		public function getCountryFlagClass(locale:String):Class{
			var tmp:Object=getLocaleAndFlagGivenLocaleCode(locale);
			var iclass:Class;
			if(tmp){
				iclass=tmp.icon as Class;
			}
			return iclass;
		}
		
		public function getLocaleCodesFromResourceFile():void{
			
			var localeitem:Object;
			var language:String, country:String, code:String, subdivision:String;
			var flag:Class;
			
			var srclang:String=SOURCE_LOCALE;
			var resources:Object=ResourceManager.getInstance().getResourceBundle(srclang, "myResources").content;
			var pattern:RegExp=/LOCALE_(\w{2})_(\w{2})$/;
			var tmpLocales:Array= new Array();
			
			for (var item:Object in resources)
			{
				var key:String=item as String;
				//Filter the keys that match the descriptor pattern
				var matches:Array=key.match(pattern);
				if(matches && matches.length){
					language = (matches[1] as String).toLowerCase();
					country = matches[2] as String;
					code = language+"_"+country.toUpperCase();
					
					if(exceptions.contains(code)){
						switch(language)
						{
							case 'eu':
							{
								subdivision='pv';
								break;
							}
							case 'gl':
							{
								subdivision='ga';
								break;
							}
							case 'ca':
							{
								subdivision='ct';
								break;
							}
							default:
							{
								continue;
							}
						}
						flag = CountryFlags["flag_"+country.toLowerCase()+"_"+subdivision];
					} else {
						flag = CountryFlags["flag_"+country.toLowerCase()];
					}
					
					localeitem = new Object();
					localeitem.code = code;
					localeitem.icon = flag;
					tmpLocales.push(localeitem);
				}
			}
			availableLanguages=tmpLocales;	
		}
		
		public function getLevelCorrespondence(avgDifficulty:Number):String
		{
			var numFormat:NumberFormatter=new NumberFormatter();
			numFormat.precision=0;
			numFormat.rounding=NumberBaseRoundType.NEAREST;
			var roundedAvgDifficulty:int=int(numFormat.format(avgDifficulty));
			switch (roundedAvgDifficulty)
			{
				case 1:
					return 'A1';
					break;
				case 2:
					return 'A2';
					break;
				case 3:
					return 'B1';
					break;
				case 4:
					return 'B2';
					break;
				case 5:
					return 'C1';
					break;
				default:
					return '';
					break;
			}
		}

	}
}
