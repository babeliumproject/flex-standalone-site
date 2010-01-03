<?php

require_once ('Datasource.php');
require_once ('Config.php');
require_once ('ExerciseRoleVO.php');


class ExerciseRoleDAO
{
	
	private $conn;
	
	public function ExerciseRoleDAO()
	{
		$settings = new Config();
		$this->conn = new DataSource($settings->host, $settings->db_name, $settings->db_username, $settings->db_password);
	}
	
	
	public function getExerciseRoles($exerciseId)
	 {
		
		$sql = "SELECT *
				FROM exercise_role
				where fk_exercise_id  = $exerciseId";
		
		$searchResults = $this->_listRolesQuery ( $sql );
		
		return $searchResults;
	}
	
	function _listRolesQuery($sql) 
	{
		$searchResults = array ();
		$result = $this->conn->_execute ( $sql );
		
		while ( $row = $this->conn->_nextRow ( $result ) ) {
			$temp = new ExerciseRoleVO ( );
			
			$temp->id = $row[0];
			$temp->exerciseId = $row[1];
			$temp->userId = $row[2];
			$temp->characterName = $row[3];
			

			
			array_push ( $searchResults, $temp );
		}
		
		return $searchResults;
	}
	
	
	public function deleteSingleExerciseRol($id)
	 {
	 	$sql = "DELETE FROM exercise_role
		     	WHERE       id = $id";
		     	
		$result = $this->conn->_execute($sql);
	}
	 	
	public function deleteAllExerciseRoles($exerciseId)
	 {
	 	$sql = "DELETE FROM exercise_role
		     	WHERE       fk_exercise_id = $exerciseId";
		     	
		$result = $this->conn->_execute($sql);	 	 
	 }
	 
	 	
	public function saveExerciseRoles($roles)
	 {
	 	$sql = "INSERT INTO exercise_role (fk_exercise_id, fk_user_id, character_name)";
	 	$sql = $sql . " VALUES ('" . $roles [0]->exerciseId . "', '" . $roles [0]->userId . "', '" . $roles [0]->characterName . "' ) ";

			for($i = 1; $i < count ( $roles ); $i ++)
			 {
				$sql = $sql . ", ('" . $roles [0]->exerciseId . "', '" . $roles [$i]->userId . "', '" . $roles [$i]->characterName . "') ";	
			 }
		return $this->_create ( $sql );
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