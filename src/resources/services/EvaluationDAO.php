<?php

require_once ('Datasource.php');
require_once ('Config.php');
require_once ('EvaluationVO.php');
require_once ('Mailer.php');

class EvaluationDAO {
	
	private $conn;
	
	private $imagePath;
	private $red5Path;
	
	private $evaluationFolder = '';
	private $exerciseFolder = '';
	private $responseFolder = '';
	
	public function EvaluationDAO(){
		$settings = new Config ( );
		$this->imagePath = $settings->imagePath;
		$this->red5Path = $settings->red5Path;
		$this->conn = new Datasource ( $settings->host, $settings->db_name, $settings->db_username, $settings->db_password );
	}
	
	public function getResponsesWaitingAssessment($userId) {
		$sql = "SELECT prefValue FROM preferences WHERE (prefName='trial.threshold') ";
		
		$result = $this->conn->_execute ( $sql );
		$row = $this->conn->_nextRow ( $result );
		if($row)
			$evaluationThreshold = $row [0];
		
		$sql = "SELECT DISTINCT A.file_identifier, A.id, A.rating_amount, A.character_name, A.fk_subtitle_id, 
		                        A.adding_date, A.source, A.thumbnail_uri, A.duration, F.name, F.ID, 
		                        B.id, B.name, B.duration, B.language, B.thumbnail_uri, B.title, B.source
				FROM (response AS A INNER JOIN exercise AS B on A.fk_exercise_id = B.id) 
				     INNER JOIN users AS F on A.fk_user_id = F.ID 
		     		 LEFT OUTER JOIN evaluation AS C on C.fk_response_id = A.id
				WHERE B.status = 'Available' AND A.rating_amount < %d AND A.fk_user_id <> %d AND A.is_private = 0
				AND NOT EXISTS (SELECT *
                                FROM evaluation AS D INNER JOIN response AS E on D.fk_response_id = E.id
                                WHERE E.id = A.id AND D.fk_user_id = %d)";
		
		$searchResults = $this->_listWaitingAssessmentQuery($sql, $evaluationThreshold, $userId, $userId);

		return $searchResults;
	}
	
	private function _listWaitingAssessmentQuery($query){
		$searchResults = array();
		$result = $this->conn->_execute ( func_get_args() );
		
		while ( $row = $this->conn->_nextRow($result)){
			$temp = new EvaluationVO();
			
			$temp->responseFileIdentifier = $row[0];
			$temp->responseId = $row[1];
			$temp->responseRatingAmount = $row[2];
			$temp->responseCharacterName = $row[3];
			$temp->responseSubtitleId = $row[4];
			$temp->responseAddingDate = $row[5];
			$temp->responseSource = $row[6];
			$temp->responseThumbnailUri = $row[7];
			$temp->responseDuration = $row[8];
			
			$temp->responseUserName = $row[9];
			$temp->responseUserId = $row[10];
			
			$temp->exerciseId = $row[11];
			$temp->exerciseName = $row[12];
			$temp->exerciseDuration = $row[13];
			$temp->exerciseLanguage = $row[14];
			$temp->exerciseThumbnailUri = $row[15];
			$temp->exerciseTitle = $row[16];
			$temp->exerciseSource = $row[17];
			array_push ( $searchResults, $temp );
		}

		return $searchResults;
	}
	
	public function getResponsesAssessedToCurrentUser($userId){
		
		$sql = "SELECT A.file_identifier, A.id, A.rating_amount, A.character_name, A.fk_subtitle_id, 
		               A.adding_date, A.source, A.thumbnail_uri, A.duration, C.fk_user_id, 
		               B.id, B.name, B.duration, B.language, B.thumbnail_uri, B.title, B.source,
		               AVG(C.score_overall) AS avg_rating, AVG(C.score_intonation) AS avg_intonation, 
		               AVG(score_fluency) AS avg_fluency, AVG(score_rhythm) avg_rhythm, AVG(score_spontaneity) AS avg_spontaneity
		        FROM response AS A INNER JOIN exercise AS B ON B.id = A.fk_exercise_id
					 INNER JOIN evaluation AS C ON C.fk_response_id = A.id 
				WHERE ( A.fk_user_id = '%d' ) 
				GROUP BY B.id";
		
		$searchResults = $this->_listAssessedToCurrentUserQuery ( $sql, $userId );
		
		return $searchResults;
	}
	
