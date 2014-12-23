package utils
{
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	import mx.utils.ObjectUtil;

	public class LocaleUtils
	{
		
		public static const SOURCE_LANGUAGE:String='en_US';
		
		public function LocaleUtils(){
			return;
		}
		
		public static function arrangeLocaleChain(preferredLocale:String):void{
			
			var rm:IResourceManager = ResourceManager.getInstance();
			
			var lchain:Array = rm.localeChain;
			var oldLocale:String = String(lchain.shift());
			
			if(preferredLocale == oldLocale)
				return;
			
			//Remove the new locale from the chain
			var nlangidx:int = lchain.indexOf(preferredLocale);
			if(nlangidx != -1)
				delete lchain[nlangidx];
			
			//Remove the source locale from the chain
			var srclangidx:int = lchain.indexOf(SOURCE_LANGUAGE);
			if(srclangidx != -1)
				delete lchain[srclangidx];
			
			if(preferredLocale==SOURCE_LANGUAGE){
				lchain.unshift(preferredLocale);
				if(lchain.indexOf(oldLocale) == -1)
					lchain.push(oldLocale);
			} else {
				lchain.unshift(preferredLocale, SOURCE_LANGUAGE);
				if(lchain.indexOf(oldLocale) == -1)
					lchain.push(oldLocale);
			}
			rm.localeChain=lchain;
		}
	}
}