<?php

require_once 'Datasource.php';
require_once 'Config.php';

require_once 'ExerciseVO.php';
require_once 'ExerciseRoleVO.php';
require_once 'SubtitleLineVO.php';
require_once 'SubtitleAndSubtitleLinesVO.php';

class SubtitleDAO {

	private $conn;

	public function SubtitleDAO() {
		$settings = new Config ( );
		$this->conn = new Datasource ( $settings->host, $settings->db_name, $settings->db_username, $settings->db_password );
	}

	public function getExerciseRoles($exerciseId) {

		$sql = "SELECT id,fk_exercise_id,fk_user_id,character_name 
				FROM exercise_role WHERE (fk_exercise_id = %d) ";

		$searchResults = $this->_listRolesQuery ( $sql, $exerciseId );

		return $searchResults;
	}

	public function getUserRoles($exerciseId, $userId){
		$sql = "SELECT id,fk_exercise_id,fk_user_id,character_name 
		    	FROM exercise_role WHERE (fk_exercise_id = %d AND fk_user_id= %d)";
		
		$searchResults = $this->_listRolesQuery ( $sql, $exerciseId, $userId );

		return $searchResults;
	}

	/*
	public function getExerciseSubtitles($exerciseId) {
		$sql = "SELECT s.id, s.fk_exercise_id, s.fk_user_id, u.name, s.language, s.translation, s.adding_date
				FROM subtitle AS s INNER JOIN users AS u ON s.fk_user_id = u.ID
				WHERE (fk_exercise_id = '%d') ";

		$searchResults = $this->_listSubtitlesQuery ( $sql, $exerciseId );
		for ($i = 0; $i<count($searchResults); $i++){
			$searchResults[$i]->subtitleLines = $this->getSubtitlesSubtitleLines($searchResults[$i]->id);
		}

		return $searchResults;
	}
	*/

	public function getSubtitlesSubtitleLines($subtitleId) {
		$sql = "SELECT SL.id, SL.show_time, SL.hide_time, SL.text, SL.fk_exercise_role_id, ER.character_name, S.id
				FROM subtitle_line AS SL INNER JOIN subtitle AS S ON SL.fk_subtitle_id = S.id 
				INNER JOIN exercise AS E ON E.id = S.fk_exercise_id 
				RIGHT OUTER JOIN exercise_role AS ER ON ER.id=SL.fk_exercise_role_id
				WHERE (SL.fk_subtitle_id = %d)";

		$searchResults = $this->_listSubtitleLinesQuery ($sql, $subtitleId);

		return $searchResults;
	}

	public function getSubtitleLines($exerciseId, $language) {
		$sql = "SELECT SL.id,SL.show_time,SL.hide_time, SL.text, SL.fk_exercise_role_id, ER.character_name, S.id
            	FROM (subtitle_line AS SL INNER JOIN subtitle AS S ON 
				SL.fk_subtitle_id = S.id) INNER JOIN exercise AS E ON E.id = 
				S.fk_exercise_id RIGHT OUTER JOIN exercise_role AS ER ON ER.id=SL.fk_exercise_role_id
				WHERE E.id = %d AND S.language = '%s'";


		$searchResults = $this->_listSubtitleLinesQuery ( $sql, $exerciseId, $language );

		return $searchResults;

	}
	
	public function getSubtitleLinesUsingId($subtitleId) {
		$sql = "SELECT SL.id,SL.show_time,SL.hide_time, SL.text, SL.fk_exercise_role_id, ER.character_name, S.id 
            	FROM (subtitle_line AS SL INNER JOIN subtitle AS S ON SL.fk_subtitle_id = S.id) 
            		 RIGHT OUTER JOIN exercise_role AS ER ON ER.id=SL.fk_exercise_role_id 
				WHERE ( S.id = %d )";

		$searchResults = $this->_listSubtitleLinesQuery ( $sql, $subtitleId );
		
		return $searchResults;
	}


