<?php

require_once 'utils/Datasource.php';
require_once 'utils/Config.php';
require_once 'vo/ExerciseRoleVO.php';


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
		$sql = "SELECT MAX(id) as id, fk_exercise_id, fk_user_id, character_name
				FROM exercise_role
				WHERE fk_exercise_id = '%d'
				GROUP BY character_name";

		$searchResults = $this->_listRolesQuery ( $sql, $exerciseId );

		return $searchResults;
	}

	private function _listRolesQuery(){
		$searchResults = array ();
		$result = $this->conn->_execute ( func_get_args() );

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
		     	WHERE       id = %d";

		$result = $this->conn->_execute($sql,$id);
	}

	public function deleteAllExerciseRoles($exerciseId)
	{
		$sql = "DELETE FROM exercise_role
		     	WHERE       fk_exercise_id = %d";

		$result = $this->conn->_execute($sql,$exerciseId);
	}


	public function saveExerciseRoles($roles)
	{
		$sql = "INSERT INTO exercise_role (fk_exercise_id, fk_user_id, character_name)";
		$sql = $sql . " VALUES ('%d', '%d', '%s' ) ";

		$params = array();
		array_push($params, $roles[0]->exerciseId, $roles[0]->userId, $roles[0]->characterName);

		for($i = 1; $i < count ( $roles ); $i ++)
		{
			$sql = $sql . ", ('%d', '%d', '%s' ) ";
			array_push($params, $roles[$i]->exerciseId, $roles[$i]->userId, $roles[$i]->characterName);
		}

		$merge = array_merge((array)$sql, $params);

		$this->conn->_execute ( $merge );

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