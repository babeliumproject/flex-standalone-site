package modules.autoevaluation
{
	public class EvaluationItem {
		public var word:String;
		public var rating:String;
		public var startIndex:int;
		
		public function EvaluationItem(word:String, rating:String, startIndex:int):void{
			this.word = word;
			this.rating = rating;
			this.startIndex = startIndex;
		}
	}
}