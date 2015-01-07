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
require_once 'utils/SessionValidation.php';
require_once 'utils/VideoProcessor.php';

require_once 'vo/ExerciseVO.php';
require_once 'vo/ExerciseReportVO.php';
require_once 'vo/ExerciseScoreVO.php';
require_once 'vo/ExerciseLevelVO.php';
require_once 'vo/UserVO.php';
require_once 'vo/UserLanguageVO.php';

require_once 'Search.php';

/**
 * Class to perform exercise related operations
 *
 * @author Babelium Team
 *
 */
class Exercise {

	private $filePath;
	private $imagePath;
	private $red5Path;
	private $posterPath;

	private $evaluationFolder = '';
	private $exerciseFolder = '';
	private $responseFolder = '';

	private $exerciseGlobalAvgRating;
	private $exerciseMinRatingCount;

	private $conn;
	private $mediaHelper;

	/**
	 * Constructor function
	 * 
	 * @throws Exception
	 * 		Thrown if there is a problem establishing a connection with the database
	 */
	public function __construct() {

		try {
			$verifySession = new SessionValidation();
			$settings = new Config ( );
			$this->filePath = $settings->filePath;
			$this->imagePath = $settings->imagePath;
			$this->posterPath = $settings->posterPath;
			$this->red5Path = $settings->red5Path;
			$this->mediaHelper = new VideoProcessor();
			$this->conn = new Datasource ( $settings->host, $settings->db_name, $settings->db_username, $settings->db_password );

		} catch (Exception $e) {
			throw new Exception($e->getMessage());
		}
	}
	
	/**
	 * Parses the tags that were sent with the upload form
	 * @param String $tags
	 * 		A set of comma-sepparated tags
	 * @return array $cleanTags
	 * 		An array of clean tags, if any
	 */
	public function parseExerciseTags($tags){
		$ptags = array();
		
		//Change new-line characters with commas, lower-case, remove html tags, and unnecessary whitespaces
		$ttags = strtolower(strip_tags(trim(escapeshellcmd($tags))));
		$ptags = explode(',', str_replace(array("\r","\n","\t"),',',$ttags));
		
		$cleanTags = array();
		
		$symbolstoremove = array(":",";","{","}","[","]","\\","/","\"","'",".");
		
		foreach($ptags as $tag){
			
			$cleanTag = trim($tag);
			//Remove links to avoid spam
			if(strlen($cleanTag) > 1 && !preg_match("/^http[s]?\:\\/\\/([^\\/]+)/",$cleanTag,$matches)){
				//TODO cut tags longer than 20 chars
				$cleanTags[] = str_replace($symbolstoremove,'',$cleanTag);
			}
		}
		unset($tag);
		return $cleanTags;
	}
	
	/**
	 * Inserts a list of tags in the database. The tags must be cleaned beforehand using the parseExerciseTags method
	 * @param array $tags
	 */
	public function insertTags($tags, $exerciseId){
		if($tags && is_array($tags) && count($tags) && $exerciseId){
			foreach($tags as $tag){
				//Check if this tag exists in the `tag` table
				$sql = "SELECT id FROM tag WHERE name='%s'";
				$exists = $this->conn->_singleSelect($sql, $tag);
				if(!$exists){
					$insert = "INSERT INTO tag SET name='%s'";
					$tagId = $this->conn->_insert($insert, $tag);
				} else {
					$tagId = $exists->id;
				}
				$sql = "SELECT fk_tag_id FROM rel_exercise_tag WHERE (fk_exercise_id=%d AND fk_tag_id=%d)";
				$exists = $this->conn->_singleSelect($sql, $exerciseId, $tagId);
				if(!$exists){
					$relInsert = "INSERT INTO rel_exercise_tag SET fk_exercise_id=%d, fk_tag_id=%d";
					$this->conn->_insert($relInsert, $exerciseId, $tagId);
				} 
			}
			unset($tag);
		}
	}
	
