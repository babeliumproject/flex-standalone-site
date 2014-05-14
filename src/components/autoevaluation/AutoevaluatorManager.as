package components.autoevaluation {

	public class AutoevaluatorManager {

		private static var instance:AutoevaluatorManager;
		private static var allowInstance:Boolean;

		public function AutoevaluatorManager() {
			if(!allowInstance)
				throw new Error("Use AutoevaluatorManager.getInstance()");
		}

		public static function getInstance():AutoevaluatorManager {
			if(instance == null) {
				allowInstance = true;
				instance = new AutoevaluatorManager();
				allowInstance = false;
			}
			return instance;
		}
		
		public function getAutoevaluator(system:String):Autoevaluator{
			switch(system) {
				case SpinvoxAutoevaluator.SYSTEM:
					return new SpinvoxAutoevaluator();
					break;
				default:
					throw new Error("Autoevaluation not available");
			}
		}

	}
}