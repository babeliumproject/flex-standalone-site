package utils
{
	import flash.globalization.DateTimeFormatter;
	import flash.globalization.DateTimeStyle;
	
	import model.DataModel;
	
	import mx.resources.ResourceManager;

	public class ExerciseRenderUtils
	{
		
		public static function formatDateTime(value:int,dateStyle:String='short',timeStyle:String='none', customPattern:String='mm:ss'):String{
			var dateTimeFormatter:DateTimeFormatter;
			var currentLocale:String=ResourceManager.getInstance().localeChain[0];
			dateTimeFormatter=new DateTimeFormatter(currentLocale);
			if(dateStyle == DateTimeStyle.CUSTOM || timeStyle == DateTimeStyle.CUSTOM){
				dateTimeFormatter.setDateTimePattern(customPattern);	
			} else {
				dateTimeFormatter.setDateTimeStyles(dateStyle,timeStyle);
			}
			var date:Date=new Date(value * 1000); //Date needs timestamps with ms accuracy				
			var formattedValue:String = dateTimeFormatter.format(date);
			return formattedValue ? formattedValue : dateTimeFormatter.getDateTimePattern();
		}
		
		public static function getFlagSource(temp:Object, property:String='language'):Class
		{
			var _model:DataModel=DataModel.getInstance();
			return temp.hasOwnProperty(property) ? _model.localesAndFlags.getCountryFlagClass(temp[property]) : null;
		}
		
		public static function getLevelLabel(difficulty:int):String
		{
			var _model:DataModel=DataModel.getInstance();
			var match:Object = CollectionUtils.findInCollection(_model.levels, CollectionUtils.findField('level',difficulty) as Function);
			return match ? match.label : '';
		}
	}
}