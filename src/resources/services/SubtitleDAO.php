<?php

require_once ('Datasource.php');
require_once ('Config.php');

require_once ('ExerciseVO.php');
require_once ('ExerciseRoleVO.php');
require_once ('ExerciseCommentVO.php');
require_once ('ExerciseScoreVO.php');
require_once ('ExerciseLevelVO.php');

require_once ('SubtitleVO.php');
require_once ('SubtitleLineVO.php');

class SubtitleDAO {
	
	private $conn;
	
	public function SubtitleDAO() {
		$settings = new Config ( );
		$this->conn = new Datasource ( $settings->host, $settings->db_name, $settings->db_username, $settings->db_password );
	}
	
	public function getExerciseRoles($exerciseId) {
		
		$sql = "SELECT * FROM exercise_role WHERE (fk_exercise_id = '" . $exerciseId . "') ";
		
		$searchResults = $this->_listRolesQuery ( $sql );
		
		return $searchResults;
	}
	
	public function addExerciseRoles($data) {
		
		if (is_array ( $data ) && count ( $data ) > 0) {
			
			$insert = "INSERT INTO exercise_level (fk_exercise_id, fk_user_id, suggested_score, suggestion_date) ";
			$insert = $insert . "VALUES ('" . $data [0]->exerciseId . "', '" . $data [0]->userId . "', '" . $data [0]->suggestedScore . "', NOW() ) ";
			
			for($i = 1; $i < count ( $data ); $i ++) {
				$insert = $insert . ", ('" . $data [$i]->exerciseId . "', '" . $data [$i]->userId . "', '" . $data [$i]->suggestedScore . "', NOW() ) ";
			}
			return $this->_create ( $insert );
		
		} else {
			return "corrupted data recieved";
		}
	}
	
	public function getExerciseMetaData($exerciseId) {
		$sql = "SELECT * FROM exercise INNER JOIN users ON fk_user_id = ID WHERE (fk_exercise_id = '" . $exerciseId . "') ";
		
		return $this->_singleMetaDataQuery ( $sql );
	}
	
	public function getExerciseScore($exerciseId) {
		$sql = "SELECT AVG(suggested_score) AS rating FROM exercise_score WHERE (fk_exercise_id = '" . $exerciseId . "') ";
		
		return $this->_singleValueQuery ( $sql );
	}
	
	public function addExerciseScore(ExerciseScoreVO $data) {
		//Can't give rating to exercise more than 5 times
		$sql = "SELECT COUNT(*) AS vote_count FROM exercise_score WHERE (fk_exercise_id = '" . $data->exerciseId . "' AND fk_user_id = '" . $data->userId . "' ) ";
		
		$insert = "INSERT INTO exercise_level (fk_exercise_id, fk_user_id, suggested_score, suggestion_date) ";
		$insert = $insert . "VALUES ('" . $data->exerciseId . "', '" . $data->userId . "', '" . $data->suggestedScore . "', NOW() ) ";
		
		if ($this->_singleValueQuery ( $sql ) < 5)
			return $this->_create ( $insert );
		else
			return false;
	}
	
	public function getExerciseComments($exerciseId) {
		
		$sql = "SELECT * FROM exercise_comment WHERE (fk_exercise_id = '" . $exerciseId . "') ";
		
		$searchResults = $this->_listCommentsQuery ( $sql );
		
		return $searchResults;
	}
	
	public function addExerciseComment(ExerciseCommentVO $data) {
		
		$insert = "INSERT INTO exercise_comment (fk_exercise_id, fk_user_id, comment, comment_date) ";
		$insert = $insert . "VALUES ('" . $data->exerciseId . "', '" . $data->userId . "', '" . $data->comment . "', NOW() ) ";
		
		return $this->_create ( $insert );
	
	}
	
	public function getExerciseLevel($exerciseId) {
		
		$sql = "SELECT AVG(suggested_level) AS level FROM exercise_level WHERE (fk_exercise_id = '" . $exerciseId . "') ";
		
		return $this->_singleValueQuery ( $sql );
	}
	
	public function addExerciseLevel(ExerciseLevelVO $data) {
		//Can't give level to exercise more than 5 times
		$sql = "SELECT COUNT(*) AS vote_count FROM exercise_level WHERE (fk_exercise_id = '" . $data->exerciseId . "' AND fk_user_id = '" . $data->userId . "' ) ";
		
		$insert = "INSERT INTO exercise_level (fk_exercise_id, fk_user_id, suggested_level, suggest_date) ";
		$insert = $insert . "VALUES ('" . $data->exerciseId . "', '" . $data->userId . "', '" . $data->suggestedLevel . "', NOW() ) ";
		
		if ($this->_singleValueQuery ( $sql ) < 5)
			return $this->_create ( $insert );
		else
			return false;
	}
	
