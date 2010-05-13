<?php

require_once ('Datasource.php');
require_once ('Config.php');
require_once ('EvaluationVO.php');

class EvaluationDAO {
	
	private $conn;
	
	public function EvaluationDAO(){
		$settings = new Config ( );
		$this->conn = new Datasource ( $settings->host, $settings->db_name, $settings->db_username, $settings->db_password );
	}
	
	public function getResponsesWaitingAssessment($userId) {
		$sql = "SELECT prefValue FROM preferences WHERE (prefName='trial.threshold') ";
		
		$result = $this->conn->_execute ( $sql );
		$row = $this->conn->_nextRow ( $result );
		if($row)
			$evaluationThreshold = $row [0];
		
		$sql = "SELECT DISTINCT A.file_identifier, A.id, A.rating_amount, A.character_name, 
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
			$temp->responseAddingDate = $row[4];
			$temp->responseSource = $row[5];
			$temp->responseThumbnailUri = $row[6];
			$temp->responseDuration = $row[7];
			
			$temp->responseUserName = $row[8];
			$temp->responseUserId = $row[9];
			
			$temp->exerciseId = $row[10];
			$temp->exerciseName = $row[11];
			$temp->exerciseDuration = $row[12];
			$temp->exerciseLanguage = $row[13];
			$temp->exerciseThumbnailUri = $row[14];
			$temp->exerciseTitle = $row[15];
			$temp->exerciseSource = $row[16];
			array_push ( $searchResults, $temp );
		}

		return $searchResults;
	}
	
	public function getResponsesAssessedToCurrentUser($userId){
		
		$sql = "SELECT A.file_identifier, A.id, A.rating_amount, A.character_name, 
		               A.adding_date, A.source, A.thumbnail_uri, A.duration, C.fk_user_id, 
		               B.id, B.name, B.duration, B.language, B.thumbnail_uri, B.title, B.source,
		               AVG(C.score) AS avg_rating
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
			$temp->responseAddingDate = $row[4];
			$temp->responseSource = $row[5];
			$temp->responseThumbnailUri = $row[6];
			$temp->responseDuration = $row[7];
			
			$temp->userId = $row[8];
			
			$temp->exerciseId = $row[9];
			$temp->exerciseName = $row[10];
			$temp->exerciseDuration = $row[11];
			$temp->exerciseLanguage = $row[12];
			$temp->exerciseThumbnailUri = $row[13];
			$temp->exerciseTitle = $row[14];
			$temp->exerciseSource = $row[15];
			
			$temp->evaluationAverage = $row[16];
			
			array_push ( $searchResults, $temp );
		}
		
		return $searchResults;
	}
	
	public function getResponsesAssessedByCurrentUser($userId){
		$sql = "SELECT DISTINCT A.file_identifier, A.id, A.rating_amount, A.character_name, 
		               			A.adding_date, A.source, A.thumbnail_uri, A.duration, A.fk_user_id,
		               			U.name, C.fk_user_id, C.score, C.comment, C.adding_date,
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
			$temp->responseAddingDate = $row[4];
			$temp->responseSource = $row[5];
			$temp->responseThumbnailUri = $row[6];
			$temp->responseDuration = $row[7];
			$temp->responseUserId = $row[8];
			$temp->responseUserName = $row[9];
			
			$temp->userId = $row[10];
			$temp->score = $row[11];
			$temp->comment = $row[12];
			$temp->addingDate = $row[13];
			
			$temp->exerciseId = $row[14];
			$temp->exerciseName = $row[15];
			$temp->exerciseDuration = $row[16];
			$temp->exerciseLanguage = $row[17];
			$temp->exerciseThumbnailUri = $row[18];
			$temp->exerciseTitle = $row[19];
			$temp->exerciseSource = $row[20];
			
			array_push ( $searchResults, $temp );
		}
		
		return $searchResults;
	}
	
	public function detailsOfAssessedResponse($responseId){
		$sql = "SELECT C.name, A.score, A.adding_date, A.comment, B.video_identifier 
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
			$temp->score = $row[1];
			$temp->addingDate = $row[2];
			$temp->comment = $row[3];
			$temp->evaluationVideoFileIdentifier = $row[4];

			array_push ( $searchResults, $temp );
		}
		
		return $searchResults;
	}
	
	public function getEvaluationChartData($responseId){
		$sql = "SELECT U.name, E.score, E.comment 
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
			$temp->score = $row[1];
			$temp->comment = $row[2];
			
			array_push ( $searchResults, $temp );
		}
		return $searchResults;
	}	
	
	public function addAssessment(EvaluationVO $evalData){
		$sql = "INSERT INTO evaluation (fk_response_id, fk_user_id, score, comment, adding_date) VALUES (";
		$sql = $sql . "'%d', ";
		$sql = $sql . "'%d', ";
		$sql = $sql . "'%d', ";
		$sql = $sql . "'%s', NOW() )";
		
		$result = $this->_databaseUpdate ( $sql, $evalData->responseId, $evalData->userId, $evalData->score, $evalData->comment );
		
		$sql = "SELECT last_insert_id()";
		$result = $this->conn->_execute ( $sql );
		
		$row = $this->conn->_nextRow ( $result );
		if ($row) {
			$evaluationId = $row[0];
			//The evaluation data was inserted successfully. Update the evaluation count on response table.
			$update = $this->updateResponseRatingAmount($evalData->responseId);
			if($update)
				return $evaluationId;
			else
				return false;
		} else {
			return false;
		}
	}
	
	public function addVideoAssessment(EvaluationVO $evalData){

		$evaluationId = $this->addAssessment($evalData);
		if ($evaluationId){
			
			$sql = "INSERT INTO evaluation_video (fk_evaluation_id, video_identifier, source) VALUES (";
			$sql = $sql . "'%d', ";
			$sql = $sql . "'%s', ";
			$sql = $sql . "'Red5')";
			$result = $this->_databaseUpdate ( $sql, $evaluationId, $evalData->evaluationVideoFileIdentifier );
			
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