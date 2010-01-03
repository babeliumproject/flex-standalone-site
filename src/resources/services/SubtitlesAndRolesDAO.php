<?php

require_once ('Datasource.php');
require_once ('Config.php');

require_once ('ExerciseVO.php');
require_once ('ExerciseRoleVO.php');
require_once ('SubtitlesAndRolesVO.php');
require_once ('SubtitleVO.php');
require_once ('SubtitleLineVO.php');

class SubtitlesAndRolesDAO 
{
	
	private $conn;
	
	public function SubtitlesAndRolesDAO()
	 {
		$settings = new Config ( );
		$this->conn = new Datasource ( $settings->host, $settings->db_name, $settings->db_username, $settings->db_password );
	}
	
	public function getInfoSubRoles($exerciseId, $language)
	 {
	$sql = "SELECT SL.id, SL.show_time, SL.hide_time, ER.id, ER.character_name, X.character_name, SL.text 
			FROM subtitle_line AS SL
			INNER JOIN subtitle AS S ON SL.fk_subtitle_id = S.id
			INNER JOIN exercise AS E ON E.id = S.fk_exercise_id
			INNER JOIN exercise_role AS ER ON ER.id = SL.fk_exercise_role_id
			RIGHT OUTER JOIN exercise_role AS X ON SL.id= X.id
			WHERE E.id = $exerciseId
			AND S.language = '$language'";
			
		$searchResults = $this->_listQuery ( $sql );
		
		return $searchResults;
	
	}
	
	
	
	function _listQuery($sql) 
	{
		$searchResults = array ();
		$result = $this->conn->_execute ( $sql );
		
		while ( $row = $this->conn->_nextRow ( $result ) ) 
		{
			$temp = new SubtitlesAndRolesVO ( );
			
			$temp->id = $row [0];
			$temp->showTime = $row [1];
			$temp->hideTime = $row [2];
			$temp->roleId = $row [3];
			$temp->singleName = $row [4];
			$temp->characterName = $row [5];
			$temp->text = $row [6];
			
			array_push ( $searchResults, $temp );
		}
		
		return $searchResults;
	}
	
}

?>