	public function getExerciseSubtitles($exerciseId) {
		//Gets a list of the available subtitles, later on when you choose one it's data is loaded
		$sql = "SELECT s.id, s.fk_exercise_id, s.fk_user_id, u.name, s.language, s.translation, s.adding_date 
				FROM subtitle AS s INNER JOIN users AS u ON s.fk_user_id = u.ID
				WHERE (fk_exercise_id = '" . $exerciseId . "') ";
		
		$searchResults = $this->_listSubtitlesQuery ( $sql );
		
		return $searchResults;
	
	}
	
	public function getSubtitleScore($subtitleId) {
		$sql = "SELECT AVG(suggested_level) AS level FROM subtitle_score WHERE (fk_subtitle_id = '" . $subtitleId . "') ";
		
		return $this->_singleValueQuery ( $sql );
	}
	
	public function addSubtitleScore(SubtitleScoreVO $data) {
		//Can't give rating to exercise more than 5 times
		$sql = "SELECT COUNT(*) AS vote_count FROM subtitle_score WHERE (fk_subtitle_id = '" . $data->subtitleId . "' AND fk_user_id = '" . $data->userId . "' ) ";
		
		$insert = "INSERT INTO subtitle_score (fk_subtitle_id, fk_user_id, suggested_score, suggestion_date) ";
		$insert = $insert . "VALUES ('" . $data->subtitleId . "', '" . $data->userId . "', '" . $data->suggestedScore . "', NOW() ) ";
		
		if ($this->_singleValueQuery ( $sql ) < 5)
			return $this->_create ( $insert );
		else
			return false;
	}
	
	public function getSubtitleLines($exerciseId, $language) {
	$sql = "Select SL.id,SL.show_time,SL.hide_time, ER.character_name,SL.text
            FROM (subtitle_line AS SL INNER JOIN subtitle AS S ON 
			SL.fk_subtitle_id = S.id) INNER JOIN exercise AS E ON E.id = 
			S.fk_exercise_id INNER JOIN exercise_role AS ER ON ER.id=SL.fk_exercise_role_id
			WHERE E.id = $exerciseId AND S.language = '$language'";

	
		$searchResults = $this->_listQuery ( $sql );
		
		return $searchResults;
	
	}
	
	public function saveSubtitle(SubtitleVO $sub) {
		$insert = "INSERT INTO subtitle (fk_exercise_id, fk_user_id, language, translation, adding_date)";
		$insert = $insert . "VALUES ('" . $sub->exerciseId . "', '" . $sub->userId . "', '" . $sub->language . "', false , now()) ";
		
		$result = $this->_create ( $insert );
		/*
		if ($result){
			$lineInsert = "INSERT INTO subtitle_line (fk_subtitle_id, show_time, hide_time, text, role)";
			if (count($lines) < 2)
				$lineInsert = $lineInsert . "VALUES ('" . $result . "', '" . $lines[0]->showTime . "', '" . $lines[0]->hideTime . "', '" . $lines[0]->text . "' , 'None' ) ";
			else{
				$lineInsert = $lineInsert . "VALUES ('" . $result . "', '" . $lines[0]->showTime . "', '" . $lines[0]->hideTime . "', '" . $lines[0]->text . "' , 'None' ) ";
				for ($i = 1; $i<count($lines); $i++){
					$lineInsert = $lineInsert . ", ('" . $result . "', '" . $lines[$i]->showTime . "', '" . $lines[$i]->hideTime . "', '" . $lines[$i]->text . "' , 'None' ) ";
				}
			}
			return $this->_create($lineInsert); 
			
		} else {
			return false;
		}*/
		return $result;
	}
	
