<?php

require_once ('Datasource.php');
require_once ('Config.php');
require_once ('CreditHistoryVO.php');

/**
 * This class is used to make queries related to an VO object. When the results
 * are stored on our VO class AMFPHP parses this data and makes it available for
 * AS3/Flex use.
 *
 * It must be placed under amfphp's services folder, once we have successfully
 * installed amfphp's files in apache's web folder.
 *
 */
class CreditDAO {
	
	private $conn;
	
	public function CreditDAO() {
		$settings = new Config ( );
		$this->conn = new Datasource ( $settings->host, $settings->db_name, $settings->db_username, $settings->db_password );
	}
	
	public function addCreditsForEvaluating($userId) {
		$sql = "UPDATE (users u JOIN preferences p)
			SET u.creditCount=u.creditCount+p.prefValue
			WHERE (u.ID= " . $userId . " AND p.prefName='evaluationDoneCredits') ";
		return $this->_databaseUpdate ( $sql );
	}
	
	public function addCreditsForSubtitling($userId) {
		$sql = "UPDATE (users u JOIN preferences p) 
			SET u.creditCount=u.creditCount+p.prefValue 
			WHERE (u.ID= " . $userId . " AND p.prefName='subtitleAdditionCredits') ";
		return $this->_databaseUpdate ( $sql );
	}
	
	public function addCreditsForExerciseAdvising($userId) {
		$sql = "UPDATE (users u JOIN preferences p) 
				SET u.creditCount=u.creditCount+p.prefValue 
				WHERE (u.ID= " . $userId . " AND p.prefName='evaluationDoneCredits') ";
		return $this->_databaseUpdate ( $sql );
	}
	
	public function addCreditsForUploading($userId) {
		$sql = "UPDATE (users u JOIN preferences p)
				SET u.creditCount=u.creditCount+p.prefValue
				WHERE (u.ID= " . $userId . " AND p.prefName='uploadExerciseCredits') ";
		return $this->_databaseUpdate ( $sql );
	}
	
	public function subCreditsForEvalRequest($userId) {
		$sql = "UPDATE (users u JOIN preferences p) 
			SET u.creditCount=u.creditCount-p.prefValue 
			WHERE (u.ID= " . $userId . " AND p.prefName='evaluationRequestCredits') ";
		return $this->_databaseUpdate ( $sql );
	}
	
	public function getCurrentDayCreditHistory($userId) {
		$sql = "SELECT c.changeDate, c.changeType, c.changeAmount, c.fk_user_id, u.name, c.fk_exercise_id, e.name, c.fk_response_id, r.id_grab 
				FROM (((credithistory c INNER JOIN users u ON c.fk_user_id=u.id) INNER JOIN exercise e ON e.id=c.fk_exercise_id) LEFT OUTER JOIN grabaciones r on r.id=c.fk_response_id) 
				WHERE (c.fk_user_id = " . $userId . " AND CURDATE() <= c.changeDate ) ORDER BY changeDate DESC ";
		
		return $this->_listQuery ( $sql );
	}
	
	public function getLastWeekCreditHistory($userId) {
		$sql = "SELECT c.changeDate, c.changeType, c.changeAmount, c.fk_user_id, u.name, c.fk_exercise_id, e.name, c.fk_response_id, r.id_grab 
				FROM (((credithistory c INNER JOIN users u ON c.fk_user_id=u.id) INNER JOIN exercise e ON e.id=c.fk_exercise_id) LEFT OUTER JOIN grabaciones r on r.id=c.fk_response_id) 
				WHERE (c.fk_user_id = " . $userId . " AND DATE_SUB(CURDATE(),INTERVAL 7 DAY) <= c.changeDate ) ORDER BY changeDate DESC ";
		
		return $this->_listQuery ( $sql );
	}
	
