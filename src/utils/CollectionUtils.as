package utils
{
	import flash.utils.getQualifiedClassName;
	
	import mx.collections.ArrayCollection;

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
				if(!Object(element).hasOwnProperty(field))
					return false;
				return element.field == value;
			}
		}
	}
}