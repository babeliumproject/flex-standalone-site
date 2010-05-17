<?php

require_once 'Datasource.php';
require_once 'Config.php';
require_once 'ResponseVO.php';

class ResponseDAO {
	
	private $conn;
	
	public function ResponseDAO() {
		$settings = new Config ( );
		$this->conn = new Datasource ( $settings->host, $settings->db_name, $settings->db_username, $settings->db_password );
	}
	
	public function saveResponse(ResponseVO $data){
		
		$insert = "INSERT INTO response (fk_user_id, fk_exercise_id, file_identifier, is_private, thumbnail_uri, source, duration, adding_date, rating_amount, character_name, fk_subtitle_id) ";
		$insert = $insert . "VALUES ('%d', '%d', '%s', 1, '%s', '%s', '%s', now(), 0, '%s', %d ) ";
		
		return $this->_create($insert, $data->userId, $data->exerciseId, $data->fileIdentifier,
								$data->thumbnailUri, $data->source, $data->duration, $data->characterName, $data->subtitleId );
		
	}
	
	public function makePublic(ResponseVO $data)
	{
		$sql = "UPDATE response SET is_private = 0 WHERE (id = '%d' ) ";
		
		return $this->_databaseUpdate ( $sql, $data->id );
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
	
	private function _databaseUpdate() {
		$result = $this->conn->_execute ( func_get_args() );
		
		return $result;
	}

}

?>