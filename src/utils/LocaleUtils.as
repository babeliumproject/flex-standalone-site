package utils
{
	import model.DataModel;
	
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	import mx.utils.ObjectUtil;

	public class LocaleUtils
	{	
		public function LocaleUtils(){
			return;
		}
		
		public static function arrangeLocaleChain(preferredLocale:String):void{
			var sourcelocale:String = DataModel.SOURCE_LOCALE;
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
			var srclangidx:int = lchain.indexOf(sourcelocale);
			if(srclangidx != -1)
				delete lchain[srclangidx];
			
			if(preferredLocale==sourcelocale){
				lchain.unshift(preferredLocale);
				if(lchain.indexOf(oldLocale) == -1)
					lchain.push(oldLocale);
			} else {
				lchain.unshift(preferredLocale, sourcelocale);
				if(lchain.indexOf(oldLocale) == -1)
					lchain.push(oldLocale);
			}
			rm.localeChain=lchain;
		}
	}
}