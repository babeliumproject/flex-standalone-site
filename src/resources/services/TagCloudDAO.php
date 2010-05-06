<?php

require_once ('Config.php');
require_once ('Datasource.php');
require_once ('TagVO.php');

class TagCloudDAO {
	private $conn;
	private $numTags;
	 
	public function TagCloudDAO() {
			$settings = new Config ( );
			$this->numTags = $settings->numTags;
			$this->conn = new Datasource ( $settings->host, $settings->db_name, $settings->db_username, $settings->db_password );
	}
	
	public function getTagCloud() {
		$searchResults = array();
		//Query
		$sql = "SELECT *
				 FROM tagcloud
				 ORDER BY amount DESC, tag
				 LIMIT " . $this->numTags . ";";
 		$result = $this->conn->_execute ( $sql );
 		while ( $row = $this->conn->_nextRow ( $result ) ) {
			$temp = new TagVO();
			
			$temp->tag = $row[0];
			$temp->amount = $row[1];
			
			array_push ( $searchResults, $temp );
		}
		return $searchResults;
	}
}
?>