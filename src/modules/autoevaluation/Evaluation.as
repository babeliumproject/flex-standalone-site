package modules.autoevaluation
{
	import mx.collections.ArrayCollection;
	
	public class Evaluation
	{
		public var words:ArrayCollection;
		public var responseText:String;
		public var maxScore:Number;
		public var minScore:Number;

		public function Evaluation(){
			words = new ArrayCollection();
			responseText = "";
			maxScore = 0;
			minScore = 0;
		}
		
		public function addItem(word:String, rating:String, startIndex:int):void{
			words.addItem(new EvaluationItem(word, rating, startIndex));
		}
	}
}