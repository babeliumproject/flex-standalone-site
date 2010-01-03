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
	
	public function hizkuntzakLortu($key) {
		
		$sql = "SELECT A.ID_SUB, A.ID_VID, A.idioma, A.textos, A.tiempo, A.duracion 
				FROM subtitulos AS A INNER JOIN videos AS B ON (A.ID_VID = B.ID)
				WHERE B.nombre = '" . $key . "'";
		
		$searchResults = $this->_listQuery ( $sql );
		
		return $searchResults;
	
	}
	
	private function _listQuery($sql) {
		
		$searchResults = array ();
		$result = $this->conn->_execute ( $sql );
		
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
