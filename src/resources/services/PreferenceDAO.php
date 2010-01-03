<?php

require_once ('Datasource.php');
require_once ('Config.php');
require_once ('PreferenceVO.php');


/**
 * This class is used to make queries related to an VO object. When the results
 * are stored on our VO class AMFPHP parses this data and makes it available for
 * AS3/Flex use.
 *
 * It must be placed under amfphp's services folder, once we have successfully
 * installed amfphp's files in apache's web folder.
 *
 */

class PreferenceDAO {

	private $conn;

	public function PreferenceDAO(){
		$settings = new Config();
		$this->conn = new Datasource($settings->host, $settings->db_name, $settings->db_username, $settings->db_password);
	}
	
	public function getAppPreferences(){
		$sql = "SELECT * FROM preferences";
		
		$searchResults = $this->_listQuery($sql);
		
		return $searchResults;
	}
	
	private function _listQuery($sql){
		$searchResults = array();
		$result = $this->conn->_execute($sql);

		while ($row = $this->conn->_nextRow($result))
		{
			$temp = new PreferenceVO();
			$temp->prefName = $row[1];
			$temp->prefValue = $row[2];
			array_push($searchResults, $temp);
		}

		return $searchResults;
	}
}

?>