	//public function saveSubtitleLines($exerciseId, $language) {
		public function saveSubtitleLines($lines = array()) {	
		
		
//	$delete ="DELETE SL
//			FROM subtitle_line AS SL INNER JOIN subtitle AS S  ON SL.fk_subtitle_id = S.id
// 			INNER JOIN exercise AS E ON E.id = S.fk_exercise_id
//            WHERE E.id = $exerciseId AND S.language LIKE '$language'";
//	$result = $this->conn->_execute($delete);
		
//		"INSERT INTO subtitle_line (
//		DELETE SL
//			   FROM subtitle_line AS SL INNER JOIN subtitle AS S  ON SL.fk_subtitle_id = S.id
// 			   INNER JOIN exercise AS E ON E.id = S.fk_exercise_id
//             WHERE E.id = $exerciseId AND S.language LIKE '$language'
//		 "
//$lineInsert = "INSERT INTO subtitle_line (fk_subtitle_id, show_time, hide_time, text, role)";
//		if (count ( $lines ) < 2)
//			$lineInsert = $lineInsert . "VALUES ('" . $lines [0]->subtitleId . "', '" . $lines [0]->showTime . "', '" . $lines [0]->hideTime . "', '" . $lines [0]->text . "' , 'None' ) ";
//		else {
//			$lineInsert = $lineInsert . "VALUES ('" . $lines [0]->subtitleId . "', '" . $lines [0]->showTime . "', '" . $lines [0]->hideTime . "', '" . $lines [0]->text . "' , 'None' ) ";
//			for($i = 1; $i < count ( $lines ); $i ++) {
//				$lineInsert = $lineInsert . ", ('" . $lines [0]->subtitleId . "', '" . $lines [$i]->showTime . "', '" . $lines [$i]->hideTime . "', '" . $lines [$i]->text . "' , 'None' ) ";
//			}
//		}
//		return $this->_create ( $lineInsert );
		 
		 
 

	//	return $result;
}
	
	public function editSubtitle() {
		//this fires when hitting save after editings
	//delete all or update the lines, have to see
	}
	
	public function scoreSubtitleLine() {
	
	}
	
	public function _singleMetaDataQuery($sql) {
		$valueObject = new ExerciseVO ( );
		$result = $this->conn->_execute ( $sql );
		
		$row = $this->conn->_nextRow ( $result );
		if ($row) {
			$valueObject->id = $row [0];
			$valueObject->name = $row [1];
			$valueObject->title = $row [2];
			$valueObject->description = $row [3];
			$valueObject->tags = $row [4];
			$valueObject->language = $row [5];
			$valueObject->source = $row [6];
			$valueObject->thumbnailUri = $row [7];
			
			$valueObject->userId = $row [8];
			$valueObject->userName = $row [9];
		
		} else {
			return false;
		}
		return $valueObject;
	}
	
	public function _singleValueQuery($sql) {
		$result = $this->conn->_execute ( $sql );
		
		$row = $this->conn->_nextRow ( $result );
		if ($row) {
			$value = $row [0];
		} else {
			return false;
		}
		return $value;
	
	}
	
	function _listQuery($sql) {
		$searchResults = array ();
		$result = $this->conn->_execute ( $sql );
		
		while ( $row = $this->conn->_nextRow ( $result ) ) {
			$temp = new SubtitleLineVO ( );
			$temp->id = $row [0];
			$temp->showTime = $row [1];
			$temp->hideTime = $row [2];
			$temp->role = $row [3];
			$temp->text=$row [4];
			array_push ( $searchResults, $temp );
		}
		
		return $searchResults;
	}
	
	public function _listRolesQuery($sql) {
		$searchResults = array ();
		$result = $this->conn->_execute ( $sql );
		
		while ( $row = $this->conn->_nextRow ( $result ) ) {
			$temp = new ExerciseRoleVO ( );
			$temp->id = $row [0];
			$temp->exerciseId = $row [1];
			$temp->userId = $row [2];
			$temp->startTime = $row [3];
			$temp->endTime = $row [4];
			$temp->characterName = $row [5];
			array_push ( $searchResults, $temp );
		}
		
		return $searchResults;
	}
	
	public function _listCommentsQuery($sql) {
		$searchResults = array ();
		$result = $this->conn->_execute ( $sql );
		
		while ( $row = $this->conn->_nextRow ( $result ) ) {
			$temp = new ExerciseCommentVO ( );
			$temp->id = $row [0];
			$temp->exerciseId = $row [1];
			$temp->userId = $row [2];
			$temp->comment = $row [3];
			$temp->commentDate = $row [4];
			array_push ( $searchResults, $temp );
		}
		
		return $searchResults;
	}
	
	public function _create($data) {
		
		$this->_databaseUpdate ( $data );
		
		$sql = "SELECT last_insert_id()";
		$result = $this->_databaseUpdate ( $sql );
		
		$row = $this->conn->_nextRow ( $result );
		if ($row) {
			return $row [0];
		} else {
			return false;
		}
	}
	
	function _databaseUpdate($sql) {
		$result = $this->conn->_execute ( $sql );
		
		return $result;
	}

}

?>