	/**
	 * Parses a list of language common framework descriptors using their id
	 * @param array $descriptors
	 * 		An array of descriptor codes
	 * @return array $descriptorIds
	 * 		An array of descriptor ids (recognizable by the database)
	 */
	public function parseDescriptors($descriptors){
		$descriptorIds = array();
		$pattern = "/D(\d)_(\d)_(\d{2})_(\d)/"; //D1_4_08_1
		if($descriptors){
			foreach($descriptors as $d){
				if(preg_match($pattern,$d,$matches)){
					// id(1),level(2),type(3),number(4)
					$sql = "SELECT id FROM exercise_descriptor WHERE situation=%d AND level=%d AND competence=%d AND number=%d";
					$result = $this->conn->_singleSelect($sql, $matches[1], $matches[2], $matches[3], $matches[4]);
					if($result) $descriptorIds[] = $result->id;
				}
			}
		}
		return $descriptorIds;
	}
	
	/**
	 * Add the descriptors this exercise helps to achieve
	 * @param array $descriptorIds
	 * 		The ids of the descriptors we want to associate with an exercise
	 * @param int $exerciseId
	 * 		The id of the exercise whose descriptors we are adding
	 */
	public function insertDescriptors($descriptorIds,$exerciseId){
		if($descriptorIds && is_array($descriptorIds) && count($descriptorIds)){
			$sql = "INSERT INTO rel_exercise_descriptor VALUES ";
			$params = array();
			foreach($descriptorIds as $dId){
				$sql.= " (%d,%d),";
				array_push($params, $exerciseId,$dId);
			}
			unset($dId);
			$sql = substr($sql,0,-1).";";
			// put sql query and all params in one array
			$merge = array_merge((array)$sql, $params);
			$result = $this->conn->_insert($merge);
		}
	}

	/**
	 * Adds some credits to the user that uploaded the video as a gift for collaborating
	 * @return int
	 * 		The number of rows affected by the credit adding operation
	 */
	private function _addCreditsForUploading() {
		$sql = "UPDATE (user u JOIN preferences p)
				SET u.creditCount=u.creditCount+p.prefValue
				WHERE (u.id=%d AND p.prefName='uploadExerciseCredits') ";
		return $this->conn->_update ( $sql, $_SESSION['uid'] );
	}

	/**
	 * Adds an entry to the credits history so the user is able to review when he/she got credits for uploading videos
	 * 
	 * @param int $exerciseId
	 * 		The id of the exercise uploaded and the credits are granted for
	 * @return int
	 * 		The id of the latest insert credit_history row or false on error
	 */
	private function _addUploadingToCreditHistory($exerciseId){
		$sql = "SELECT prefValue FROM preferences WHERE ( prefName='uploadExerciseCredits' )";
		$result = $this->conn->_singleSelect ( $sql );
		if($result){
			$sql = "INSERT INTO credithistory (fk_user_id, fk_exercise_id, changeDate, changeType, changeAmount) ";
			$sql = $sql . "VALUES ('%d', '%d', NOW(), '%s', '%d') ";
			return $this->conn->_insert($sql, $_SESSION['uid'], $exerciseId, 'exercise_upload', $result->prefValue);
		} else {
			return false;
		}
	}

	/**
	 * Retrieves the information of the currently logged-in user (via session variables)
	 * @return stdClass
	 * 		An object with information about the currently logged in user or false on error
	 */
	private function _getUserInfo(){

		$sql = "SELECT username, creditCount, joiningDate, isAdmin FROM user WHERE (id = %d) ";

		return $this->conn->recast('UserVO',$this->conn->_singleSelect($sql, $_SESSION['uid']));
	}

	

	/**
	 * Gets a list of all the available exercises sorted by date
	 * 
	 * @return mixed
	 * 		An array of stdClass on which each element has information about an exercises, or false on error
	 */
	public function getExercises(){
		$sql = "SELECT e.id, 
					   e.title, 
					   e.description, 
					   e.language, 
					   e.exercisecode, 
       				   e.timecreated, 
       				   u.username as userName, 
       				   e.difficulty, 
       				   e.status, 
       				   e.likes, 
       				   e.dislikes 
				FROM   exercise e INNER JOIN user u ON e.fk_user_id= u.id
       			WHERE (e.status = 1)
				GROUP BY e.id
				ORDER BY e.timecreated DESC";

		$searchResults = $this->conn->_multipleSelect($sql);
		foreach($searchResults as $searchResult){
			$data = $this->getPrimaryMediaMinData($searchResult->id);
			$searchResult->thumbnail = $data ? $data->thumbnail : null;
			$searchResult->duration = $data ? $data->duration : 0;
			$searchResult->tags = $this->getExerciseTags($searchResult->id);
			$searchResult->descriptors = $this->getExerciseDescriptors($searchResult->id);
		}

		return $this->conn->multipleRecast('ExerciseVO',$searchResults);
	}
	
