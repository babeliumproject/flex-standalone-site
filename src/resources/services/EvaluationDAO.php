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
			$evaluationThreshold = $row [0]; // maximum number of assements before considering one video as evaluated  
		

		//Bideo bat inork ez duenean baloratu, c.fk_user_id null izango da, eta true itzultzen du konparaketak
		$sql = "SELECT DISTINCT A.file_identifier, A.id, A.rating_amount, A.character_name, 
		                        A.adding_date, A.source, F.name, F.ID, B.id, B.name, B.duration,
		                        B.language, B.thumbnail_uri, B.title, B.source
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
	
	public function getResponsesAssessedToCurrentUser($userId){
		$sql = "SELECT DISTINCT A.name, B.file_identifier, C.fk_response_id, 
							    A.duration, B.rating_amount, B.character_name, A.id 
				FROM exercise As A INNER JOIN response As B on A.id = B.fk_exercise_id
					 INNER JOIN evaluation As C on C.fk_response_id = B.id 
				WHERE ( C.fk_user_id = '%d' ) ";
		
		$searchResults = $this->_listQuery ( $sql, $userId );
		
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
			
			$temp->userName = $row[6];
			$temp->userId = $row[7];
			
			$temp->exerciseId = $row[8];
			$temp->exerciseName = $row[9];
			$temp->exerciseDuration = $row[10];
			$temp->exerciseLanguage = $row[11];
			$temp->exerciseThumbnailUri = $row[12];
			$temp->exerciseTitle = $row[13];
			$temp->exerciseSource = $row[14];
		}

		return $searchResults;
	}
	
}


?>