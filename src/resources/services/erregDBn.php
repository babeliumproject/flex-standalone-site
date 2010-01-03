<?php

require_once ('Datasource.php');
require_once ('Config.php');

class erregDBn {
	
	private $conn;
	
	public function erregDBn() {
		$settings = new Config ( );
		$this->conn = new Datasource ( $settings->host, $settings->db_name, $settings->db_username, $settings->db_password );
	}
	
	public function insertErreg($id_user, $id_vid, $izena, $duration, $selectedRole) {
		$sql = "INSERT INTO response (fk_user_id, fk_exercise_id, file_identifier,";
		$sql .= " is_private, source, duration, adding_date, rating_amount,";
		$sql .= " character_name) ";
		$sql .= "VALUES ('$id_user', '$id_vid', '$izena',";
		$sql .= " 1, 'Red5', $duration, NOW(), 0, '$selectedRole');";
		
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
	
	private function _databaseUpdate($sql) {
		$result = $this->conn->_execute ( $sql );
		
		return $result;
	}
}

?>