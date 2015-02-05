package utils
{
	import flash.utils.getQualifiedClassName;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ISort;
	import mx.collections.ISortField;
	
	import spark.collections.Sort;
	import spark.collections.SortField;

	public class CollectionUtils
	{
		public function CollectionUtils()
		{
		}
		
		public static function findInCollection(c:ArrayCollection, find:Function):Object
		{
			var matches:Array=c.source.filter(find);
			return (matches.length > 0 ? matches[0] : null);
		}
		
		public static function findField(field:String, value:*):Function
		{
			return function(element:*, index:int, array:Array):Boolean
			{
				if(!getQualifiedClassName((element) == 'Object'))
					return false;
				var tmpelem:Object = Object(element);
				if(!element.hasOwnProperty(field))
					return false;
				return element[field] == value;
			}
		}
		
		public static function sortByField(collection:ArrayCollection, field:String, numeric:Boolean):void{
			var sort:ISort = new Sort();
			var sortfield:ISortField = new SortField(field,true,numeric);

			sort.fields = [sortfield];
			collection.sort = sort;
			collection.refresh();
			collection.sort = null;
		}
	}
}