	public function getLastMonthCreditHistory($userId) {
		$sql = "SELECT c.changeDate, c.changeType, c.changeAmount, c.fk_user_id, u.name, c.fk_exercise_id, e.name, c.fk_response_id, r.id_grab 
				FROM (((credithistory c INNER JOIN users u ON c.fk_user_id=u.id) INNER JOIN exercise e ON e.id=c.fk_exercise_id) LEFT OUTER JOIN grabaciones r on r.id=c.fk_response_id) 
				WHERE (c.fk_user_id = " . $userId . " AND DATE_SUB(CURDATE(),INTERVAL 30 DAY) <= c.changeDate ) ORDER BY changeDate DESC ";
		
		return $this->_listQuery ( $sql );
	}
	
	public function getAllTimeCreditHistory($userId) {
		$sql = "SELECT c.changeDate, c.changeType, c.changeAmount, c.fk_user_id, u.name, c.fk_exercise_id, e.name, c.fk_response_id, r.id_grab 
				FROM (((credithistory c INNER JOIN users u ON c.fk_user_id=u.id) INNER JOIN exercise e ON e.id=c.fk_exercise_id) LEFT OUTER JOIN grabaciones r on r.id=c.fk_response_id) 
				WHERE (c.fk_user_id = " . $userId . " ) ORDER BY changeDate DESC ";
		
		return $this->_listQuery ( $sql );
	}
	
	public function addEntryToCreditHistory(CreditHistoryVO $data) {
		return $this->_create ( $data );
	}
	
	//Returns a single object
	public function _singleQuery($sql) {
		$valueObject = new UserVO ( );
		$result = $this->conn->_execute ( $sql );
		
		$row = $this->conn->_nextRow ( $result );
		if ($row) {
			$valueObject->ID = $row [0];
			$valueObject->name = $row [1];
			$valueObject->email = $row [2];
			$valueObject->creditCount = $row [3];
		} else {
			return false;
		}
		return $valueObject;
	}
	
	//Returns an array of objects
	public function _listQuery($sql) {
		$searchResults = array ();
		$result = $this->conn->_execute ( $sql );
		
		while ( $row = $this->conn->_nextRow ( $result ) ) {
			$temp = new CreditHistoryVO ( );
			$temp->changeDate = $row [0];
			$temp->changeType = $row [1];
			$temp->changeAmount = $row [2];
			$temp->userId = $row [3];
			$temp->userName = $row [4];
			$temp->videoExerciseId = $row [5];
			$temp->videoExerciseName = $row [6];
			$temp->videoResponseId = $row [7];
			$temp->videoResponseName = $row [8];
			//$temp->videoEvaluationId = $row[9];
			//$temp->videoEvaluationName = $row[10];
			

			array_push ( $searchResults, $temp );
		}
		if (count ( $searchResults ) > 0)
			return $searchResults;
		else
			return false;
	}
	
	public function _create(CreditHistoryVO $valueObject) {
		
		if ($valueObject->changeType == "exercise_upload" || $valueObject->changeType="subtitling"){
			$sql = "INSERT INTO credithistory (fk_user_id, fk_exercise_id, changeDate, changeType, changeAmount) ";
			$sql = $sql . "VALUES ('" . $valueObject->userId . "', '" . $valueObject->videoExerciseId . "', NOW(), '" . $valueObject->changeType . "', '" . $valueObject->changeAmount . "') ";
		} elseif ($valueObject->changeType == "eval_request"){
			$sql = "INSERT INTO credithistory (fk_user_id, fk_exercise_id, fk_response_id, changeDate, changeType, changeAmount) ";
			$sql = $sql . "VALUES ('" . $valueObject->userId . "', '" . $valueObject->videoExerciseId . "', '" . $valueObject->videoResponseId . "', NOW(), '" . $valueObject->changeType . "', '" . $valueObject->changeAmount . "') ";
		} elseif ($valueObject->changeType == "evaluation"){
			//Something else
		}
		
		$this->_databaseUpdate ( $sql );
		
		$sql = "SELECT last_insert_id()";
		$result = $this->conn->_execute ( $sql );
		
		$row = $this->conn->_nextRow ( $result );
		if ($row) {
			return $row [0];
		} else {
			return false;
		}
	}
	
	public function _databaseUpdate($sql) {
		$result = $this->conn->_execute ( $sql );
		
		return $result;
	}
}

?>