	public function getSubtitleScore($subtitleId) {
		$sql = "SELECT AVG(suggested_level) AS level FROM subtitle_score WHERE (fk_subtitle_id = '%d') ";

		return $this->_singleValueQuery ( $sql, $subtitleId );
	}

	public function addSubtitleScore(SubtitleScoreVO $data) {
		//Can't give rating to exercise more than 5 times
		$sql = "SELECT COUNT(*) AS vote_count FROM subtitle_score WHERE (fk_subtitle_id = '%d' AND fk_user_id = '%d' ) ";

		$insert = "INSERT INTO subtitle_score (fk_subtitle_id, fk_user_id, suggested_score, suggestion_date) ";
		$insert = $insert . "VALUES ('%d', '%d', '%d', NOW() ) ";

		if ($this->_singleValueQuery ( $sql, $data->subtitleId, $data->userId ) < 5)
		return $this->_create ( $insert, $data->subtitleId, $data->userId, $data->suggestedScore );
		else
		return false;
	}



	//We retrieve an instance of SubtitleAndSubtitleLinesVO
	public function saveSubtitles($subtitles) {

		$result = 0;
		$subtitleLines = $subtitles->subtitleLines;

		//if ($subtitles->id == 0){
			
		$this->_deletePreviousSubtitles($subtitles->exerciseId);
			
		//We are adding a new subtitle
		//First, we insert the new subtitle on the database
		$s_sql = "INSERT INTO subtitle (fk_exercise_id, fk_user_id, language, adding_date) ";
		$s_sql .= "VALUES ('%d', '%d', '%s', NOW() ) ";
		$subtitleId = $this->_create($s_sql, $subtitles->exerciseId, $subtitles->userId, $subtitles->language );

		//Second, we insert the new exercise_roles
		$er_sql = "INSERT INTO exercise_role (fk_exercise_id, fk_user_id, character_name) VALUES ";
		$params = array();
			
		foreach($subtitleLines as $line){
			if(count($distinctRoles)==0){
				$distinctRoles[] = $line->exerciseRoleName;
				$er_sql .= " ('%d', '%d', '%s' ),";
				array_push($params, $subtitles->exerciseId, $subtitles->userId, $line->exerciseRoleName );
			}
			else if(!in_array($line->exerciseRoleName,$distinctRoles)){
				$distinctRoles[] = $line->exerciseRoleName;
				$er_sql .= " ('%d', '%d', '%s' ),";
				array_push($params, $subtitles->exerciseId, $subtitles->userId, $line->exerciseRoleName);
			}
		}
		unset($line);
		$er_sql = substr($er_sql,0,-1);
		// put sql query and all params in one array
		$merge = array_merge((array)$er_sql, $params);
		$lastRoleId = $this->_vcreate($merge);


		//Third, we insert the new subtitle_lines
		$params = array();
		$userRoles = $this->getUserRoles($subtitles->exerciseId, $subtitles->userId);
		$sl_sql = "INSERT INTO subtitle_line (fk_subtitle_id, show_time, hide_time, text, fk_exercise_role_id) VALUES ";
		foreach($subtitleLines as $line){
			foreach($userRoles as $role){
				if ($role->characterName == $line->exerciseRoleName){
					$line->exerciseRoleId = $role->id;
					$sl_sql .= " ('%d', '%s', '%s', '%s', '%d' ),";
					array_push($params, $subtitleId, $line->showTime, $line->hideTime, $line->text, $line->exerciseRoleId);
					break;
				}
			}
			unset($role);
		}
		unset($line);
		$sl_sql = substr($sl_sql,0,-1);
		// put sql query and all params in one array
		$merge = array_merge((array)$sl_sql, $params);
		$lastSubtitleLineId = $this->_vcreate($merge);
		if ($subtitleId && $lastRoleId && $lastSubtitleLineId)
		$result = $subtitleId;

		//} elseif ($subtitles->id > 0) {
		//We are modifying a subtitle that already exists

		//} else {
		//Something is not right. The client sent a null id.
		//	throw new Exception("Error: Your request is not well formed.");
		//}

		return $result;

	}

