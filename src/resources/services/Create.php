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
	
	public function modifyVideoData($videoData = null){
		try{
			$verifySession = new SessionValidation(true);
	
			if(!$videoData)
				return false;
	
			$exercise = new Exercise();
			$parsedTags = $exercise->parseExerciseTags($videoData->tags);
			$parsedDescriptors = $exercise->parseDescriptors($videoData->descriptors);
	
			//Turn off the autocommit
			//$this->conn->_startTransaction();
	
			//Remove previous exercise_level
			$sql = "DELETE FROM exercise_level WHERE fk_exercise_id=%d";
			$arows2 = $this->conn->_delete($sql,$videoData->id);
	
			//Insert new exercise level
			$sql = "INSERT INTO exercise_level (fk_exercise_id, fk_user_id, suggested_level) VALUES (%d, %d, %d)";
			$lii1 = $this->conn->_insert($sql, $videoData->id, $_SESSION['uid'], $videoData->avgDifficulty);
	
			//Remove previous exercise_descriptors (if any)
			$sql = "DELETE FROM rel_exercise_descriptor WHERE fk_exercise_id=%d";
			$arows4 = $this->conn->_delete($sql,$videoData->id);
	
			//Insert new exercise descriptors (if any)
			$exercise->insertDescriptors($parsedDescriptors,$videoData->id);
	
			//Remove previous exercise_tags
			$sql = "DELETE FROM rel_exercise_tag WHERE fk_exercise_id=%d";
			$arows3 = $this->conn->_delete($sql,$videoData->id);
	
			//Insert new exercise tags
			$exercise->insertTags($parsedTags,$videoData->id);
	
			//Update the fields of the exercise
			$sql = "UPDATE exercise SET title='%s', description='%s', tags='%s', license='%s', reference='%s', language='%s'
			WHERE ( name='%s' AND fk_user_id=%d )";
	
			$arows1 = $this->conn->_update($sql, $videoData->title, $videoData->description, implode(',',$parsedTags), $videoData->license, $videoData->reference, $videoData->language, $videoData->name, $_SESSION['uid']);
	
			//Turn on the autocommit, there was no errors modifying the database
			//$this->conn->_endTransaction();
	
			return true;
	
	
		} catch (Exception $e){
			//$this->conn->_failedTransaction();
			throw new Exception ($e->getMessage());
		}
	}
}