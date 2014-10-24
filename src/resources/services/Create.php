<?php
/**
 * Babelium Project open source collaborative second language oral practice - http://www.babeliumproject.com
 *
 * Copyright (c) 2014 GHyM and by respective authors (see below).
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

require_once 'utils/Datasource.php';
require_once 'utils/Config.php';
require_once 'utils/SessionValidation.php';

require_once 'Exercise.php';
require_once 'vo/ExerciseVO.php';

/**
 * This class deals with all aspects of exercise creation
 *
 * @author Babelium Team
 *
 */
class Create {
	private $conn;

	public function __construct(){
		$settings = new Config();
		try {
			$verifySession = new SessionValidation();
			$this->conn = new Datasource($settings->host, $settings->db_name, $settings->db_username, $settings->db_password);
		} catch (Exception $e) {
			throw new Exception($e->getMessage());
		}
	}
	
	public function listUserCreations($offset=0, $rowcount=0){
		try {
			$verifySession = new SessionValidation(true);
	
			$sql = "SELECT e.id,
			e.title,
			e.description,
			e.language,
			e.exercisecode,
			e.timecreated,
			e.difficulty,
			e.status
			FROM exercise e
			WHERE e.fk_user_id = %d
			ORDER BY e.timecreated DESC";
				
			$searchResults = array();
				
			if($rowcount){
				if($offset){
					$sql .= " LIMIT %d, %d";
					$searchResults = $this->conn->_multipleSelect($sql, $_SESSION['uid'], $offset, $rowcount);
				} else {
					$sql .= " LIMIT %d";
					$searchResults = $this->conn->_multipleSelect($sql, $_SESSION['uid'], $rowcount);
				}
			} else {
				$searchResults = $this->conn->_multipleSelect($sql, $_SESSION['uid']);
			}
	
			if($searchResults){
				$exercise = new Exercise();
				foreach($searchResults as $searchResult){
					//$searchResult->isSubtitled = $searchResult->isSubtitled ? true : false;
					//$searchResult->avgRating = $exercise->getExerciseAvgBayesianScore($searchResult->id)->avgRating;
					$searchResult->descriptors = $exercise->getExerciseDescriptors($searchResult->id);
				}
			}
			return $this->conn->multipleRecast('ExerciseVO', $searchResults);
	
		} catch (Exception $e) {
			throw new Exception($e->getMessage());
		}
	}
	
	public function deleteSelectedVideos($selectedVideos = null){
		try {
			$verifySession = new SessionValidation(true);
	
			if(!$selectedVideos)
				return false;
	
			$whereClause = '';
			$names = array();
	
			if(count($selectedVideos) > 0){
				foreach($selectedVideos as $selectedVideo){
					$whereClause .= " name = '%s' OR";
					array_push($names, $selectedVideo->name);
				}
				unset($selectedVideo);
				$whereClause = substr($whereClause,0,-2);
	
				$sql = "UPDATE exercise SET status='Unavailable' WHERE ( fk_user_id=%d AND" . $whereClause ." )";
	
				$merge = array_merge((array)$sql, (array)$_SESSION['uid'], $names);
				$updateData = $this->conn->_update($merge);
	
				return $updateData ? true : false;
			}
	
		} catch (Exception $e) {
			throw new Exception($e->getMessage());
		}
	}
	
	public function getExerciseData($exercisecode = null){
		try{
			$verifySession = new SessionValidation(true);
			
			require_once 'Exercise.php';
			$exercise = new Exercise();
			$exercisedata = $exercise->getExerciseByCode($exercisecode);
			
			//The requested code was not found, user is adding a new exercise
			if(!$exercisedata){
				//Generate an exercise-uid and store it in the session and return it to client.
				//In following calls to saveExerciseData check for exercise-uid to determine if adding new exercise.
				$euid = $this->uuidv4();
				$_SESSION['euid'] = $euid;
				return $euid;
			} else {
				
			}
		} catch (Exception $e){
			throw new Exception ($e->getMessage());
		}
	}
	