	public function watchExercise($exercisecode){
		if(!$exercisecode) return;
		
		$exdata = $this->getExerciseByCode($exercisecode);
		if($exdata){
			$status = 2;
			$level = array(1,2);
			$media = $this->getExerciseMedia($exdata->id, $status, $level);
			if($media)
				$exdata->media = $media;
			$related = $this->getRelatedExercises($exdata);
			if($related)
				$exdata->related = $related;
		}
		return $this->conn->recast('ExerciseVO',$exdata);
	}
	
	/**
	 * Gets information about an exercise using its id
	 * @return stdClass
	 * 		An object with information about the requested exercise or false on error
	 */
	public function getExerciseById($id = 0){
		if(!$id)
			return;
			
		$sql = "SELECT e.id, 
					   e.title, 
					   e.description, 
					   e.language, 
					   e.exercisecode, 
       				   e.timecreated, 
       				   u.username as userName, 
       				   e.difficulty, 
       				   e.status, 
       				   e.likes,
       				   e.dislikes 
				FROM   exercise e INNER JOIN user u ON e.fk_user_id= u.id
       			WHERE (e.id = %d)
				GROUP BY e.id
				LIMIT 1";
		
		$result = $this->conn->_singleSelect($sql,$id);
		if($result){
			$data = $this->getPrimaryMediaMinData($result->id);
			$result->thumbnail = $data ? $data->thumbnail : null;
			$result->duration = $data ? $data->duration : 0;
			$result->tags = $this->getExerciseTags($result->id);
			$result->descriptors = $this->getExerciseDescriptors($result->id);
		}

		return $this->conn->recast('ExerciseVO',$result);
	}

	/**
	 * Gets information about an exercise using its name (or filehash)
	 * @return stdClass
	 * 		An object with information about the requested exercise or false on error
	 */
	public function getExerciseByCodeWithMedia($exercisecode = null){
		if(!$exercisecode)
			return;
			
		$result = $this->getExerciseByCode($exercisecode);
		if($result){
			$data = $this->getPrimaryMediaMinData($result->id);
			$result->thumbnail = $data ? $data->thumbnail : null;
			$result->duration = $data ? $data->duration : 0;
		}

		return $this->conn->recast('ExerciseVO',$result);
	}
	
	public function getExerciseByCode($exercisecode){
		if(!$exercisecode)
			return;
			
		$sql = "SELECT e.id, e.title, e.description, e.language, e.exercisecode, e.timecreated,
					   u.username as userName, e.difficulty, e.status, e.likes, e.dislikes, e.type,
					   e.competence, e.situation, e.lingaspects
				FROM   exercise e INNER JOIN user u ON e.fk_user_id= u.id
				WHERE (e.exercisecode = '%s')
				GROUP BY e.id LIMIT 1";
		
		$result = $this->conn->_singleSelect($sql,$exercisecode);
		if($result){
			$result->tags = $this->getExerciseTags($result->id);
			$result->descriptors = $this->getExerciseDescriptors($result->id);
		}
		return $this->conn->recast('ExerciseVO',$result);
	}
	
	private function getRelatedExercises($exercise, $howmany=5){
		if (!$exercise) return;
		$relatedex = false;
		$sql = "SELECT e.id  
				FROM exercise e 
				WHERE language='%s' AND difficulty=%d AND status=1 ORDER BY RAND() LIMIT %d";
		$results = $this->conn->_multipleSelect($sql, $exercise->language, $exercise->difficulty, $howmany);
		if ($results){
			$relatedex = array();
			foreach($results as $result){
				$re = $this->getExerciseById($result->id);
				if($re) $relatedex[] = $re;
			}
		}
		return $relatedex;
	}

