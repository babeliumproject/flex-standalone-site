package AutoevaluationTestCase {
	import flexunit.framework.TestCase;
	import flexunit.framework.TestSuite;
	
	import modules.autoevaluation.Autoevaluator;
	import modules.autoevaluation.AutoevaluatorManager;
	import modules.autoevaluation.Evaluation;

	public class SpinvoxAutoevaluationTest extends TestCase {
		private const system:String = "spinvox";

		public function SpinvoxAutoevaluationTest(methodName:String = null) {
			super(methodName);
		}

		public static function suite():TestSuite {
			var evaluationTS:TestSuite = new TestSuite();
			evaluationTS.addTest(new SpinvoxAutoevaluationTest("testSameStrings"));
			evaluationTS.addTest(new SpinvoxAutoevaluationTest("testSameStringsWithMediumRespInMiddle"));
			evaluationTS.addTest(new SpinvoxAutoevaluationTest("testWrongMediumRespInMiddle"));
			evaluationTS.addTest(new SpinvoxAutoevaluationTest("testSameStringsWithMediumExerRespInMiddle"));
			evaluationTS.addTest(new SpinvoxAutoevaluationTest("testSameStringsWithMediumExerInMiddle"));
			evaluationTS.addTest(new SpinvoxAutoevaluationTest("testSameStringsWithMediumRespInEnd"));
			evaluationTS.addTest(new SpinvoxAutoevaluationTest("testSameStringsWithMediumRespInStartEnd"));
			evaluationTS.addTest(new SpinvoxAutoevaluationTest("testSameWordNumberErrorRespInMiddle"));
			evaluationTS.addTest(new SpinvoxAutoevaluationTest("testInsertWordsRespInMiddle"));
			evaluationTS.addTest(new SpinvoxAutoevaluationTest("testRemoveWordsRespInMiddle"));
			evaluationTS.addTest(new SpinvoxAutoevaluationTest("testUnknownWordRespInMiddle"));
			evaluationTS.addTest(new SpinvoxAutoevaluationTest("testDifferentStrings"));
			evaluationTS.addTest(new SpinvoxAutoevaluationTest("testRepeatReplaceWordResp"));
			evaluationTS.addTest(new SpinvoxAutoevaluationTest("testRepeatWordsResp"));
			evaluationTS.addTest(new SpinvoxAutoevaluationTest("testRepeatWordsRespAtBegin"));
			evaluationTS.addTest(new SpinvoxAutoevaluationTest("testRepeatWordsTogetherResp"));
			evaluationTS.addTest(new SpinvoxAutoevaluationTest("testUnknownWordExerInMiddle"));
			evaluationTS.addTest(new SpinvoxAutoevaluationTest("testSameStringsRepeatWordsExer"));
			evaluationTS.addTest(new SpinvoxAutoevaluationTest("testDifferentWordCount"));
			evaluationTS.addTest(new SpinvoxAutoevaluationTest("testSamePartOfWord"));
			evaluationTS.addTest(new SpinvoxAutoevaluationTest("testSamePartOfWordBeginningExerciseStr"));
			evaluationTS.addTest(new SpinvoxAutoevaluationTest("testSamePartOfWordMiddleExerciseStr"));			
			evaluationTS.addTest(new SpinvoxAutoevaluationTest("testSamePartOfWordMiddleExerciseAndWordStr"));
			
			evaluationTS.addTest(new SpinvoxAutoevaluationTest("testPhrase1"));
			evaluationTS.addTest(new SpinvoxAutoevaluationTest("testPhrase2"));
			
			return evaluationTS;
		}

	public function testSameStrings():void {
			var eval:Autoevaluator = AutoevaluatorManager.getInstance().getAutoevaluator(system);
			var str1:String = "Can’t you just use your sleeve";
			var str2:String = "Can’t you just use your sleeve";
			var result:Evaluation = eval.evaluate(str1, str2);

			assertEquals("1st rating", "right", result.words.getItemAt(0).rating);
			assertEquals("1st word", "can’t", result.words.getItemAt(0).word);
			assertEquals("1st startIndex", 0, result.words.getItemAt(0).startIndex);

			assertEquals("2th rating", "right", result.words.getItemAt(1).rating);
			assertEquals("2th word", "you", result.words.getItemAt(1).word);
			assertEquals("2th startIndex", 6, result.words.getItemAt(1).startIndex);

			assertEquals("3th rating", "right", result.words.getItemAt(2).rating);
			assertEquals("3th word", "just", result.words.getItemAt(2).word);
			assertEquals("3th startIndex", 10, result.words.getItemAt(2).startIndex);
			
			assertEquals("4th rating", "right", result.words.getItemAt(3).rating);
			assertEquals("4th word", "use", result.words.getItemAt(3).word);
			assertEquals("4th startIndex", 15, result.words.getItemAt(3).startIndex);
			
			assertEquals("5th rating", "right", result.words.getItemAt(4).rating);
			assertEquals("5th word", "your", result.words.getItemAt(4).word);
			assertEquals("5th startIndex", 19, result.words.getItemAt(4).startIndex);
			
			assertEquals("6th rating", "right", result.words.getItemAt(5).rating);
			assertEquals("6th word", "sleeve", result.words.getItemAt(5).word);
			assertEquals("6th startIndex", 24, result.words.getItemAt(5).startIndex);
			
			assertEquals("Max score", 100, result.maxScore);
			assertEquals("Min score", 100, result.minScore);
		}

		/*public function testSameStrings():void {
			var eval:Autoevaluator = AutoevaluatorManager.getInstance().getAutoevaluator(system);
			var str1:String = "Hello world, how are you?";
			var str2:String = "Hello world, how are you?";
			var result:Evaluation = eval.evaluate(str1, str2);

			assertEquals("1st rating", "right", result.words.getItemAt(0).rating);
			assertEquals("1st word", "hello", result.words.getItemAt(0).word);
			assertEquals("1st startIndex", 0, result.words.getItemAt(0).startIndex);

			assertEquals("2nd rating", "right", result.words.getItemAt(1).rating);
			assertEquals("2nd word", "world", result.words.getItemAt(1).word);
			assertEquals("2nd startIndex", 6, result.words.getItemAt(1).startIndex);

			assertEquals("3th rating", "right", result.words.getItemAt(2).rating);
			assertEquals("3th word", "how", result.words.getItemAt(2).word);
			assertEquals("3th startIndex", 12, result.words.getItemAt(2).startIndex);

			assertEquals("4th rating", "right", result.words.getItemAt(3).rating);
			assertEquals("4th word", "are", result.words.getItemAt(3).word);
			assertEquals("4th startIndex", 16, result.words.getItemAt(3).startIndex);

			assertEquals("5th rating", "right", result.words.getItemAt(4).rating);
			assertEquals("5th word", "you", result.words.getItemAt(4).word);
			assertEquals("5th startIndex", 20, result.words.getItemAt(4).startIndex);
			
			assertEquals("Max score", 100, result.maxScore);
			assertEquals("Min score", 100, result.minScore);
		}*/

		public function testSameStringsWithMediumRespInMiddle():void {
			var eval:Autoevaluator = AutoevaluatorManager.getInstance().getAutoevaluator(system);
			var str1:String = "Hello world, how are you?";
			var str2:String = "Hello world, how(?) are you?";
			var result:Evaluation = eval.evaluate(str1, str2);

			assertEquals("1st rating", "right", result.words.getItemAt(0).rating);
			assertEquals("1st word", "hello", result.words.getItemAt(0).word);
			assertEquals("1st startIndex", 0, result.words.getItemAt(0).startIndex);

			assertEquals("2nd rating", "right", result.words.getItemAt(1).rating);
			assertEquals("2nd word", "world", result.words.getItemAt(1).word);
			assertEquals("2nd startIndex", 6, result.words.getItemAt(1).startIndex);

			assertEquals("3th rating", "medium", result.words.getItemAt(2).rating);
			assertEquals("3th word", "how", result.words.getItemAt(2).word);
			assertEquals("3th startIndex", 12, result.words.getItemAt(2).startIndex);

			assertEquals("4th rating", "right", result.words.getItemAt(3).rating);
			assertEquals("4th word", "are", result.words.getItemAt(3).word);
			assertEquals("4th startIndex", 19, result.words.getItemAt(3).startIndex);

			assertEquals("5th rating", "right", result.words.getItemAt(4).rating);
			assertEquals("5th word", "you", result.words.getItemAt(4).word);
			assertEquals("5th startIndex", 23, result.words.getItemAt(4).startIndex);
			
			assertEquals("Max score", 90, result.maxScore);
			assertEquals("Min score", 90, result.minScore);
		}

		public function testWrongMediumRespInMiddle():void {
			var eval:Autoevaluator = AutoevaluatorManager.getInstance().getAutoevaluator(system);
			var str1:String = "Hello world, how are you?";
			var str2:String = "Hello world, flex(?) are you?";
			var result:Evaluation = eval.evaluate(str1, str2);

			assertEquals("1st rating", "right", result.words.getItemAt(0).rating);
			assertEquals("1st word", "hello", result.words.getItemAt(0).word);
			assertEquals("1st startIndex", 0, result.words.getItemAt(0).startIndex);

			assertEquals("2nd rating", "right", result.words.getItemAt(1).rating);
			assertEquals("2nd word", "world", result.words.getItemAt(1).word);
			assertEquals("2nd startIndex", 6, result.words.getItemAt(1).startIndex);

			assertEquals("3th rating", "wrong", result.words.getItemAt(2).rating);
			assertEquals("3th word", "how", result.words.getItemAt(2).word);
			assertEquals("3th startIndex", 12, result.words.getItemAt(2).startIndex);

			assertEquals("4th rating", "right", result.words.getItemAt(3).rating);
			assertEquals("4th word", "are", result.words.getItemAt(3).word);
			assertEquals("4th startIndex", 20, result.words.getItemAt(3).startIndex);

			assertEquals("5th rating", "right", result.words.getItemAt(4).rating);
			assertEquals("5th word", "you", result.words.getItemAt(4).word);
			assertEquals("5th startIndex", 24, result.words.getItemAt(4).startIndex);
			
			assertEquals("Max score", 80, result.maxScore);
			assertEquals("Min score", 80, result.minScore);
		}

		public function testSameStringsWithMediumExerRespInMiddle():void {
			var eval:Autoevaluator = AutoevaluatorManager.getInstance().getAutoevaluator(system);
			var str1:String = "Hello world, how(?) are you?";
			var str2:String = "Hello world, how(?) are you?";
			var result:Evaluation = eval.evaluate(str1, str2);

			assertEquals("1st rating", "right", result.words.getItemAt(0).rating);
			assertEquals("1st word", "hello", result.words.getItemAt(0).word);
			assertEquals("1st startIndex", 0, result.words.getItemAt(0).startIndex);

			assertEquals("2nd rating", "right", result.words.getItemAt(1).rating);
			assertEquals("2nd word", "world", result.words.getItemAt(1).word);
			assertEquals("2nd startIndex", 6, result.words.getItemAt(1).startIndex);

			assertEquals("3th rating", "medium", result.words.getItemAt(2).rating);
			assertEquals("3th word", "how", result.words.getItemAt(2).word);
			assertEquals("3th startIndex", 12, result.words.getItemAt(2).startIndex);

			assertEquals("4th rating", "right", result.words.getItemAt(3).rating);
			assertEquals("4th word", "are", result.words.getItemAt(3).word);
			assertEquals("4th startIndex", 19, result.words.getItemAt(3).startIndex);

			assertEquals("5th rating", "right", result.words.getItemAt(4).rating);
			assertEquals("5th word", "you", result.words.getItemAt(4).word);
			assertEquals("5th startIndex", 23, result.words.getItemAt(4).startIndex);
			
			assertEquals("Max score", 90, result.maxScore);
			assertEquals("Min score", 90, result.minScore);
		}

		public function testSameStringsWithMediumExerInMiddle():void {
			var eval:Autoevaluator = AutoevaluatorManager.getInstance().getAutoevaluator(system);
			var str1:String = "Hello world, how(?) are you?";
			var str2:String = "Hello world, how are you?";
			var result:Evaluation = eval.evaluate(str1, str2);

			assertEquals("1st rating", "right", result.words.getItemAt(0).rating);
			assertEquals("1st word", "hello", result.words.getItemAt(0).word);
			assertEquals("1st startIndex", 0, result.words.getItemAt(0).startIndex);

			assertEquals("2nd rating", "right", result.words.getItemAt(1).rating);
			assertEquals("2nd word", "world", result.words.getItemAt(1).word);
			assertEquals("2nd startIndex", 6, result.words.getItemAt(1).startIndex);

			assertEquals("3th rating", "right", result.words.getItemAt(2).rating);
			assertEquals("3th word", "how", result.words.getItemAt(2).word);
			assertEquals("3th startIndex", 12, result.words.getItemAt(2).startIndex);

			assertEquals("4th rating", "right", result.words.getItemAt(3).rating);
			assertEquals("4th word", "are", result.words.getItemAt(3).word);
			assertEquals("4th startIndex", 16, result.words.getItemAt(3).startIndex);

			assertEquals("5th rating", "right", result.words.getItemAt(4).rating);
			assertEquals("5th word", "you", result.words.getItemAt(4).word);
			assertEquals("5th startIndex", 20, result.words.getItemAt(4).startIndex);
			
			assertEquals("Max score", 100, result.maxScore);
			assertEquals("Min score", 100, result.minScore);
		}

		public function testSameStringsWithMediumRespInEnd():void {
			var eval:Autoevaluator = AutoevaluatorManager.getInstance().getAutoevaluator(system);
			var str1:String = "Hello world, how are you?";
			var str2:String = "Hello world, how are you(?)?";
			var result:Evaluation = eval.evaluate(str1, str2);

			assertEquals("1st rating", "right", result.words.getItemAt(0).rating);
			assertEquals("1st word", "hello", result.words.getItemAt(0).word);
			assertEquals("1st startIndex", 0, result.words.getItemAt(0).startIndex);

			assertEquals("2nd rating", "right", result.words.getItemAt(1).rating);
			assertEquals("2nd word", "world", result.words.getItemAt(1).word);
			assertEquals("2nd startIndex", 6, result.words.getItemAt(1).startIndex);

			assertEquals("3th rating", "right", result.words.getItemAt(2).rating);
			assertEquals("3th word", "how", result.words.getItemAt(2).word);
			assertEquals("3th startIndex", 12, result.words.getItemAt(2).startIndex);

			assertEquals("4th rating", "right", result.words.getItemAt(3).rating);
			assertEquals("4th word", "are", result.words.getItemAt(3).word);
			assertEquals("4th startIndex", 16, result.words.getItemAt(3).startIndex);

			assertEquals("5th rating", "medium", result.words.getItemAt(4).rating);
			assertEquals("5th word", "you", result.words.getItemAt(4).word);
			assertEquals("5th startIndex", 20, result.words.getItemAt(4).startIndex);
			
			assertEquals("Max score", 90, result.maxScore);
			assertEquals("Min score", 90, result.minScore);
		}

		public function testSameStringsWithMediumRespInStartEnd():void {
			var eval:Autoevaluator = AutoevaluatorManager.getInstance().getAutoevaluator(system);
			var str1:String = "Hello world, how are you?";
			var str2:String = "Hello(?) world, how are you(?)?";
			var result:Evaluation = eval.evaluate(str1, str2);

			assertEquals("1st rating", "medium", result.words.getItemAt(0).rating);
			assertEquals("1st word", "hello", result.words.getItemAt(0).word);
			assertEquals("1st startIndex", 0, result.words.getItemAt(0).startIndex);

			assertEquals("2nd rating", "right", result.words.getItemAt(1).rating);
			assertEquals("2nd word", "world", result.words.getItemAt(1).word);
			assertEquals("2nd startIndex", 9, result.words.getItemAt(1).startIndex);

			assertEquals("3th rating", "right", result.words.getItemAt(2).rating);
			assertEquals("3th word", "how", result.words.getItemAt(2).word);
			assertEquals("3th startIndex", 15, result.words.getItemAt(2).startIndex);

			assertEquals("4th rating", "right", result.words.getItemAt(3).rating);
			assertEquals("4th word", "are", result.words.getItemAt(3).word);
			assertEquals("4th startIndex", 19, result.words.getItemAt(3).startIndex);

			assertEquals("5th rating", "medium", result.words.getItemAt(4).rating);
			assertEquals("5th word", "you", result.words.getItemAt(4).word);
			assertEquals("5th startIndex", 23, result.words.getItemAt(4).startIndex);
			
			assertEquals("Max score", 80, result.maxScore);
			assertEquals("Min score", 80, result.minScore);
		}

		public function testSameWordNumberErrorRespInMiddle():void {
			var eval:Autoevaluator = AutoevaluatorManager.getInstance().getAutoevaluator(system);
			var str1:String = "Hello world, how are you?";
			var str2:String = "Hello flex, how are you?";
			var result:Evaluation = eval.evaluate(str1, str2);

			assertEquals("1st rating", "right", result.words.getItemAt(0).rating);
			assertEquals("1st word", "hello", result.words.getItemAt(0).word);
			assertEquals("1st startIndex", 0, result.words.getItemAt(0).startIndex);

			assertEquals("2nd rating", "wrong", result.words.getItemAt(1).rating);
			assertEquals("2nd word", "world", result.words.getItemAt(1).word);
			assertEquals("2nd startIndex", 6, result.words.getItemAt(1).startIndex);

			assertEquals("3th rating", "right", result.words.getItemAt(2).rating);
			assertEquals("3th word", "how", result.words.getItemAt(2).word);
			assertEquals("3th startIndex", 11, result.words.getItemAt(2).startIndex);

			assertEquals("4th rating", "right", result.words.getItemAt(3).rating);
			assertEquals("4th word", "are", result.words.getItemAt(3).word);
			assertEquals("4th startIndex", 15, result.words.getItemAt(3).startIndex);

			assertEquals("5th rating", "right", result.words.getItemAt(4).rating);
			assertEquals("5th word", "you", result.words.getItemAt(4).word);
			assertEquals("5th startIndex", 19, result.words.getItemAt(4).startIndex);
			
			assertEquals("Max score", 80, result.maxScore);
			assertEquals("Min score", 80, result.minScore);
		}

		public function testInsertWordsRespInMiddle():void {
			var eval:Autoevaluator = AutoevaluatorManager.getInstance().getAutoevaluator(system);
			var str1:String = "Hello world, how are you?";
			var str2:String = "Hello world and flex, how are you?";
			var result:Evaluation = eval.evaluate(str1, str2);

			assertEquals("1st rating", "right", result.words.getItemAt(0).rating);
			assertEquals("1st word", "hello", result.words.getItemAt(0).word);
			assertEquals("1st startIndex", 0, result.words.getItemAt(0).startIndex);

			assertEquals("2nd rating", "right", result.words.getItemAt(1).rating);
			assertEquals("2nd word", "world", result.words.getItemAt(1).word);
			assertEquals("2nd startIndex", 6, result.words.getItemAt(1).startIndex);

			assertEquals("3th rating", "right", result.words.getItemAt(2).rating);
			assertEquals("3th word", "how", result.words.getItemAt(2).word);
			assertEquals("3th startIndex", 21, result.words.getItemAt(2).startIndex);

			assertEquals("4th rating", "right", result.words.getItemAt(3).rating);
			assertEquals("4th word", "are", result.words.getItemAt(3).word);
			assertEquals("4th startIndex", 25, result.words.getItemAt(3).startIndex);

			assertEquals("5th rating", "right", result.words.getItemAt(4).rating);
			assertEquals("5th word", "you", result.words.getItemAt(4).word);
			assertEquals("5th startIndex", 29, result.words.getItemAt(4).startIndex);
			
			assertEquals("Max score", 80, result.maxScore);
			assertEquals("Min score", 80, result.minScore);
		}

		public function testRemoveWordsRespInMiddle():void {
			var eval:Autoevaluator = AutoevaluatorManager.getInstance().getAutoevaluator(system);
			var str1:String = "Hello world, how are you?";
			var str2:String = "Hello, how are you?";
			var result:Evaluation = eval.evaluate(str1, str2);

			assertEquals("1st rating", "right", result.words.getItemAt(0).rating);
			assertEquals("1st word", "hello", result.words.getItemAt(0).word);
			assertEquals("1st startIndex", 0, result.words.getItemAt(0).startIndex);

			assertEquals("2nd rating", "wrong", result.words.getItemAt(1).rating);
			assertEquals("2nd word", "world", result.words.getItemAt(1).word);
			assertEquals("2nd startIndex", 6, result.words.getItemAt(1).startIndex);

			assertEquals("3th rating", "right", result.words.getItemAt(2).rating);
			assertEquals("3th word", "how", result.words.getItemAt(2).word);
			assertEquals("3th startIndex", 6, result.words.getItemAt(2).startIndex);

			assertEquals("4th rating", "right", result.words.getItemAt(3).rating);
			assertEquals("4th word", "are", result.words.getItemAt(3).word);
			assertEquals("4th startIndex", 10, result.words.getItemAt(3).startIndex);

			assertEquals("5th rating", "right", result.words.getItemAt(4).rating);
			assertEquals("5th word", "you", result.words.getItemAt(4).word);
			assertEquals("5th startIndex", 14, result.words.getItemAt(4).startIndex);
			
			assertEquals("Max score", 80, result.maxScore);
			assertEquals("Min score", 80, result.minScore);
		}

		public function testUnknownWordRespInMiddle():void {
			var eval:Autoevaluator = AutoevaluatorManager.getInstance().getAutoevaluator(system);
			var str1:String = "Hello world, how are you?";
			var str2:String = "Hello _, how are you?";
			var result:Evaluation = eval.evaluate(str1, str2);

			assertEquals("1st rating", "right", result.words.getItemAt(0).rating);
			assertEquals("1st word", "hello", result.words.getItemAt(0).word);
			assertEquals("1st startIndex", 0, result.words.getItemAt(0).startIndex);

			assertEquals("2nd rating", "wrong", result.words.getItemAt(1).rating);
			assertEquals("2nd word", "world", result.words.getItemAt(1).word);
			assertEquals("2nd startIndex", 6, result.words.getItemAt(1).startIndex);

			assertEquals("3th rating", "right", result.words.getItemAt(2).rating);
			assertEquals("3th word", "how", result.words.getItemAt(2).word);
			assertEquals("3th startIndex", 8, result.words.getItemAt(2).startIndex);

			assertEquals("4th rating", "right", result.words.getItemAt(3).rating);
			assertEquals("4th word", "are", result.words.getItemAt(3).word);
			assertEquals("4th startIndex", 12, result.words.getItemAt(3).startIndex);

			assertEquals("5th rating", "right", result.words.getItemAt(4).rating);
			assertEquals("5th word", "you", result.words.getItemAt(4).word);
			assertEquals("5th startIndex", 16, result.words.getItemAt(4).startIndex);
			
			assertEquals("Max score", 80, result.maxScore);
			assertEquals("Min score", 80, result.minScore);
		}

		public function testDifferentStrings():void {
			var eval:Autoevaluator = AutoevaluatorManager.getInstance().getAutoevaluator(system);
			var str1:String = "Hello world, how are you?";
			var str2:String = "This is Babelia";
			var result:Evaluation = eval.evaluate(str1, str2);

			assertEquals("1st rating", "wrong", result.words.getItemAt(0).rating);
			assertEquals("1st word", "hello", result.words.getItemAt(0).word);
			assertEquals("1st startIndex", 0, result.words.getItemAt(0).startIndex);

			assertEquals("2nd rating", "wrong", result.words.getItemAt(1).rating);
			assertEquals("2nd word", "world", result.words.getItemAt(1).word);
			assertEquals("2nd startIndex", 0, result.words.getItemAt(1).startIndex);

			assertEquals("3th rating", "wrong", result.words.getItemAt(2).rating);
			assertEquals("3th word", "how", result.words.getItemAt(2).word);
			assertEquals("3th startIndex", 0, result.words.getItemAt(2).startIndex);

			assertEquals("4th rating", "wrong", result.words.getItemAt(3).rating);
			assertEquals("4th word", "are", result.words.getItemAt(3).word);
			assertEquals("4th startIndex", 0, result.words.getItemAt(3).startIndex);

			assertEquals("5th rating", "wrong", result.words.getItemAt(4).rating);
			assertEquals("5th word", "you", result.words.getItemAt(4).word);
			assertEquals("5th startIndex", 0, result.words.getItemAt(4).startIndex);
			
			assertEquals("Max score", 0, result.maxScore);
			assertEquals("Min score", 0, result.minScore);
		}

		public function testRepeatReplaceWordResp():void {
			var eval:Autoevaluator = AutoevaluatorManager.getInstance().getAutoevaluator(system);
			var str1:String = "Hello world, how are you?";
			var str2:String = "Hello world hello are you";
			var result:Evaluation = eval.evaluate(str1, str2);

			assertEquals("1st rating", "right", result.words.getItemAt(0).rating);
			assertEquals("1st word", "hello", result.words.getItemAt(0).word);
			assertEquals("1st startIndex", 0, result.words.getItemAt(0).startIndex);

			assertEquals("2nd rating", "right", result.words.getItemAt(1).rating);
			assertEquals("2nd word", "world", result.words.getItemAt(1).word);
			assertEquals("2nd startIndex", 6, result.words.getItemAt(1).startIndex);

			assertEquals("3th rating", "wrong", result.words.getItemAt(2).rating);
			assertEquals("3th word", "how", result.words.getItemAt(2).word);
			assertEquals("3th startIndex", 12, result.words.getItemAt(2).startIndex);

			assertEquals("4th rating", "right", result.words.getItemAt(3).rating);
			assertEquals("4th word", "are", result.words.getItemAt(3).word);
			assertEquals("4th startIndex", 18, result.words.getItemAt(3).startIndex);

			assertEquals("5th rating", "right", result.words.getItemAt(4).rating);
			assertEquals("5th word", "you", result.words.getItemAt(4).word);
			assertEquals("5th startIndex", 22, result.words.getItemAt(4).startIndex);
			
			assertEquals("Max score", 80, result.maxScore);
			assertEquals("Min score", 80, result.minScore);
		}

		public function testRepeatWordsResp():void {
			var eval:Autoevaluator = AutoevaluatorManager.getInstance().getAutoevaluator(system);
			var str1:String = "Hello world, how are you?";
			var str2:String = "Hello world how hello world are you";
			var result:Evaluation = eval.evaluate(str1, str2);

			assertEquals("1st rating", "right", result.words.getItemAt(0).rating);
			assertEquals("1st word", "hello", result.words.getItemAt(0).word);
			assertEquals("1st startIndex", 0, result.words.getItemAt(0).startIndex);

			assertEquals("2nd rating", "right", result.words.getItemAt(1).rating);
			assertEquals("2nd word", "world", result.words.getItemAt(1).word);
			assertEquals("2nd startIndex", 6, result.words.getItemAt(1).startIndex);

			assertEquals("3th rating", "right", result.words.getItemAt(2).rating);
			assertEquals("3th word", "how", result.words.getItemAt(2).word);
			assertEquals("3th startIndex", 12, result.words.getItemAt(2).startIndex);

			assertEquals("4th rating", "right", result.words.getItemAt(3).rating);
			assertEquals("4th word", "are", result.words.getItemAt(3).word);
			assertEquals("4th startIndex", 28, result.words.getItemAt(3).startIndex);

			assertEquals("5th rating", "right", result.words.getItemAt(4).rating);
			assertEquals("5th word", "you", result.words.getItemAt(4).word);
			assertEquals("5th startIndex", 32, result.words.getItemAt(4).startIndex);
			
			assertEquals("Max score", 80, result.maxScore);
			assertEquals("Min score", 80, result.minScore);
		}

		public function testRepeatWordsRespAtBegin():void {
			var eval:Autoevaluator = AutoevaluatorManager.getInstance().getAutoevaluator(system);
			var str1:String = "Hello world, how are you?";
			var str2:String = "Hello world hello world how are you";
			var result:Evaluation = eval.evaluate(str1, str2);

			assertEquals("1st rating", "right", result.words.getItemAt(0).rating);
			assertEquals("1st word", "hello", result.words.getItemAt(0).word);
			assertEquals("1st startIndex", 0, result.words.getItemAt(0).startIndex);

			assertEquals("2nd rating", "right", result.words.getItemAt(1).rating);
			assertEquals("2nd word", "world", result.words.getItemAt(1).word);
			assertEquals("2nd startIndex", 6, result.words.getItemAt(1).startIndex);

			assertEquals("3th rating", "right", result.words.getItemAt(2).rating);
			assertEquals("3th word", "how", result.words.getItemAt(2).word);
			assertEquals("3th startIndex", 24, result.words.getItemAt(2).startIndex);

			assertEquals("4th rating", "right", result.words.getItemAt(3).rating);
			assertEquals("4th word", "are", result.words.getItemAt(3).word);
			assertEquals("4th startIndex", 28, result.words.getItemAt(3).startIndex);

			assertEquals("5th rating", "right", result.words.getItemAt(4).rating);
			assertEquals("5th word", "you", result.words.getItemAt(4).word);
			assertEquals("5th startIndex", 32, result.words.getItemAt(4).startIndex);
			
			assertEquals("Max score", 80, result.maxScore);
			assertEquals("Min score", 80, result.minScore);
		}

		public function testRepeatWordsTogetherResp():void {
			var eval:Autoevaluator = AutoevaluatorManager.getInstance().getAutoevaluator(system);
			var str1:String = "Hello world, how are you?";
			var str2:String = "Hello world world how are you";
			var result:Evaluation = eval.evaluate(str1, str2);

			assertEquals("1st rating", "right", result.words.getItemAt(0).rating);
			assertEquals("1st word", "hello", result.words.getItemAt(0).word);
			assertEquals("1st startIndex", 0, result.words.getItemAt(0).startIndex);

			assertEquals("2nd rating", "right", result.words.getItemAt(1).rating);
			assertEquals("2nd word", "world", result.words.getItemAt(1).word);
			assertEquals("2nd startIndex", 6, result.words.getItemAt(1).startIndex);

			assertEquals("3th rating", "right", result.words.getItemAt(2).rating);
			assertEquals("3th word", "how", result.words.getItemAt(2).word);
			assertEquals("3th startIndex", 18, result.words.getItemAt(2).startIndex);

			assertEquals("4th rating", "right", result.words.getItemAt(3).rating);
			assertEquals("4th word", "are", result.words.getItemAt(3).word);
			assertEquals("4th startIndex", 22, result.words.getItemAt(3).startIndex);

			assertEquals("5th rating", "right", result.words.getItemAt(4).rating);
			assertEquals("5th word", "you", result.words.getItemAt(4).word);
			assertEquals("5th startIndex", 26, result.words.getItemAt(4).startIndex);
			
			assertEquals("Max score", 90, result.maxScore);
			assertEquals("Min score", 90, result.minScore);
		}

		public function testUnknownWordExerInMiddle():void {
			var eval:Autoevaluator = AutoevaluatorManager.getInstance().getAutoevaluator(system);
			var str1:String = "Hello _ how are you?";
			var str2:String = "Hello world and flex how are you";
			var result:Evaluation = eval.evaluate(str1, str2);

			assertEquals("1st rating", "right", result.words.getItemAt(0).rating);
			assertEquals("1st word", "hello", result.words.getItemAt(0).word);
			assertEquals("1st startIndex", 0, result.words.getItemAt(0).startIndex);

			assertEquals("2nd rating", "unknown", result.words.getItemAt(1).rating);
			assertEquals("2nd word", "_", result.words.getItemAt(1).word);
			assertEquals("2nd startIndex", 6, result.words.getItemAt(1).startIndex);

			assertEquals("3th rating", "right", result.words.getItemAt(2).rating);
			assertEquals("3th word", "how", result.words.getItemAt(2).word);
			assertEquals("3th startIndex", 21, result.words.getItemAt(2).startIndex);

			assertEquals("4th rating", "right", result.words.getItemAt(3).rating);
			assertEquals("4th word", "are", result.words.getItemAt(3).word);
			assertEquals("4th startIndex", 25, result.words.getItemAt(3).startIndex);

			assertEquals("5th rating", "right", result.words.getItemAt(4).rating);
			assertEquals("5th word", "you", result.words.getItemAt(4).word);
			assertEquals("5th startIndex", 29, result.words.getItemAt(4).startIndex);
			
			assertEquals("Max score", 100, result.maxScore);
			assertEquals("Min score", 80, result.minScore);
		}

		public function testSameStringsRepeatWordsExer():void {
			var eval:Autoevaluator = AutoevaluatorManager.getInstance().getAutoevaluator(system);
			var str1:String = "Hello world hello flex";
			var str2:String = "Hello world hello flex";
			var result:Evaluation = eval.evaluate(str1, str2);

			assertEquals("1st rating", "right", result.words.getItemAt(0).rating);
			assertEquals("1st word", "hello", result.words.getItemAt(0).word);
			assertEquals("1st startIndex", 0, result.words.getItemAt(0).startIndex);

			assertEquals("2nd rating", "right", result.words.getItemAt(1).rating);
			assertEquals("2nd word", "world", result.words.getItemAt(1).word);
			assertEquals("2nd startIndex", 6, result.words.getItemAt(1).startIndex);

			assertEquals("3th rating", "right", result.words.getItemAt(2).rating);
			assertEquals("3th word", "hello", result.words.getItemAt(2).word);
			assertEquals("3th startIndex", 12, result.words.getItemAt(2).startIndex);

			assertEquals("4th rating", "right", result.words.getItemAt(3).rating);
			assertEquals("4th word", "flex", result.words.getItemAt(3).word);
			assertEquals("4th startIndex", 18, result.words.getItemAt(3).startIndex);
			
			assertEquals("Max score", 100, result.maxScore);
			assertEquals("Min score", 100, result.minScore);
		}
		
		public function testDifferentWordCount():void {
			var eval:Autoevaluator = AutoevaluatorManager.getInstance().getAutoevaluator(system);
			var str1:String = "Hello world, how are you?";
			var str2:String = "Hello";
			var result:Evaluation = eval.evaluate(str1, str2);

			assertEquals("1st rating", "right", result.words.getItemAt(0).rating);
			assertEquals("1st word", "hello", result.words.getItemAt(0).word);
			assertEquals("1st startIndex", 0, result.words.getItemAt(0).startIndex);

			assertEquals("2nd rating", "wrong", result.words.getItemAt(1).rating);
			assertEquals("2nd word", "world", result.words.getItemAt(1).word);
			assertEquals("2nd startIndex", 6, result.words.getItemAt(1).startIndex);

			assertEquals("3th rating", "wrong", result.words.getItemAt(2).rating);
			assertEquals("3th word", "how", result.words.getItemAt(2).word);
			assertEquals("3th startIndex", 6, result.words.getItemAt(2).startIndex);

			assertEquals("4th rating", "wrong", result.words.getItemAt(3).rating);
			assertEquals("4th word", "are", result.words.getItemAt(3).word);
			assertEquals("4th startIndex", 6, result.words.getItemAt(3).startIndex);
			
			assertEquals("4th rating", "wrong", result.words.getItemAt(4).rating);
			assertEquals("4th word", "you", result.words.getItemAt(4).word);
			assertEquals("4th startIndex", 6, result.words.getItemAt(4).startIndex);
			
			assertEquals("Max score", 20, result.maxScore);
			assertEquals("Min score", 20, result.minScore);
		}
		
		public function testSamePartOfWord():void {
			var eval:Autoevaluator = AutoevaluatorManager.getInstance().getAutoevaluator(system);
			var str1:String = "Hello world, how are you?";
			var str2:String = "ho";
			var result:Evaluation = eval.evaluate(str1, str2);

			assertEquals("1st rating", "wrong", result.words.getItemAt(0).rating);
			assertEquals("1st word", "hello", result.words.getItemAt(0).word);
			assertEquals("1st startIndex", 0, result.words.getItemAt(0).startIndex);

			assertEquals("2nd rating", "wrong", result.words.getItemAt(1).rating);
			assertEquals("2nd word", "world", result.words.getItemAt(1).word);
			assertEquals("2nd startIndex", 0, result.words.getItemAt(1).startIndex);

			assertEquals("3th rating", "wrong", result.words.getItemAt(2).rating);
			assertEquals("3th word", "how", result.words.getItemAt(2).word);
			assertEquals("3th startIndex", 0, result.words.getItemAt(2).startIndex);

			assertEquals("4th rating", "wrong", result.words.getItemAt(3).rating);
			assertEquals("4th word", "are", result.words.getItemAt(3).word);
			assertEquals("4th startIndex", 0, result.words.getItemAt(3).startIndex);
			
			assertEquals("5th rating", "wrong", result.words.getItemAt(4).rating);
			assertEquals("5th word", "you", result.words.getItemAt(4).word);
			assertEquals("5th startIndex", 0, result.words.getItemAt(4).startIndex);
			
			assertEquals("Max score", 0, result.maxScore);
			assertEquals("Min score", 0, result.minScore);
		}
		
		public function testSamePartOfWordBeginningExerciseStr():void {
			var eval:Autoevaluator = AutoevaluatorManager.getInstance().getAutoevaluator(system);
			var str1:String = "a standard converted message from spinvox";
			var str2:String = "proba";
			var result:Evaluation = eval.evaluate(str1, str2);

			assertEquals("1st rating", "wrong", result.words.getItemAt(0).rating);
			assertEquals("1st word", "a", result.words.getItemAt(0).word);
			assertEquals("1st startIndex", 0, result.words.getItemAt(0).startIndex);

			assertEquals("2nd rating", "wrong", result.words.getItemAt(1).rating);
			assertEquals("2nd word", "standard", result.words.getItemAt(1).word);
			assertEquals("2nd startIndex", 0, result.words.getItemAt(1).startIndex);

			assertEquals("3th rating", "wrong", result.words.getItemAt(2).rating);
			assertEquals("3th word", "converted", result.words.getItemAt(2).word);
			assertEquals("3th startIndex", 0, result.words.getItemAt(2).startIndex);

			assertEquals("4th rating", "wrong", result.words.getItemAt(3).rating);
			assertEquals("4th word", "message", result.words.getItemAt(3).word);
			assertEquals("4th startIndex", 0, result.words.getItemAt(3).startIndex);
			
			assertEquals("5th rating", "wrong", result.words.getItemAt(4).rating);
			assertEquals("5th word", "from", result.words.getItemAt(4).word);
			assertEquals("5th startIndex", 0, result.words.getItemAt(4).startIndex);
			
			assertEquals("6th rating", "wrong", result.words.getItemAt(5).rating);
			assertEquals("6th word", "spinvox", result.words.getItemAt(5).word);
			assertEquals("6th startIndex", 0, result.words.getItemAt(5).startIndex);
			
			assertEquals("Max score", 0, result.maxScore);
			assertEquals("Min score", 0, result.minScore);
		}
		
		public function testSamePartOfWordMiddleExerciseStr():void {
			var eval:Autoevaluator = AutoevaluatorManager.getInstance().getAutoevaluator(system);
			var str1:String = "This is a standard converted message from spinvox";
			var str2:String = "proba";
			var result:Evaluation = eval.evaluate(str1, str2);

			assertEquals("1st rating", "wrong", result.words.getItemAt(0).rating);
			assertEquals("1st word", "this", result.words.getItemAt(0).word);
			assertEquals("1st startIndex", 0, result.words.getItemAt(0).startIndex);

			assertEquals("2nd rating", "wrong", result.words.getItemAt(1).rating);
			assertEquals("2nd word", "is", result.words.getItemAt(1).word);
			assertEquals("2nd startIndex", 0, result.words.getItemAt(1).startIndex);

			assertEquals("3th rating", "wrong", result.words.getItemAt(2).rating);
			assertEquals("3th word", "a", result.words.getItemAt(2).word);
			assertEquals("3th startIndex", 0, result.words.getItemAt(2).startIndex);

			assertEquals("4th rating", "wrong", result.words.getItemAt(3).rating);
			assertEquals("4th word", "standard", result.words.getItemAt(3).word);
			assertEquals("4th startIndex", 0, result.words.getItemAt(3).startIndex);
			
			assertEquals("5th rating", "wrong", result.words.getItemAt(4).rating);
			assertEquals("5th word", "converted", result.words.getItemAt(4).word);
			assertEquals("5th startIndex", 0, result.words.getItemAt(4).startIndex);
			
			assertEquals("6th rating", "wrong", result.words.getItemAt(5).rating);
			assertEquals("6th word", "message", result.words.getItemAt(5).word);
			assertEquals("6th startIndex", 0, result.words.getItemAt(5).startIndex);
			
			assertEquals("7th rating", "wrong", result.words.getItemAt(6).rating);
			assertEquals("7th word", "from", result.words.getItemAt(6).word);
			assertEquals("7th startIndex", 0, result.words.getItemAt(6).startIndex);
			
			assertEquals("8th rating", "wrong", result.words.getItemAt(7).rating);
			assertEquals("8th word", "spinvox", result.words.getItemAt(7).word);
			assertEquals("8th startIndex", 0, result.words.getItemAt(7).startIndex);
			
			assertEquals("Max score", 0, result.maxScore);
			assertEquals("Min score", 0, result.minScore);
		}
		
		public function testSamePartOfWordMiddleExerciseAndWordStr():void {
			var eval:Autoevaluator = AutoevaluatorManager.getInstance().getAutoevaluator(system);
			var str1:String = "This is a standard converted message from spinvox";
			var str2:String = "proba a";
			var result:Evaluation = eval.evaluate(str1, str2);

			assertEquals("1st rating", "wrong", result.words.getItemAt(0).rating);
			assertEquals("1st word", "this", result.words.getItemAt(0).word);
			assertEquals("1st startIndex", 0, result.words.getItemAt(0).startIndex);

			assertEquals("2nd rating", "wrong", result.words.getItemAt(1).rating);
			assertEquals("2nd word", "is", result.words.getItemAt(1).word);
			assertEquals("2nd startIndex", 0, result.words.getItemAt(1).startIndex);

			assertEquals("3th rating", "right", result.words.getItemAt(2).rating);
			assertEquals("3th word", "a", result.words.getItemAt(2).word);
			assertEquals("3th startIndex", 6, result.words.getItemAt(2).startIndex);

			assertEquals("4th rating", "wrong", result.words.getItemAt(3).rating);
			assertEquals("4th word", "standard", result.words.getItemAt(3).word);
			assertEquals("4th startIndex", 8, result.words.getItemAt(3).startIndex);
			
			assertEquals("5th rating", "wrong", result.words.getItemAt(4).rating);
			assertEquals("5th word", "converted", result.words.getItemAt(4).word);
			assertEquals("5th startIndex", 8, result.words.getItemAt(4).startIndex);
			
			assertEquals("6th rating", "wrong", result.words.getItemAt(5).rating);
			assertEquals("6th word", "message", result.words.getItemAt(5).word);
			assertEquals("6th startIndex", 8, result.words.getItemAt(5).startIndex);
			
			assertEquals("7th rating", "wrong", result.words.getItemAt(6).rating);
			assertEquals("7th word", "from", result.words.getItemAt(6).word);
			assertEquals("7th startIndex", 8, result.words.getItemAt(6).startIndex);
			
			assertEquals("8th rating", "wrong", result.words.getItemAt(7).rating);
			assertEquals("8th word", "spinvox", result.words.getItemAt(7).word);
			assertEquals("8th startIndex", 8, result.words.getItemAt(7).startIndex);
			
			assertEquals("Max score", 12, result.maxScore);
			assertEquals("Min score", 12, result.minScore);
		}
		
		public function testPhrase1():void {
			var eval:Autoevaluator = AutoevaluatorManager.getInstance().getAutoevaluator(system);
			var str1:String = "Can’t you just use your sleeve";
			var str2:String = "Can’t you just use you sleeve";
			var result:Evaluation = eval.evaluate(str1, str2);

			assertEquals("1st rating", "right", result.words.getItemAt(0).rating);
			assertEquals("1st word", "can’t", result.words.getItemAt(0).word);
			assertEquals("1st startIndex", 0, result.words.getItemAt(0).startIndex);

			assertEquals("2th rating", "right", result.words.getItemAt(1).rating);
			assertEquals("2th word", "you", result.words.getItemAt(1).word);
			assertEquals("2th startIndex", 6, result.words.getItemAt(1).startIndex);

			assertEquals("3th rating", "right", result.words.getItemAt(2).rating);
			assertEquals("3th word", "just", result.words.getItemAt(2).word);
			assertEquals("3th startIndex", 10, result.words.getItemAt(2).startIndex);
			
			assertEquals("4th rating", "right", result.words.getItemAt(3).rating);
			assertEquals("4th word", "use", result.words.getItemAt(3).word);
			assertEquals("4th startIndex", 15, result.words.getItemAt(3).startIndex);
			
			assertEquals("5th rating", "wrong", result.words.getItemAt(4).rating);
			assertEquals("5th word", "your", result.words.getItemAt(4).word);
			assertEquals("5th startIndex", 19, result.words.getItemAt(4).startIndex);
			
			assertEquals("6th rating", "right", result.words.getItemAt(5).rating);
			assertEquals("6th word", "sleeve", result.words.getItemAt(5).word);
			assertEquals("6th startIndex", 23, result.words.getItemAt(5).startIndex);
			
			assertEquals("Max score", 83, result.maxScore);
			assertEquals("Min score", 83, result.minScore);
		}

		/*public function testPhrase2():void {
			var eval:Autoevaluator = AutoevaluatorManager.getInstance().getAutoevaluator(system);
			var str1:String = "Can’t you just use your sleeve";
			var str2:String = "You just can’t use your sleeve";
			var result:Evaluation = eval.evaluate(str1, str2);

			assertEquals("1st rating", "right", result.words.getItemAt(0).rating);
			assertEquals("1st word", "can’t", result.words.getItemAt(0).word);
			assertEquals("1st startIndex", 9, result.words.getItemAt(0).startIndex);

			assertEquals("2th rating", "wrong", result.words.getItemAt(1).rating);
			assertEquals("2th word", "you", result.words.getItemAt(1).word);
			assertEquals("2th startIndex", 15, result.words.getItemAt(1).startIndex);

			assertEquals("3th rating", "wrong", result.words.getItemAt(2).rating);
			assertEquals("3th word", "just", result.words.getItemAt(2).word);
			assertEquals("3th startIndex", 15, result.words.getItemAt(2).startIndex);
			
			assertEquals("4th rating", "right", result.words.getItemAt(3).rating);
			assertEquals("4th word", "use", result.words.getItemAt(3).word);
			assertEquals("4th startIndex", 15, result.words.getItemAt(3).startIndex);
			
			assertEquals("5th rating", "right", result.words.getItemAt(4).rating);
			assertEquals("5th word", "your", result.words.getItemAt(4).word);
			assertEquals("5th startIndex", 19, result.words.getItemAt(4).startIndex);
			
			assertEquals("6th rating", "right", result.words.getItemAt(5).rating);
			assertEquals("6th word", "sleeve", result.words.getItemAt(5).word);
			assertEquals("6th startIndex", 24, result.words.getItemAt(5).startIndex);
			
			assertEquals("Max score", 58, result.maxScore);
			assertEquals("Min score", 58, result.minScore);
		}*/
		
		public function testPhrase2():void {
			var eval:Autoevaluator = AutoevaluatorManager.getInstance().getAutoevaluator(system);
			var str1:String = "Can’t you just use your sleeve";
			var str2:String = "Can’t you just don’t use your sleeve";
			var result:Evaluation = eval.evaluate(str1, str2);

			assertEquals("1st rating", "right", result.words.getItemAt(0).rating);
			assertEquals("1st word", "can’t", result.words.getItemAt(0).word);
			assertEquals("1st startIndex", 0, result.words.getItemAt(0).startIndex);

			assertEquals("2th rating", "right", result.words.getItemAt(1).rating);
			assertEquals("2th word", "you", result.words.getItemAt(1).word);
			assertEquals("2th startIndex", 6, result.words.getItemAt(1).startIndex);

			assertEquals("3th rating", "right", result.words.getItemAt(2).rating);
			assertEquals("3th word", "just", result.words.getItemAt(2).word);
			assertEquals("3th startIndex", 10, result.words.getItemAt(2).startIndex);
			
			assertEquals("4th rating", "right", result.words.getItemAt(3).rating);
			assertEquals("4th word", "use", result.words.getItemAt(3).word);
			assertEquals("4th startIndex", 21, result.words.getItemAt(3).startIndex);
			
			assertEquals("5th rating", "right", result.words.getItemAt(4).rating);
			assertEquals("5th word", "your", result.words.getItemAt(4).word);
			assertEquals("5th startIndex", 25, result.words.getItemAt(4).startIndex);
			
			assertEquals("6th rating", "right", result.words.getItemAt(5).rating);
			assertEquals("6th word", "sleeve", result.words.getItemAt(5).word);
			assertEquals("6th startIndex", 30, result.words.getItemAt(5).startIndex);
			
			assertEquals("Max score", 91, result.maxScore);
			assertEquals("Min score", 91, result.minScore);
		}
	}
}