	public function getExerciseMedia($exercisecode){
		if(!$exercisecode) return;
		try{
			$verifySession = new SessionValidation(true);
		
			$statuses = '0,1,2,3,4';
			$levels = '0,1,2';
			$component = 'exercise';
			$sql = "SELECT id, mediacode, status, timecreated, timemodified, license, authorref, duration, level
					FROM media 
					WHERE component='%s' AND status IN (%s) AND level IN (%s) AND instanceid=(SELECT id FROM exercise WHERE exercisecode='%s')";
			$results = $this->conn->_multipleSelect($sql, $component, $statuses, $levels, $exercisecode);
			return $results;
		} catch (Exception $e){
			throw new Exception ($e->getMessage());
		}
	}
	
	public function saveExerciseMedia($data = null){
		try{
			$verifySession = new SessionValidation(true);
			
			if(!$data) return;
			
			$optime = time();
			
		} catch (Exception $e){
			throw new Exception($e->getMessage());
		}
	}
	
	public function getMediaStatus($mediaid){
		$component = 'exercise';
		$sql = "SELECT status FROM media WHERE component='%s' AND id=%d";
		$result = $this->conn->_singleSelect($sql, $component, $mediaid);
		return $result ? $result->status : -1;
	}
	
	/**
	 * Helper function to generate RFC4122 compliant UUIDs
	 * 
	 * @return String $uuid
	 * 		A RFC4122 compliant string
	 */
	public function uuidv4()
	{
		//When the openssl extension is not available in *nix systems try using urandom
		if(function_exists('openssl_random_pseudo_bytes')){
			$data = openssl_random_pseudo_bytes(16);
		} else {
			$data = file_get_contents('/dev/urandom', NULL, NULL, 0, 16);
		}	
	
		$data[6] = chr(ord($data[6]) & 0x0f | 0x40); // set version to 0100
		$data[8] = chr(ord($data[8]) & 0x3f | 0x80); // set bits 6-7 to 10
	
		return vsprintf('%s%s-%s-%s-%s-%s%s%s', str_split(bin2hex($data), 4));
	}
	
	public function saveExerciseData($data = null){
		try{
			$verifySession = new SessionValidation(true);
	
			if(!$data)
				return;
			
			$optime = time();
			$exercise = new Exercise();
			$parsedTags = $exercise->parseExerciseTags($data->tags);
			$parsedDescriptors = $exercise->parseDescriptors($data->descriptors);
	
			//Updating an exercise that already exists
			if($data->exercisecode && $exercise->getExerciseByCode($data->exercisecode)){
	
				//Turn off the autocommit
				//$this->conn->_startTransaction();
						
				//Remove previous exercise_descriptors (if any)
				$sql = "DELETE FROM rel_exercise_descriptor WHERE fk_exercise_id=%d";
				$arows4 = $this->conn->_delete($sql,$data->id);
		
				//Insert new exercise descriptors (if any)
				$exercise->insertDescriptors($parsedDescriptors,$data->id);
		
				//Remove previous exercise_tags
				$sql = "DELETE FROM rel_exercise_tag WHERE fk_exercise_id=%d";
				$arows3 = $this->conn->_delete($sql,$data->id);
		
				//Insert new exercise tags
				$exercise->insertTags($parsedTags,$data->id);
		
				//Update the fields of the exercise
				$sql = "UPDATE exercise SET title='%s', description='%s', language='%s', difficulty=%d WHERE exercisecode='%s' AND fk_user_id=%d";
				$arows1 = $this->conn->_update($sql, $data->title, $data->description, $data->language, $data->difficulty, $data->exercisecode, $_SESSION['uid']);
				
				//Turn on the autocommit, there was no errors modifying the database
				//$this->conn->_endTransaction();
				
				return $data->exercisecode;
	
			// Adding a new exercise
			} else {
				$data->euid;
				
				$sql = "INSERT INTO exercise (exercisecode, title, description, language, difficulty, fk_user_id, timecreated) 
						VALUES ('%s', '%s', '%s', '%s', %d, %d, %d)";
				$exerciseid = $this->conn->_insert($sql, $exercisecode, $data->title, $data->description, $data->language, $data->difficulty, $_SESSION['uid'], $optime);
				
				//Insert new exercise descriptors (if any)
				$exercise->insertDescriptors($parsedDescriptors,$exerciseid);
				
				//Insert new exercise tags
				$exercise->insertTags($parsedTags,$exerciseid);
				
				return $exercisecode;
			}
	
	
		} catch (Exception $e){
			//$this->conn->_failedTransaction();
			throw new Exception ($e->getMessage());
		}
	}
}