	private function _deletePreviousSubtitles($exerciseId){
		//Retrieve the subtitle id to be deleted
		$sql = "SELECT DISTINCT s.id
				FROM subtitle_line sl INNER JOIN subtitle s ON sl.fk_subtitle_id = s.id
				WHERE (s.fk_exercise_id= '%d' )";

		$subtitleIdToDelete = $this->_singleSubtitleIdQuery($sql, $exerciseId);

		if($subtitleIdToDelete){
			//Delete the subtitle_line entries ->
			$sl_delete = "DELETE FROM subtitle_line WHERE (fk_subtitle_id = '%d')";
			$this->_databaseUpdate($sl_delete, $subtitleIdToDelete);

			//The first query should suffice to delete all due to ON DELETE CASCADE clauses but
			//as it seems this doesn't work we delete the rest manually.
				
			//Delete the exercise_role entries
			$er_delete = "DELETE FROM exercise_role WHERE (fk_exercise_id = '%d')";
			$this->_databaseUpdate($er_delete, $exerciseId);

			//Delete the subtitle entry
			$s_delete = "DELETE FROM subtitle WHERE (id ='%d')";
			$this->_databaseUpdate($s_delete, $subtitleIdToDelete);
		}
	}

	private function _singleSubtitleIdQuery(){
		$subtitleId = 0;
		$result = $this->conn->_execute(func_get_args());
		$row = $this->conn->_nextRow($result);
		if ($row){
			$subtitleId = $row[0];
		} else {
			return false;
		}
		return $subtitleId;
	}

	private function _listSubtitlesQuery(){
		$searchResults = array();
		$result = $this->conn->_execute ( func_get_args() );

		while ( $row = $this->conn->_nextRow($result)){
			$temp = new SubtitleAndSubtitleLinesVO();
			$temp->id = $row[0];
			$temp->exerciseId = $row[1];
			$temp->userId = $row[2];
			$temp->userName = $row[3];
			$temp->language = $row[4];
			$temp->translation = $row[5];
			$temp->addingDate = $row[6];
			array_push($searchResults, $temp);
		}

		return $searchResults;
	}

	private function _listSubtitleLinesQuery() {
		$searchResults = array ();
		$result = $this->conn->_execute ( func_get_args() );

		while ( $row = $this->conn->_nextRow ( $result ) ) {
			$temp = new SubtitleLineVO ( );
			$temp->id = $row [0];
			$temp->showTime = $row [1];
			$temp->hideTime = $row [2];
			$temp->text=$row [3];
			$temp->exerciseRoleId=$row[4];
			$temp->exerciseRoleName=$row[5];
			$temp->subtitleId=$row[6];
			array_push ( $searchResults, $temp );
		}

		return $searchResults;
	}

	private function _listRolesQuery() {
		$searchResults = array ();
		$result = $this->conn->_execute ( func_get_args() );

		while ( $row = $this->conn->_nextRow ( $result ) ) {
			$temp = new ExerciseRoleVO ( );
			$temp->id = $row [0];
			$temp->exerciseId = $row [1];
			$temp->userId = $row [2];
			$temp->characterName = $row [3];
			array_push ( $searchResults, $temp );
		}

		return $searchResults;
	}

	private function _create() {

		$this->conn->_execute ( func_get_args() );

		$sql = "SELECT last_insert_id()";
		$result = $this->_databaseUpdate ( $sql );

		$row = $this->conn->_nextRow ( $result );
		if ($row) {
			return $row [0];
		} else {
			return false;
		}
	}

	private function _vcreate($params) {

		$this->conn->_execute ( $params );

		$sql = "SELECT last_insert_id()";
		$result = $this->conn->_execute ( $sql );

		$row = $this->conn->_nextRow ( $result );
		if ($row) {
			return $row [0];
		} else {
			return false;
		}
	}

	private function _databaseUpdate($sql) {
		$result = $this->conn->_execute ( func_get_args() );

		return $result;
	}

}

?>