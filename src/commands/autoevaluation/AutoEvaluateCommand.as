package commands.autoevaluation {
	import business.AutoEvaluationDelegate;

	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;

	import events.EvaluationEvent;

	import model.DataModel;

	import modules.autoevaluation.Evaluation;
	import modules.autoevaluation.EvaluationItem;

	import mx.controls.Alert;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ObjectUtil;
	import mx.utils.StringUtil;

	import vo.TranscriptionsVO;

	public class AutoEvaluateCommand implements ICommand, IResponder {

		public function execute(event:CairngormEvent):void {
			new AutoEvaluationDelegate(this).getResponseTranscriptions((event as EvaluationEvent).responseID);
		}

		public function result(data:Object):void {
			var result:Object = data.result;
			var error:String = "";
			if(result is TranscriptionsVO) {
				var transcriptions:TranscriptionsVO = result as TranscriptionsVO;
				if(transcriptions.exerciseTranscriptionStatus.toLowerCase() != "converted") {
					if(transcriptions.exerciseTranscriptionStatus.toLowerCase() == "pending")
						error = "Your autoevaluation request is pending";
					else if(transcriptions.exerciseTranscriptionStatus.toLocaleLowerCase() == "processing")
						error = "Your autoevaluation request is being processed";
					else
						error = "Autoevaluation not available";
				} else if(transcriptions.responseTranscriptionStatus.toLocaleLowerCase() != "converted") {
					if(transcriptions.responseTranscriptionStatus.toLowerCase() == "pending")
						error = "Your autoevaluation request is pending";
					else if(transcriptions.responseTranscriptionStatus.toLocaleLowerCase() == "processing")
						error = "Your autoevaluation request is being processed";
					else
						error = "Autoevaluation not available";
				} else
					evaluate(transcriptions.responseTranscriptionSystem.toLowerCase(), transcriptions.exerciseTranscription, transcriptions.responseTranscription);
				DataModel.getInstance().autoevaluationAvailable = true;
			} else {
				error = "";
				DataModel.getInstance().autoevaluationAvailable = false;
			}
			DataModel.getInstance().autoevaluationError = error;
		}

		public function fault(info:Object):void {
			DataModel.getInstance().autoevaluationAvailable = false;
			var faultEvent:FaultEvent = FaultEvent(info);
			Alert.show("Error: " + faultEvent.message);
			trace(ObjectUtil.toString(info));
		}

		private function evaluate(system:String, exerciseStr:String, responseStr:String):void {
			switch(system) {
				case "spinvox":
					spinvoxEvaluate(exerciseStr, responseStr);
					break;
				default:
					DataModel.getInstance().autoevaluationError = "Autoevaluation not available";
			}
		}

		private function spinvoxEvaluate(exerciseStr:String, responseStr:String):void {
			try {
				//convert both strings to lower case
				exerciseStr = exerciseStr.toLowerCase();
				responseStr = responseStr.toLowerCase();

				//separate all the words and save them into an array
				var exTranscWords:Array = exerciseStr.split(" ");
				var resTranscWords:Array = responseStr.split(" ");

				//alphanumeric character, (?) after word and _
				var pattern:RegExp = /[a-zA-Z0-9_]+(\(\?\))?/;

				//remake the response string without the unwanted characters
				var resStr:String = "";
				for each(var s:String in resTranscWords) {
					//remove non alphanumeric character except (?) and _
					var res:Array = pattern.exec(s);
					resStr += res[0] + " ";
				}
				resStr = StringUtil.trim(resStr);

				//the evaluation results will be saved into this ArrayCollection
				var eval:Evaluation = new Evaluation();

				//the string that will be seached in the response string at each loop 
				var findStr:String = "";
				//the end index of the last found string
				var lastIndex:int = 0;
				//the index from where to start searching 
				var searchIndex:int = 0;

				//here starts the evaluation
				for each(var word:String in exTranscWords) {
					//remove non alphanumeric character except (?) and _
					var result:Array = pattern.exec(word);

					if(result != null)
						word = StringUtil.trim(result[0]);
					else
						word = "";

					if(word != null) {
						//if the word is _ it means that the system couldn't transcript it
						if(word != "_") {
							//if the word has (?) at the end, it means that the system couldn't understand well what was said
							if(word.indexOf("(?)") != 0)
								//ignore the (?) if it is in a word of the exercise transcription
								word = word.replace("(?)", "");
							//add the word to the string to search and see if it appears in the response transcription string
							findStr += word + " ";
							i = resStr.indexOf(StringUtil.trim(findStr), searchIndex);

							if(i != -1) {
								if(resStr.indexOf(StringUtil.trim(findStr) + "(?)") == -1) {
									//if the string with the word is in the result transcription in the correct place and it has no (?) then it is well said
									eval.addItem(word, "right", i + findStr.length - (word.length + 1));
									lastIndex = i + findStr.length;
								} else {
									//if the string with the word is in the result transcription in the correct place but it has (?) then it is not very well said
									findStr = StringUtil.trim(findStr) + "(?) ";
									eval.addItem(word, "medium", i + findStr.length - (word.length + 4));
									lastIndex = i + findStr.length + 3;
								}
							} else {
								//if the string with the word doesn't exist in the result transcription, set the new search index and search for the word alone first
								searchIndex = lastIndex;
								findStr = word + " ";
								i = resStr.indexOf(StringUtil.trim(findStr), searchIndex);

								if(i != -1) {
									if(resStr.indexOf(StringUtil.trim(findStr) + "(?)") == -1) {
										//if the word is in the result transcription in the correct place and it has no (?) then it is well said
										eval.addItem(word, "right", i + findStr.length - (word.length + 1));
										lastIndex = i + findStr.length;
									} else {
										//if the word is in the result transcription in the correct place but it has (?) then it is not very well said
										eval.addItem(word, "medium", i + findStr.length - (word.length + 1));
										lastIndex = i + findStr.length;
										findStr = StringUtil.trim(findStr) + "(?) ";
									}
								} else {
									//if the word doesn't appear in the result transcription then that word is not well said
									eval.addItem(word, "wrong", searchIndex);
									findStr = "";
								}
							}
						} else {
							//if a word in the exercise transcription is _ this part can not be rated
							searchIndex = lastIndex;
							eval.addItem(word, "unknown", searchIndex);
							findStr = "";
						}
					}
				}

				//calculate the final score
				//the score on the best 
				var maxScore:Number = 0;
				//the score in the worst
				var minScore:Number = 0;
				//the index of the previous item
				lastIndex = 0;
				//the rating of the previous item
				var lastRate:String = "right";
				for each(var item:EvaluationItem in eval.words) {
					//get the amount of words in the response transcription between the this and the previous item
					i = StringUtil.trim(resStr.substring(lastIndex, item.startIndex)).split(" ").length;

					if(item.rating == "right") {
						maxScore += 1;
						minScore += 1;

						if(lastRate == "right" || lastRate == "medium") {
							maxScore -= 0.5 * (i - 1);
							minScore -= 0.5 * (i - 1);
						}
					} else if(item.rating == "medium") {
						maxScore += 0.5;
						minScore += 0.5;

						if(lastRate == "right" || lastRate == "medium") {
							maxScore -= 0.5 * (i - 1);
							minScore -= 0.5 * (i - 1);
						}
					} else if(item.rating == "unknown") {
						maxScore += 1;
					}

					lastIndex = item.startIndex;
					lastRate = item.rating;
				}

				var i:int = StringUtil.trim(resStr.substring(lastIndex)).split(" ").length;
				if(lastRate == "right" || lastRate == "medium") {
					maxScore -= 0.5 * (i - 1);
					minScore -= 0.5 * (i - 1);
				}

				var finalMaxScore:int = maxScore / eval.words.length * 100;
				var fnalMinScore:int = minScore / eval.words.length * 100;

				eval.responseText = resStr;
				eval.maxScore = finalMaxScore;
				eval.minScore = fnalMinScore;

				//fill the datamodel with the evaluation data
				DataModel.getInstance().autoevaluationResults = eval;
				DataModel.getInstance().autoevaluationDone = true;

			} catch(e:Error) {
				DataModel.getInstance().autoevaluationDone = false;
				DataModel.getInstance().autoevaluationAvailable = false;
				DataModel.getInstance().autoevaluationError = "";
			}
		}
	}
}