	/**
	 * Gets a list of all the exercises that are available and whose subtitling has not been marked as complete.
	 * This method is only accessible for logged-in users.
	 * 
	 * @return mixed
	 * 		An array of stdClass on which each element has information about an exercises, or false on error
	 * @throws Exception
	 * 		There's no active logged-in user session, or there was a problem updating the database
	 */
	public function getExercisesUnfinishedSubtitling(){
		try {
			$verifySession = new SessionValidation(true);

			$sql = "SELECT e.id, 
						   e.title, 
						   e.description, 
						   e.language, 
						   e.exercisecode, 
       					   e.timecreated, 
       					   u.username as userName, 
       					   e.difficulty, 
       					   e.likes, 
       					   e.dislikes, 
       					   e.status 
					FROM exercise e 
					 	 INNER JOIN user u ON e.fk_user_id= u.id
       				 	 LEFT OUTER JOIN subtitle a ON e.id=a.fk_exercise_id
       			 	 	 WHERE (e.status = 1)
				 	GROUP BY e.id
				 	ORDER BY e.timecreated DESC";

			$searchResults = $this->conn->_multipleSelect($sql);
			foreach($searchResults as $searchResult){
				$data = $this->getPrimaryMediaMinData($searchResult->id);
				$searchResult->thumbnail = $data ? $data->thumbnail : null;
				$searchResult->duration = $data ? $data->duration : 0;
				$searchResult->tags = $this->getExerciseTags($searchResult->id);
				$searchResult->descriptors = $this->getExerciseDescriptors($searchResult->id);
			}

			//Filter searchResults to include only the "evaluate" languages of the user
			$filteredResults = $this->filterByLanguage($searchResults, 'evaluate');
			return $this->conn->multipleRecast('ExerciseVO',$filteredResults);
		} catch (Exception $e){
			throw new Exception($e->getMessage());
		}
	}


	/**
	 * Gets a list of all the exercises that are available and ready to be practiced (it has subtitles and those subtitles are marked as complete).
	 * If there's an active user session the list is filtered using the user's set of preferred languages.
	 * 
	 * @return mixed
	 * 		An array of stdClass on which each element has information about an exercises, or false on error
	 */
	public function getRecordableExercises($data){
		
		$sql = "SELECT e.id, e.title, e.description, e.language, e.exercisecode, e.timecreated, u.username as userName, 
					   e.difficulty, e.status, e.likes, e.dislikes, e.type, e.situation, e.competence, e.lingaspects
				FROM exercise e INNER JOIN user u ON e.fk_user_id= u.id WHERE e.status = 1 AND e.visible=1";
		
		$q = isset($data->q) && strlen($data->q) ? $data->q : null;
		//$sort = isset($data->sort) ? $data->sort : null;
		$lang = isset($data->lang) ? $data->lang : null;
		$difficulty = isset($data->difficulty) ? $data->difficulty : 0;
		$type = isset($data->type) ? $data->type : -1;
		$situation = isset($data->situation) ? $data->situation : 0;
		
		if($q){
			$search = new Search();
			$exidarray = $search->launchSearch($q);
			if(count($exidarray)){
				$exids = implode($exidarray,',');
				$sql .= " AND e.id IN (%s) ";
				$sql .= " ORDER BY e.timecreated DESC, e.language DESC";
				$searchResults = $this->conn->_multipleSelect($sql,$exids);
			} else {
				$searchResults=null;	
			}
		} else {
			$sql .= " ORDER BY e.timecreated DESC, e.language DESC";
			$searchResults = $this->conn->_multipleSelect($sql);
		}
		
		if($searchResults){
			$filtered = $searchResults;
			if($lang) 
				$filtered = $this->filterByLang($filtered, $lang);
			if($difficulty) 
				$filtered = $this->filterByDifficulty($filtered, $difficulty);
			if($type>-1) 
				$filtered = $this->filterByType($filtered, $type);
			if($situation) 
				$filtered = $this->filterBySituation($filtered, $situation);
		
			if($filtered){
				foreach($filtered as $r){
					$data = $this->getPrimaryMediaMinData($r->id);
					$r->thumbnail = $data ? $data->thumbnail : null;
					$r->duration = $data ? $data->duration : 0;
					$r->tags = $this->getExerciseTags($r->id);
					$r->descriptors = $this->getExerciseDescriptors($r->id);
				}
			}
			$searchResults = $filtered;
		}

		try {
			$verifySession = new SessionValidation(true);
			$filteredResults = $this->filterByLanguage($searchResults, 'practice');
			return $this->conn->multipleRecast('ExerciseVO',$filteredResults);
		} catch (Exception $e) {
			return $this->conn->multipleRecast('ExerciseVO',$searchResults);
		}
	}
	
