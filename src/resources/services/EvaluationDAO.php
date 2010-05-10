<?php

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
			
			$temp->userName = $row[8];
			$temp->userId = $row[9];
			
			$temp->exerciseId = $row[10];
			$temp->exerciseName = $row[11];
			$temp->exerciseDuration = $row[12];
			$temp->exerciseLanguage = $row[13];
			$temp->exerciseThumbnailUri = $row[14];
			$temp->exerciseTitle = $row[15];
			$temp->exerciseSource = $row[16];
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
				WHERE ( C.fk_user_id = '%d' ) 
				GROUP BY B.id";
		
		$searchResults = $this->_listQuery ( $sql, $userId );
		
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
		}
		
		return $searchResults;
	}
	
	public function getResponsesAssessedByCurrentUser($userId){
		
	}
	
	private function _listAssessedByCurrentUser(){
		$searchResults = array();
		$result = $this->conn->_execute(func_get_args());
		
		while ($row = $this->conn->_nextRow($result)){
			
		}
	}
	
}


?>