	private function _listAssessedToCurrentUserQuery() {
		$searchResults = array ();
		$result = $this->conn->_execute ( func_get_args() );
		
		while ( $row = $this->conn->_nextRow ( $result ) ) {
			$temp = new EvaluationVO();		
			
			$temp->responseFileIdentifier = $row[0];
			$temp->responseId = $row[1];
			$temp->responseRatingAmount = $row[2];
			$temp->responseCharacterName = $row[3];
			$temp->responseSubtitleId = $row[4];
			$temp->responseAddingDate = $row[5];
			$temp->responseSource = $row[6];
			$temp->responseThumbnailUri = $row[7];
			$temp->responseDuration = $row[8];
			
			$temp->userId = $row[9];
			
			$temp->exerciseId = $row[10];
			$temp->exerciseName = $row[11];
			$temp->exerciseDuration = $row[12];
			$temp->exerciseLanguage = $row[13];
			$temp->exerciseThumbnailUri = $row[14];
			$temp->exerciseTitle = $row[15];
			$temp->exerciseSource = $row[16];
			
			$temp->overallScoreAverage = $row[17];
			$temp->intonationScoreAverage = $row[18];
			$temp->fluencyScoreAverage = $row[19];
			$temp->rhythmScoreAverage = $row[20];
			$temp->spontaneityScoreAverage = $row[21];
			
			array_push ( $searchResults, $temp );
		}
		
		return $searchResults;
	}
	
	public function getResponsesAssessedByCurrentUser($userId){
		$sql = "SELECT DISTINCT A.file_identifier, A.id, A.rating_amount, A.character_name, A.fk_subtitle_id, 
		               			A.adding_date, A.source, A.thumbnail_uri, A.duration, A.fk_user_id,
		               			U.name, C.fk_user_id, C.score_overall, C.score_intonation, C.score_fluency, C.score_rhythm,
		               			C.score_spontaneity, C.comment, C.adding_date,
		               			B.id, B.name, B.duration, B.language, B.thumbnail_uri, B.title, B.source 
			    FROM response AS A INNER JOIN exercise AS B ON B.id = A.fk_exercise_id  
			         INNER JOIN evaluation AS C ON C.fk_response_id = A.id
			         INNER JOIN users AS U ON U.ID = A.fk_user_id
			    WHERE (C.fk_user_id = '%d')";
		
		$searchResults = $this->_listAssessedByCurrentUserQuery ( $sql, $userId );
		
		return $searchResults;
	}
	
	private function _listAssessedByCurrentUserQuery(){
		$searchResults = array();
		$result = $this->conn->_execute(func_get_args());
		
		while ($row = $this->conn->_nextRow($result)){
			$temp = new EvaluationVO();		
			
			$temp->responseFileIdentifier = $row[0];
			$temp->responseId = $row[1];
			$temp->responseRatingAmount = $row[2];
			$temp->responseCharacterName = $row[3];
			$temp->responseSubtitleId = $row[4];
			$temp->responseAddingDate = $row[5];
			$temp->responseSource = $row[6];
			$temp->responseThumbnailUri = $row[7];
			$temp->responseDuration = $row[8];
			$temp->responseUserId = $row[9];
			$temp->responseUserName = $row[10];
			
			$temp->userId = $row[11];
			$temp->overallScore = $row[12];
			$temp->intonationScore = $row[13];
			$temp->fluencyScore = $row[14];
			$temp->rhythmScore = $row[15];
			$temp->spontaneityScore = $row[16];
			$temp->comment = $row[17];
			$temp->addingDate = $row[18];
			
			$temp->exerciseId = $row[19];
			$temp->exerciseName = $row[20];
			$temp->exerciseDuration = $row[21];
			$temp->exerciseLanguage = $row[22];
			$temp->exerciseThumbnailUri = $row[23];
			$temp->exerciseTitle = $row[24];
			$temp->exerciseSource = $row[25];
			
			array_push ( $searchResults, $temp );
		}
		
		return $searchResults;
	}
	
