<?php

require_once './Datasource.php';
require_once './Config.php';
require_once './ResponseVO.php';

class ResponseDAO {
	
	private $conn;
	
	public function ResponseDAO() {
		$settings = new Config ( );
		$this->conn = new Datasource ( $settings->host, $settings->db_name, $settings->db_username, $settings->db_password );
	}
	
	public function addResponse(ResponseVO $data){
		
		$insert = "INSERT INTO response (fk_user_id, fk_exercise_id, file_identifier, is_private, thumbnail_uri, source, duration, adding_date) ";
		$insert = $insert . "VALUES ('" . $data->userId . "', '" . $data->exerciseId . "', '" . $data->fileIdentifier . "', '" . $data->isPrivate . "', '" . $data->thumbnailUri . "', '" . $data->source . "', '" . $data->duration . "', now() ) ";
		
		return $this->_create($insert);
		
	}
	
	private function _create($insert) {
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
	
	private function _databaseUpdate($sql) {
		$result = $this->conn->_execute ( $sql );
		
		return $result;
	}

}

?>