	private function filterByLang($list, $lang){
		if(!$lang || !$list) return;
		$result = array();
		foreach($list as $e){
			if(strpos($e->language, $lang) !== false){
				array_push($result, $e);
			}
		}
		return $result;
	}
	
	private function filterByDifficulty($list, $difficulty){
		if(!$difficulty || !$list) return;
		$result = array();
		foreach($list as $l){
			if($l->difficulty==$difficulty){
				array_push($result,$l);
			}
		}
		return $result;
	}
	
	private function filterByType($list, $type){
		if(!$type || !$list) return;
		$result = array();
		foreach($list as $l){
			if($l->type == $type){
				array_push($result,$l);
			}
		}
		return $result;
	}
	
	private function filterBySituation($list, $situation){
		if(!$situation || !$list) return;
		$result = array();
		foreach($list as $l){
			if($l->situation == $situation){
				array_push($result,$l);
			}
		}
		return $result;
	}

	/**
	 * Filters an exercise list using a language setting of the currently logged-in user
	 * 
	 * @param array $searchList
	 * 		The list that's going to be filtered
	 * @param String $languagePurpose
	 * 		The language purpose to search for among the user's languages when filtering
	 * @return array $filteredList
	 * 		The list filtered with the languages of the user that meet the provided purpose
	 */
	public function filterByLanguage($searchList, $languagePurpose){
		return $searchList;
		/* Won't be using this feature for the time being */
		/*
		if(!isset($_SESSION['user-languages']) || !is_array($_SESSION['user-languages']) || count($_SESSION['user-languages']) < 1)
			return $searchList;
		if($languagePurpose != 'evaluate' && $languagePurpose != 'practice')
			return $searchList;

		$filteredList = array();
		foreach ($searchList as $listItem){
			foreach ($_SESSION['user-languages'] as $userLanguage) {
				if ($userLanguage->purpose == $languagePurpose){
					if($listItem->language == $userLanguage->language && $listItem->avgDifficulty <= $userLanguage->level){
						array_push($filteredList, $listItem);
						break;
					}
				}
			}
		}
		return $filteredList;
		*/
	}
	
	/**
	 * Returns the descriptors of the provided exercise (if any) formated like this example: D000_A1_SI00
	 * @param int $exerciseId
	 * 		The exercise id to check for descriptors
	 * @return mixed $dcodes
	 * 		An array of descriptor codes. False when the exercise has no descriptors at all.
	 */
	public function getExerciseDescriptors($exerciseId){
		if(!$exerciseId)
			return false;
		$dcodes = false;
		$sql = "SELECT ed.* FROM rel_exercise_descriptor red INNER JOIN exercise_descriptor ed ON red.fk_exercise_descriptor_id=ed.id 
				WHERE red.fk_exercise_id=%d";
		$results = $this->conn->_multipleSelect($sql,$exerciseId);
		if($results && count($results)){
			$dcodes = array();
			foreach($results as $result){
					$dcode = sprintf("D%d_%d_%02d_%d", $result->situation, $result->level, $result->competence, $result->number);
					$dcodes[] = $dcode;
			}
			unset($result);
		}
		return $dcodes;
	}
	
	
	/**
	 * Returns the tags that were defined for the specified exercise
	 * 
	 * @param int $exerciseid
	 * 		The exercise id whose tags you want to retrieve
	 * @return mixed $tags
	 * 		An array of tags or false when no tags are defined for the specified exercise
	 */
	public function getExerciseTags($exerciseid){
		if(!$exerciseid) return;
		$tags = '';
		$sql = "SELECT t.name FROM tag t INNER JOIN rel_exercise_tag r ON t.id=r.fk_tag_id WHERE r.fk_exercise_id=%d";
		$results = $this->conn->_multipleSelect($sql, $exerciseid);
		if($results){
			$tags = array();
			foreach($results as $tag){
				$tags[] = $tag->name;
			}
		}
		return $tags;
	}
	
