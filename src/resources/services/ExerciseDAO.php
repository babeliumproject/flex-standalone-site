<?php

require_once ('Datasource.php');
require_once ('Config.php');
require_once ('ExerciseVO.php');

class ExerciseDAO {
	
	private $conn;
	private $filePath = '';
	
	public function ExerciseDAO() {
		$settings = new Config ( );
		$this->filePath = $settings->filePath;
		$this->conn = new Datasource ( $settings->host, $settings->db_name, $settings->db_username, $settings->db_password );
	
	}
	
	public function addExercise(ExerciseVO $local, ExerciseVO $youtube) {
		$this->deleteLocalVideoCopy ( $local->name );
		
		$sql = "INSERT INTO exercise (name, title, description, tags, language, source, fk_user_id, thumbnail_uri, adding_date, duration) ";
		$sql = $sql . "VALUES ('" . $youtube->name . "', '" . $local->title . "', '" . $local->description . "', '". $local->tags ."', '" . $local->language . "', '" . $local->source . "', '" . $local->userId . "', '" . $youtube->thumbnailUri . "', now(), 0 ) ";
		
		return $this->_create ( $sql );
	
	}

	public function getExercises(){
		//$sql = "SELECT e.id, e.title, e.description, e.language, e.tags, e.source, e.name, e.thumbnail_uri, e.adding_date, e.fk_user_id, u.name 
		//        FROM exercise e INNER JOIN users u ON e.fk_user_id=u.ID ORDER BY e.adding_date DESC";
		
		$sql = "SELECT e.id, e.title, e.description, e.language, e.tags, e.source, e.name, e.thumbnail_uri,
       					e.adding_date, e.fk_user_id, u.name, avg(suggested_score) as avgScore, 
       					avg (suggested_level) as avgLevel
				 FROM   exercise e INNER JOIN users u ON e.fk_user_id= u.ID
       				    LEFT OUTER JOIN exercise_score s ON e.id=s.fk_exercise_id
       				    LEFT OUTER JOIN exercise_level l ON e.id=l.fk_exercise_id
				 GROUP BY e.id
				 ORDER BY e.adding_date DESC";
		
		
		$searchResults = $this->_listQuery($sql);
		
		return $searchResults;
	}
	
	private function deleteLocalVideoCopy($fileName) {
		$path = $this->filePath . "/" . $fileName;
		$success = unlink ( $path );
		return $success;
	}
	
	private function _singleScoreQuery($sql){
		
		$result = $this->conn->_execute($sql);
		$row = $this->conn->_nextRow ($result);
		if ($row){
			$avgRating = $row[0];
			return $avgRating;
		} else {
			return false;
		}
		
	}
	
	function _singleQuery($sql) {
		$valueObject = new ExerciseVO ( );
		$result = $this->conn->_execute ( $sql );
		
		$row = $this->conn->_nextRow ( $result );
		if ($row) {
			$valueObject->ID = $row [0];
			$valueObject->nombre = $row [1];
			$valueObject->duracion = $row [2];
			$valueObject->autor = $row [3];
		} else {
			return false;
		}
		return $valueObject;
	}
	
	function _listQuery($sql) {
		$searchResults = array ();
		$result = $this->conn->_execute ( $sql );
		
		while ( $row = $this->conn->_nextRow ( $result ) ) {
			$temp = new ExerciseVO ( );
			
			$temp->id = $row[0];
			$temp->title = $row[1];
			$temp->description = $row[2];
			$temp->language = $row[3];
			$temp->tags = $row[4];
			$temp->source = $row[5];
			$temp->name = $row[6];
			$temp->thumbnailUri = $row[7];
			$temp->addingDate = $row[8];
			$temp->userId = $row[9];
			$temp->userName = $row[10];
			$temp->avgRating = $row[11];
			$temp->avgDifficulty = $row[12];
			
			array_push ( $searchResults, $temp );
		}
		
		return $searchResults;
	}
	
	public function _create($insert) {
		$this->_databaseUpdate ( $insert );
		
		$sql = "SELECT last_insert_id()";
		$result = $this->_databaseUpdate ( $sql );
		
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

	public function makePublic($responseID)
	{
		$sql = "UPDATE response SET is_private = 0 WHERE id = $responseID";
		
		if ($this->_databaseUpdate($sql) > 0)
			return "Done";
		else
			return "error";
	}

}

?>