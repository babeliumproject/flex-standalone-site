package utils
{
	public class QueryUtils
	{
		public static function formatSearchQuery(rawQuery:String):String{
			var terms:String=rawQuery;
			if (!terms.length)
				return null;
			var tb:String=terms.replace(/[\r\n]+/g, "");
			var ts:String=tb.replace(/[\s]+/g, "");
			if (!ts.length)
				return null;
			var te:String=encodeURIComponent(tb);
			var tp:String=te.replace(/%20/g, "+");
			
			return tp;
		}
	}
}