	public function detailsOfAssessedResponse($responseId){
		$sql = "SELECT C.name, A.score_overall, A.score_intonation, A.score_fluency, A.score_rhythm, A.score_spontaneity,
					   A.adding_date, A.comment, B.video_identifier 
			    FROM (evaluation AS A INNER JOIN users AS C ON A.fk_user_id = C.id) 
			    	 LEFT OUTER JOIN evaluation_video AS B on A.id = B.fk_evaluation_id 
				WHERE (A.fk_response_id = '%d') ";
		
		$searchResults = $this->_listDetailsOfAssessedResponseQuery ( $sql, $responseId );
		
		return $searchResults;
	}
	
	private function _listDetailsOfAssessedResponseQuery(){
		$searchResults = array();
		$result = $this->conn->_execute(func_get_args());
		
		while ($row = $this->conn->_nextRow($result)){
			$temp = new EvaluationVO();

			$temp->userName = $row[0];
			$temp->overallScore = $row[1];
			$temp->intonationScore = $row[2];
			$temp->fluencyScore = $row[3];
			$temp->rhythmScore = $row[4];
			$temp->spontaneityScore = $row[5];
			$temp->addingDate = $row[6];
			$temp->comment = $row[7];
			$temp->evaluationVideoFileIdentifier = $row[8];

			array_push ( $searchResults, $temp );
		}
		
		return $searchResults;
	}
	
	public function getEvaluationChartData($responseId){
		$sql = "SELECT U.name, E.score_overall, E.comment 
				FROM evaluation AS E INNER JOIN users AS U ON E.fk_user_id = U.ID 
				     INNER JOIN response AS R ON E.fk_response_id = R.id 
				WHERE (R.id = '%d') ";
		
		$searchResults = $this->_listEvaluationChartDataQuery($sql, $responseId);
	
		return $searchResults;
	}
	
	private function _listEvaluationChartDataQuery(){
		$searchResults = array();
		$result = $this->conn->_execute(func_get_args());
		
		while ($row = $this->conn->_nextRow($result)){
			$temp = new EvaluationVO();
			
			$temp->userName = $row[0];
			$temp->overallScore = $row[1];
			$temp->comment = $row[2];
			
			array_push ( $searchResults, $temp );
		}
		return $searchResults;
	}	
	
	public function addAssessment(EvaluationVO $evalData){
		$sql = "INSERT INTO evaluation (fk_response_id, fk_user_id, score_overall, score_intonation, score_fluency, score_rhythm, score_spontaneity, comment, adding_date) VALUES (";
		$sql = $sql . "'%d', ";
		$sql = $sql . "'%d', ";
		$sql = $sql . "'%d', ";
		$sql = $sql . "'%d', ";
		$sql = $sql . "'%d', ";
		$sql = $sql . "'%d', ";
		$sql = $sql . "'%d', ";
		$sql = $sql . "'%s', NOW() )";
		
		$result = $this->_databaseUpdate ( $sql, $evalData->responseId, $evalData->userId, $evalData->overallScore, 
												 $evalData->intonationScore, $evalData->fluencyScore, $evalData->rhythmScore, 
												 $evalData->spontaneityScore, $evalData->comment );
		
		$sql = "SELECT last_insert_id()";
		$result = $this->conn->_execute ( $sql );
		
		$row = $this->conn->_nextRow ( $result );
		if ($row) {
			$evaluationId = $row[0];
			//The evaluation data was inserted successfully. Update the evaluation count on response table.
			$update = $this->updateResponseRatingAmount($evalData->responseId);
			if($update){
				//Nevermind the result of the mail sending what's important is the DB data
				$this->notifyUserAboutResponseBeingAssessed($evalData);
				
				return $evaluationId;
			} else {
				return false;
			}
		} else {
			return false;
		}
	}
	
	public function addVideoAssessment(EvaluationVO $evalData){
		set_time_limit(0);
		$evaluationId = $this->addAssessment($evalData);
		if ($evaluationId){

			$this->_getResourceDirectories();
			$duration = $this->calculateVideoDuration($evalData->evaluationVideoFileIdentifier);
			$this->takeRandomSnapshot($evalData->evaluationVideoFileIdentifier, $evalData->evaluationVideoFileIdentifier);
			
			$sql = "INSERT INTO evaluation_video (fk_evaluation_id, video_identifier, source, thumbnail_uri) VALUES (";
			$sql = $sql . "'%d', ";
			$sql = $sql . "'%s', ";
			$sql = $sql . "'Red5', ";
			$sql = $sql . "'%s')";
			$result = $this->_databaseUpdate ( $sql, $evaluationId, $evalData->evaluationVideoFileIdentifier, $evalData->evaluationVideoFileIdentifier.'.jpg' );
			
			$sql = "SELECT last_insert_id()";
			
			$result = $this->conn->_execute ( $sql );
			$row = $this->conn->_nextRow ( $result );
			if ($row) {
				return $evaluationId;
			} else {
				return false;
			}
		} else {
			return false;
		}
	}
	
