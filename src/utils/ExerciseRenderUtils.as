package utils
{
	import flash.globalization.DateTimeFormatter;
	import flash.globalization.DateTimeStyle;
	import flash.globalization.LocaleID;
	
	import model.DataModel;
	
	import mx.collections.ArrayCollection;
	import mx.resources.ResourceManager;
	import mx.utils.ObjectUtil;

	public class ExerciseRenderUtils
	{

		public static var dpExerciseType:ArrayCollection=new ArrayCollection([{'code': 0, 'label': 'LANGUAGE_PRACTICE'}, {'code': 1, 'label': 'FREE_CONTEXT'}, {'code': 2, 'label': 'CONVERSATION'}, {'code': 3, 'label': 'STORYTELLING'}, {'code': 4, 'label': 'VOICE_OVER'}, {'code': 5, 'label': 'OTHER'}]);

		public static var dpCommSituation:ArrayCollection=new ArrayCollection([{'code': 0, 'label': 'EVERYDAY_LIFE_AND_TOURISM'}, {'code': 1, 'label': 'STUDIES'}, {'code': 2, 'label': 'WORK'}]);

		public static var dpLingAspect:ArrayCollection=new ArrayCollection([{'code': 0, 'label': 'ADVERB_ADJECTIVE'}, {'code': 1, 'label': 'FORMS_OF_QUESTIONS'}, {'code': 2, 'label': 'NEGATION'}, {'code': 3, 'label': 'NOUN'}, {'code': 4, 'label': 'PRONOUNS'}, {'code': 5, 'label': 'PRONUNCIATION'}, {'code': 6, 'label': 'VERB'}, {'code': 7, 'label': 'VOCABULARY'}]);

		public static var competenceLabels:Array=['DEALING_WITH_EMERGENCY_SITUATIONS', 'DESCRIBING_EXPERIENCES', 'DEVELOPING_AN_ARGUMENT', 'GENERAL_WORK', 'GIVING_PRESENTATIONS', 'GOING_OUT_TO_EAT', 'GOING_SHOPPING', 'HEALTH', 'MAKING_ARRANGEMENTS', 'PARTICIPATING_IN_AN_INTERVIEW', 'PARTICIPATING_IN_CLASS', 'PARTICIPATING_IN_MEETINGS', 'PUBLIC_SPEAKING', 'SIGHTSEEING', 'SOCIALIZING', 'SPEAKING_ABOUT_ONESELF', 'STAYING_AT_A_HOTEL', 'TELEPHONING', 'TRAVEL', 'USING_FINANCIAL_AND_POSTAL_SERVICES'];

		public static function formatTimestamp(value:int, dateStyle:String='short', timeStyle:String='none', customPattern:String='mm:ss'):String
		{
			var dateTimeFormatter:DateTimeFormatter;
			var currentLocale:String=ResourceManager.getInstance().localeChain[0];
			dateTimeFormatter=new DateTimeFormatter(currentLocale);
			if (dateStyle == DateTimeStyle.CUSTOM || timeStyle == DateTimeStyle.CUSTOM)
			{
				dateTimeFormatter.setDateTimePattern(customPattern);
			}
			else
			{
				dateTimeFormatter.setDateTimeStyles(dateStyle, timeStyle);
			}
			var date:Date=new Date(value * 1000); //Date needs timestamps with ms accuracy				
			var formattedValue:String=dateTimeFormatter.format(date);
			return formattedValue ? formattedValue : dateTimeFormatter.getDateTimePattern();
		}

		public static function formatDateTime(value:String, dateStyle:String='short', timeStyle:String='none', customPattern:String='mm:ss'):String
		{
			var dateTimeFormatter:DateTimeFormatter;
			var currentLocale:String=ResourceManager.getInstance().localeChain[0];

			dateTimeFormatter=new DateTimeFormatter(currentLocale);
			if (dateStyle == DateTimeStyle.CUSTOM || timeStyle == DateTimeStyle.CUSTOM)
			{
				dateTimeFormatter.setDateTimePattern(customPattern);
			}
			else
			{
				dateTimeFormatter.setDateTimeStyles(dateStyle, timeStyle);
			}
			var formattedValue:String=value;
			var pattern:RegExp=/([0-9]+)-([0-9]+)-([0-9]+) ([0-9]+):([0-9]+):([0-9]+)/;
			var matches:Array=value.match(pattern);
			if (matches && matches.length)
			{
				//year,month,date,hour,minute,second
				var date:Date=new Date(matches[1], matches[2] - 1, matches[3], matches[4], matches[5], matches[6]);
				formattedValue=dateTimeFormatter.format(date);
			}

			return formattedValue;
		}

		public static function getFlagSource(temp:Object, property:String='language'):Class
		{
			var _model:DataModel=DataModel.getInstance();
			return temp.hasOwnProperty(property) ? _model.localesAndFlags.getCountryFlagClass(temp[property]) : null;
		}

		public static function getLevelLabel(difficulty:int):String
		{
			var _model:DataModel=DataModel.getInstance();
			var match:Object=CollectionUtils.findInCollection(_model.levels, CollectionUtils.findField('level', difficulty) as Function);
			return match ? match.label : '';
		}

		public static function getTypeLabel(type:int):String
		{
			var match:Object=CollectionUtils.findInCollection(dpExerciseType, CollectionUtils.findField('code', type) as Function);
			return match ? match.label : '';
		}

		public static function getCommunicationSituationLabel(commSituation:int):String
		{
			var tmp:int=commSituation - 1;
			if (tmp < 0)
				return '';
			var match:Object=CollectionUtils.findInCollection(dpCommSituation, CollectionUtils.findField('code', tmp) as Function);
			return match ? match.label : '';
		}

		public static function getLinguisticAspectLabel(lingAspect:int):String
		{
			var tmp:int=lingAspect - 1;
			if (tmp < 0)
				return '';
			var match:Object=CollectionUtils.findInCollection(dpLingAspect, CollectionUtils.findField('code', tmp) as Function);
			return match ? match.label : '';
		}

		public static function getCommunicativeCompetenceLabel(commCompetence:int):String
		{
			var tmp:int=commCompetence - 1;
			if (tmp < 0)
				return '';
			return (tmp < competenceLabels.length) ? competenceLabels[tmp] : '';
		}
	}
}
