package components.autoevaluation {

	public interface Autoevaluator {
		function evaluate(exerciseStr:String, responseStr:String):Evaluation;
	}
}