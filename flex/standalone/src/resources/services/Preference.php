<?php

/**
 * Babelium Project open source collaborative second language oral practice - http://www.babeliumproject.com
 * 
 * Copyright (c) 2011 GHyM and by respective authors (see below).
 * 
 * This file is part of Babelium Project.
 *
 * Babelium Project is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Babelium Project is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

require_once 'utils/Config.php';
require_once 'utils/Datasource.php';
require_once 'utils/SessionHandler.php';

require_once 'vo/PreferenceVO.php';

/**
 * Class to retrieve application preference data
 * 
 * @author Babelium Team
 *
 */
class Preference {

	private $conn;

	/**
	 * Constructor function
	 *
	 * @throws Exception
	 * 		Thrown if there is a problem establishing a connection with the database
	 */
	public function __construct(){
		try {
			$verifySession = new SessionHandler();
			$settings = new Config();
			$this->conn = new Datasource($settings->host, $settings->db_name, $settings->db_username, $settings->db_password);
		} catch (Exception $e) {
			throw new Exception($e->getMessage());
		}
	}

	/**
	 * Retrieve the application preferences in a key=value fashion
	 * 
	 * @return mixed
	 * 		An array of stdClass with preference data. False on empty set or error.
	 */
	public function getAppPreferences(){

		//Retrieve the actual php.ini configuration	
		$maxFileSize = min($this->return_bytes(ini_get('post_max_size')),$this->return_bytes(ini_get('upload_max_filesize')));
		
		$sql = "SELECT DISTINCT(prefName), prefValue FROM preferences";
		$searchResults = $this->conn->_multipleSelect($sql);
		foreach($searchResults as $searchResult){
			//Override the value for maxFileSize that comes from the DB, if it is set
			if($searchResult->prefName == 'maxFileSize')
				$searchResult->prefValue = $maxFileSize;
			$preferenceData[$searchResult->prefName] = $searchResult->prefValue;
		}
		$_SESSION['preferenceData'] = $preferenceData;

		return $this->conn->multipleRecast('PreferenceVO',$searchResults);
	}
	
	/**
	 * Retrieve the exercise descriptors in all the available languages
	 */
	public function getExerciseDescriptors(){
		$sql = "SELECT ed.*, edt.locale, edt.name
				FROM exercise_descriptor ed INNER JOIN exercise_descriptor_i18n edt ON ed.id=edt.fk_exercise_descriptor_id";
		$results = $this->conn->_multipleSelect($sql);
		return $results;
	}
	
	/**
 	 * Returns the byte representation of a configuration directive
     * @param mixed $val
     * 		Either a byte or shorthand notation of a directive (K for kilobytes, M for megabytes, G for gigabytes)
     * @return int $val
     * 		Byte notation of the directive
     */
	private function return_bytes($val) {
    	$val = trim($val);
    	$last = strtolower($val[strlen($val)-1]);
    	switch($last) {
       		// The 'G' modifier is available since PHP 5.1.0
        	case 'g':
            	$val *= 1024;
        	case 'm':
            	$val *= 1024;
        	case 'k':
            	$val *= 1024;
    	}
    	return $val;
	}
	
}

?>