	public function getPrimaryMediaMinData($exerciseid){
		if(!$exerciseid) return;
		$data = false;
		$media = $this->getExerciseMedia($exerciseid, 2, 1);
		if($media && count($media)==1){
			$data = new stdClass();
			$data->thumbnail = '/resources/images/thumbs/'.$media[0]->mediacode.'/default.jpg';
			$data->duration = $media[0]->duration;
		}
		return $data;
	}
	
	/**
	 * Retrieves the media associated to the specified exercise.
	 * 
	 * @param int $exerciseid
	 * 		The exercise id whose media you want to retrieve
	 * @param int $status
	 * 		The status of the media you want to retrieve. Possible values are:
	 * 			0: Raw media. Format and dimensions are not consistent
	 * 			1: Encoding media. Media that is currently being encoded to follow standard formats and dimensions
	 * 			2: Encoded media. Media with consistent format and dimensions
	 * 			3: Duplicated media. Media with contenthash already present in the system
	 * 			4: Corrupt media. Media that can't be displayed or read correctly.
	 * 			5: Deleted media. Media that is marked as deleted and will be removed periodically.
	 * @param int $level
	 * 		The level of the media you want to retrieve. Possible values are:
	 * 			0: Undefined. This media has not been assigned a level as of yet.
	 * 			1: Primary. This media is the primary file of the instance and displayed by default.
	 * 			2: Model. This media is a model associated to a primary media.
	 * 			3: Attempt. This media is a submission done following some instance.
	 * 			4: Rendition. This media is a rendition (different dimension version) of a primary media.
	 * @return mixed $results
	 * 		An array of objects with data about the media or false when matching media is not found
	 */
	public function getExerciseMedia($exerciseid, $status, $level){
		if(!$exerciseid) return;
		
		$component = 'exercise';
		
		$sql = "SELECT m.id, m.mediacode, m.instanceid, m.component, m.type, m.duration, m.level, m.defaultthumbnail, mr.status, mr.filename
				FROM media m INNER JOIN media_rendition mr ON m.id=mr.fk_media_id
				WHERE m.component='%s' AND m.instanceid=%d";
		
		if(is_array($status)){
			if(count($status)>1){
				$sparam = implode(",",$status);
				$sql.=" AND mr.status IN (%s) ";
			} else {
				$sparam = $status[0];
				$sql.=" AND mr.status=%d ";
			}	
		} else {
			$sparam=$status;
			$sql.=" AND mr.status=%d ";
		}
		
		if(is_array($level)){
			if(count($level)>1){
				$lparam = implode(",",$level);
				$sql.=" AND m.level IN (%s) ";
			} else {
				$lparam = $level[0];
				$sql.=" AND m.level=%d ";
			}
		} else {
			$lparam = $level;
			$sql.=" AND m.level=%d ";
		}
		
		
		$results = $this->conn->_multipleSelect($sql, $component, $exerciseid, $sparam, $lparam);
		return $results;
	}

	/**
	 * Gets the available subtitle languages for the provided exercise id
	 * @param int $mediaid
	 * 		The media file whose subtitle languages we want to search
	 * @return array $results
	 * 		An array of subtitle languages available for this media
	 */
	public function getExerciseLocales($mediaid=0) {
		if(!$mediaid)
			return false;

		$sql = "SELECT DISTINCT language as locale FROM subtitle
				WHERE fk_media_id = %d";

		$results = $this->conn->_multipleSelect ( $sql, $mediaid );

		return $results; // return languages
	}