	private function takeRandomSnapshot($videoFileName,$outputImageName){
		$videoPath  = $this->red5Path .'/'. $this->evaluationFolder .'/'. $videoFileName . '.flv';
		// where you'll save the image
		$imagePath  = $this->imagePath .'/'. $outputImageName . '.jpg';
		// default time to get the image
		$second = 1;

		// get the duration and a random place within that
		$resultduration = (exec("ffmpeg -i $videoPath 2>&1",$cmd));
		if (preg_match('/Duration: ((\d+):(\d+):(\d+))/s', implode($cmd), $time)) {
			$total = ($time[2] * 3600) + ($time[3] * 60) + $time[4];
			$second = rand(1, ($total - 1));
		}
		$resultsnap = (exec("ffmpeg -y -i $videoPath -r 1 -ss $second -vframes 1 -r 1 -s 120x90 $imagePath 2>&1",$cmd));
		return $resultsnap;
	}
	
	private function calculateVideoDuration($videoFileName){
		$videoPath  = $this->red5Path .'/'. $this->evaluationFolder .'/'. $videoFileName .'.flv';
		$total = 0;
		
		$resultduration = (exec("ffmpeg -i $videoPath 2>&1",$cmd));
		if (preg_match('/Duration: ((\d+):(\d+):(\d+))/s', implode($cmd), $time)) {
			$total = ($time[2] * 3600) + ($time[3] * 60) + $time[4];
		}
		return $total;
	}
	
	private function _getResourceDirectories(){
		$sql = "SELECT prefValue FROM preferences
				WHERE (prefName='exerciseFolder' OR prefName='responseFolder' OR prefName='evaluationFolder') 
				ORDER BY prefName";
		$result = $this->conn->_execute($sql);

		$row = $this->conn->_nextRow($result);
		$this->evaluationFolder = $row ? $row[0] : '';
		$row = $this->conn->_nextRow($result);
		$this->exerciseFolder = $row ? $row[0] : '';
		$row = $this->conn->_nextRow($result);
		$this->responseFolder = $row ? $row[0] : '';
	}
	
	public function notifyUserAboutResponseBeingAssessed(EvaluationVO $evaluation){
		
		$sql = "SELECT language 
				FROM user_languages 
				WHERE ( fk_user_id='%d' AND level=7 ) LIMIT 1";
		$result = $this->conn->_execute($sql, $evaluation->responseUserId);
		$row = $this->conn->_nextRow($result);
		if($row){
			$locale = $row[0];
			
			$mail = new Mailer($evaluation->responseUserName);
				
			$subject = 'Babelium Project: You have been assessed';

			$args = array(
						'DATE' => $evaluation->responseAddingDate,
						'EXERCISE_TITLE' => $evaluation->exerciseTitle,
						'EVALUATOR_NAME' => $evaluation->userName,
						'ASSESSMENT_LINK' => 'http://'.$_SERVER['HTTP_HOST'].'/Main.html#/evaluation/revise/'.$evaluation->responseFileIdentifier,
						'SIGNATURE' => 'The Babelium Project Team');

			if ( !$mail->makeTemplate("assessment_notify", $args, $locale) ) 
				return null;

			return ($mail->send($mail->txtContent, $subject, $mail->htmlContent));
			
		} else {
			return false;
		}
	}
	
	public function updateResponseRatingAmount($responseId){
		$sql = "UPDATE response SET rating_amount = (rating_amount + 1) 
		        WHERE (id = '%d')";

		return $result = $this->_databaseUpdate ( $sql, $responseId );
	}
	
	private function _databaseUpdate() {
		$result = $this->conn->_execute ( func_get_args() );
		
		return $result;
	}
	
}


?>