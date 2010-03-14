<?php

require_once ('Sub.php');
require_once ('Datasource.php');
require_once ('Config.php');

class ShowSubLang {
	
	private $conn;
	
	public function ShowSubLang() {
		$settings = new Config ( );
		$this->conn = new Datasource ( $settings->host, $settings->db_name, $settings->db_username, $settings->db_password );
	}
	
	public function hizkuntzakLortu($key){
		
		$sql = "SELECT S.id, E.id, S.language, L.text, TRUNCATE(L.show_time*1000,0), L.hide_time*0 "; 
		$sql .="FROM exercise AS E INNER JOIN subtitle AS S ON (E.id = S.fk_exercise_id) INNER JOIN ";
		$sql .="subtitle_line AS L ON (S.id = L.fk_subtitle_id) ";
		$sql .="WHERE (E.name = '%s' ) ";
				
		$searchResults = $this->_listQuery ( $sql, $key );
		
		return $searchResults;
	
	}
	
	private function _listQuery() {
		
		$searchResults = array ();
		$result = $this->conn->_execute ( func_get_args() );
		
		while ( $row = $this->conn->_nextRow ( $result ) ) {
			$temp = new Sub ( );
			$temp->ID_SUB = $row [0];
			$temp->ID_VID = $row [1];
			$temp->idioma = $row [2];
			$temp->textos = $row [3];
			$temp->tiempo = $row [4];
			$temp->duracion = $row [5];
			array_push ( $searchResults, $temp );
		}
		
		return $searchResults;
	}
	

	
}

?>
