<?php

require_once ('Bideoa.php');
require_once ('Datasource.php');
require_once ('Config.php');

class BideoaIkusi {
	
	var $conn;
	
	function BideoaIkusi() {
		$settings = new Config ( );
		$this->conn = new Datasource ( $settings->host, $settings->db_name, $settings->db_username, $settings->db_password );
	}
	
	function _listQuery($sql) {
		$searchResults = array ();
		$result = $this->conn->_execute ( $sql );
		
		while ( $row = $this->conn->_nextRow ( $result ) ) {
			$temp = new Bideoa ( );
			$temp->ID = $row [0];
			$temp->nombre = $row [1];
			$temp->duracion = $row [2];
			$temp->autor = $row [3];
			$temp->thumbnail = $row [4];
			$temp->name = $row [5];
			array_push ( $searchResults, $temp );
		}
		
		return $searchResults;
	}
	
	function bideoakLortu() {
	$sql = "Select e.id,e.title,e.duration,users.name, e.thumbnail_uri, e.name
                        from exercise as e, users
                        where e.fk_user_id = users.ID";
	
		$searchResults = $this->_listQuery ( $sql );
		
		return $searchResults;
	
	}

}

?>