	/**
	 * Reports about an exercise/video that breaks the rules of the site
	 *
	 * @param stdClass $report
	 * 		An object that stores the reason of the report and the exercise being reported
	 * @return int
	 * 		The id of the report we just added to the database or false on error
	 * @throws Exception
	 * 		There's no active user session
	 */
	public function addInappropriateExerciseReport($report = null){
		try {
			$verifySession = new SessionValidation(true);

			if(!$report)
				return false;

			$result = $this->userReportedExercise($report);

			if (!$result){
				// The user is reporting an innapropriate exercise
				$sql = "INSERT INTO exercise_report (fk_exercise_id, fk_user_id, reason, report_date)
				    	VALUES ('%d', '%d', '%s', NOW() )";

				$result = $this->conn->_insert($sql, $report->exerciseId, $_SESSION['uid'], $report->reason);
				//$this->notifyExerciseReported($report);
				return $result;
			} else {
				return 0;
			}
		} catch (Exception $e) {
			throw new Exception($e->getMessage());
		}
	}

	/**
	 * Sends an email to the site admins warning an exercise is being reported as inadequate
	 * 
	 * @param stdClass $report
	 * 		An object that stores the reason of the report and the exercise being reported
	 * @return boolean
	 * 		Returns true if there was no noticeable problem while sending the email or false otherwise
	 */
	private function notifyExerciseReported($report){
		$mail = new Mailer();
		$subject = 'Babelium Project: Exercise reported';
		$text = sprintf("Exercise (id=%d) has been reported to be %s by the user (id=%d)", $report->exerciseId, $report->reason, $_SESSION['uid']);
		return ($mail->send($text, $subject, null));
	}

	
	public function addExerciseLike($data = null){
		try {
			$verifySession = new SessionValidation(true);
			
			if(!$data || $data->like !=0 || $data->like!=1)
				return false;

			$optime = time();
			$alreadyliked = $this->exerciseAlreadyLiked($data);
			
			if (!$alreadyliked){
				$sql = "INSERT INTO exercise_like (fk_exercise_id, fk_user_id, like, timecreated, timemodified) VALUES (%d, %d, %d, %d, %d)";
				$likeid = $this->conn->_insert($sql, $data->exerciseid, $_SESSION['uid'], $data->like, $optime);
				$this->updateLikeCount($data->exerciseid);
			} else {
				//User changed the opinion regarding this exercise
				if($alreadyliked->like != $data->like){
					$sql = "UPDATE execise_like SET like=%d, timemodified=%d WHERE id=%d";
					$updatedrows = $this->conn->_update($sql, $data->like, $optime, $alreadyliked->id);
					$this->updateLikeCount($data->exerciseid);
				}
			}
			
			//Return updated like values
			return $this->getExerciseById($data->exerciseid);
			
		} catch (Exception $e) {
			throw new Exception($e->getMessage());
		}
	}

	private function exerciseAlreadyLiked($data = null){
		try {
			$verifySession = new SessionValidation(true);
	
			if(!$data) return false;
			
			$sql = "SELECT id, like FROM exercise_like WHERE (fk_exercise_id=%d AND fk_user_id=%d)";
			return $this->conn->_singleSelect($sql, $data->exerciseid, $_SESSION['uid']);
			
		} catch (Exception $e) {
			throw new Exception($e->getMessage());
		}
	}
	
	private function updateLikeCount($exerciseid){
		$sql = "UPDATE exercise e SET e.likes=(SELECT COUNT(l1.like) exercise_like l1 WHERE l1.fk_exercise_id=%d AND l1.like=1), 
									e.dislikes=(SELECT COUNT(l2.like) exercise_like l2 WHERE l2.fk_exercise_id=%d AND l2.like=0)
		        WHERE e.id=%d";
		
		$this->conn->_update($sql, $exerciseid, $exerciseid, $exerciseid);
	}

	/**
	 * Check if the user has already reported about this exercise
	 * @param stdClass $report
	 * 		An object that stores the reason of the report and the exercise being reported
	 * @return stdClass
	 * 		An object with info about the requested report, false if report doesn't exist
	 * @throws Exception
	 * 		There's no active user session
	 */
	public function userReportedExercise($report = null){
		try {
			$verifySession = new SessionValidation(true);
			if(!$report)
				return false;
				
			$sql = "SELECT *
				FROM exercise_report 
				WHERE ( fk_exercise_id='%d' AND fk_user_id='%d' )";
			return $this->conn->_singleSelect ($sql, $report->exerciseId, $_SESSION['uid']);
		} catch (Exception $e) {
			throw new Exception($e->getMessage());
		}
	}

}

?>
