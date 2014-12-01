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
	
	const STATUS_UNDEF=0;
	const STATUS_ENCODING=1;
	const STATUS_READY=2;
	const STATUS_DUPLICATED=3;
	const STATUS_ERROR=4;

	const LEVEL_UNDEF=0;
	const LEVEL_PRIMARY=1;
	const LEVEL_MODEL=2;
	
	const TYPE_VIDEO='video';
	const TYPE_AUDIO='audio';
	
	private $conn;
	private $cfg;

	public function __construct(){
		try {
			$this->cfg = new Config();
			$verifySession = new SessionValidation();
			$this->mediaHelper = new VideoProcessor();
			$this->conn = new Datasource($this->cfg->host, $this->cfg->db_name, $this->cfg->db_username, $this->cfg->db_password);
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
					$whereClause .= " exercisecode = '%s' OR";
					array_push($names, $selectedVideo->exercisecode);
				}
				unset($selectedVideo);
				$whereClause = substr($whereClause,0,-2);
	
				$sql = "DELETE FROM exercise WHERE (fk_user_id=%d AND " . $whereClause ." )";
	
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
			$sql = "SELECT m.id, m.instanceid as exerciseid, m.mediacode, m.defaultthumbnail, m.type, m.timecreated, m.timemodified, m.license, m.authorref, m.duration, m.level,
						   mr.filename, mr.status, mr.dimension
					FROM media m INNER JOIN media_rendition mr ON m.id=mr.fk_media_id 
					WHERE m.component='%s' AND m.level IN (%s) AND m.instanceid=(SELECT id FROM exercise WHERE exercisecode='%s')";
			$results = $this->conn->_multipleSelect($sql, $component, $levels, $exercisecode);
			if($results){
				foreach($results as $r){
					$r->
					if($r->status==self::STATUS_READY){
						$r->subtitlestatus=$this->getSubtitleStatus($r->id);
						if($r->type==self::TYPE_VIDEO){
							$posterurl = '/resources/images/posters/'.$r->mediacode.'/0'.$r->defaultthumbnail.'.jpg';
							$r->posterurl = $posterurl;
							$thumburls=array();
							for($i=1;$i<4;$i++){
								$thumburls[] = '/resources/images/thumbs/'.$r->mediacode.'/0'.$i.'.jpg';
							}
							$r->thumburls = $thumburls;
						}
					}
				}
			}
			//Filter by status
			return $results;
		} catch (Exception $e){
			throw new Exception ($e->getMessage());
		}
	}
	
	private function getSubtitleStatus($mediaid){
		$status=0;
		$sql = "SELECT complete FROM subtitle WHERE fk_media_id=%d";
		$results = $this->conn->_multipleSelect($sql, $mediaid);
		if($results){
			$status=1;
			foreach($results as $r){
				if($r->complete==1){
					$status=2;
					break;
				}
			}
		}
		return $status;
	}
	
	public function setDefaultThumbnail($data){
		try{
			$session = new SessionValidation(true);
			
			if(!$data || !isset($data->mediacode)) return;
			
			$thumbidx = (isset($data->defaultthumbnail) && $data->defaultthumbnail >=1 && $data->defaultthumbnail <= 3) ? $data->defaultthumbnail : 1;
			$mediacode = $data->mediacode;
			
			$posterfolder = $this->cfg->posterPath .'/'. $mediacode;
			$thumbfolder = $this->cfg->imagePath .'/'. $mediacode;
			
			@unlink($thumbfolder.'/default.jpg');
			@unlink($posterfolder.'/default.jpg');
			
			if( !symlink($thumbfolder.'/0'.$thumbidx.'.jpg', $thumbfolder.'/default.jpg')  ){
				throw new Exception ("Couldn't create link for the thumbnail $thumbfolder/0$thumbidx.jpg, $thumbfolder/default.jpg\n");
			}
			if( !symlink($posterfolder.'/0'.$thumbidx.'.jpg', $posterfolder.'/default.jpg') ){
				throw new Exception ("Couldn't create link for the poster\n");
			}
			
			$sql = "UPDATE media SET defaultthumbnail=%d WHERE mediacode='%s' AND type='video' AND fk_user_id=%d";
			
			$rowcount = $this->conn->_update($sql, $thumbidx, $mediacode, $_SESSION['uid']);
		
			$sql = "SELECT instanceid FROM media WHERE mediacode='%s' AND component='exercise'";
			$result = $this->conn->_singleSelect($sql, $mediacode);
			
			if(!$result || !isset($result->instanceid)){
				throw new Exception("No exercise matches the given mediacode");
			}else{
				require_once 'Exercise.php';
				$exercise = new Exercise();
				$exercisedata = $exercise->getExerciseById($result->instanceid);
				return $this->getExerciseMedia($exercisedata->exercisecode);
			}
		} catch (Exception $e){
			throw new Exception($e->getMessage());
		}
	}
	
	public function saveExerciseMedia($data = null){
		try{
			$verifySession = new SessionValidation(true);
			
			if(!$data || !isset($data->exercisecode) || !isset($data->filename) || !isset($data->level)) return;
			
			//Check if media has already been added for the given 'instanceid', 'component' and 'level'
			$sql = "SELECT id FROM media WHERE instanceid=%d AND component='%s' AND level=%d";
			$mediaexists = $this->conn->_multipleSelect($sql, $data->exercisecode, 'exercise', $data->level);
			
			if($mediaexists) return;
			
			$this->_getResourceDirectories();
			
			require_once 'Exercise.php';
			$exercise = new Exercise();
			$exercisedata = $exercise->getExerciseByCode($result->exercisecode);
			$instanceid = $exercisedata->instanceid;
			
			$optime = time();
			$mediacode = $this->uuidv4();
			
			$webcammedia = $this->cfg->red5Path . '/' . $this->exerciseFolder . '/' . $data->filename;
			$filemedia = $this->cfg->filePath . '/' . $data->filename;
			
			$status = self::STATUS_UNDEF; //raw video
			
			if(is_file($webcammedia)){
				$medianfo = $this->mediaHelper->retrieveMediaInfo($webcammedia);
				$dimension = $medianfo->videoHeight;
				$filesize = filesize($webcammedia);
				$this->mediaHelper->takeFolderedRandomSnapshots($webcammedia, $this->cfg->imagePath, $this->cfg->posterPath);
				$status = self::STATUS_READY;
			} else if(is_file($filemedia)){
				$medianfo = $this->mediaHelper->retrieveMediaInfo($filemedia);
				$dimension = $medianfo->videoHeight;
				$filesize = filesize($filemedia);
			} else {
				return;
			}
			$contenthash = $medianfo->hash;
			$duration = $medianfo->duration;
			$type = $medianfo->hasVideo ? 'video' : 'audio';
			$metadata = $this->custom_json_encode($medianfo);
			
			$insert = "INSERT INTO media (instanceid, component, mediacode, type, timecreated, duration, level, defaultthumbnail, fk_user_id) 
					   VALUES (%d, '%s', '%s', '%s', %d, %d, %d, %d, %d)";
			
			$mediaid = $this->conn->_insert($insert, $instanceid, 'exercise', $mediacode, $type, $optime, $duration, $data->level, 1, $_SESSION['uid']);
			
			$insertr = "INSERT INTO media_rendition (fk_media_id, filename, contenthash, status, timecreated, filesize, metadata, dimension) 
						VALUES (%d, '%s', '%s', %d, %d, %d, '%s', %d)";
			
			$mediarendition = $this->conn->_insert($insertr, $mediaid, $data->filename, $contenthash, $status, $optime, $filesize, $metadata, $dimension);
			
			//TODO add raw media to asynchronous task processing queue
			//videoworker->add_task($mediaid);
			
			return $this->getExerciseMedia($data->exercisecode);
			
		} catch (Exception $e){
			throw new Exception($e->getMessage());
		}
	}
	
	public function getMediaStatus($mediaid){
		$component = 'exercise';
		$sql = "SELECT max(`status`) as `status` FROM media_rendition WHERE id=%d";
		$result = $this->conn->_singleSelect($sql, $mediaid);
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
				$sql = "UPDATE exercise SET title='%s', description='%s', language='%s', difficulty=%d, timemodified=%d, type=%d, situation=%d, competence=%d, lingaspects='%s'
						WHERE exercisecode='%s' AND fk_user_id=%d";
				$arows1 = $this->conn->_update($sql, $data->title, $data->description, $data->language, $data->difficulty, $optime, $data->type, 
													 $data->situation, $data->competence, $data->lingaspects, $data->exercisecode, $_SESSION['uid']);
				
				//Turn on the autocommit, there was no errors modifying the database
				//$this->conn->_endTransaction();
				
				return $data->exercisecode;
	
			// Adding a new exercise
			} else {
				//TODO use some session value to know when transitioning back&forth from 'step1' and 'step2'
				
				$exercisecode = $this->str_makerand(11,true,true);
				
				$sql = "INSERT INTO exercise (exercisecode, title, description, language, difficulty, timecreated, type, situation, competence, lingaspects, fk_user_id) 
						VALUES ('%s', '%s', '%s', '%s', %d, %d, %d, %d, %d, '%s', %d)";
				$exerciseid = $this->conn->_insert($sql, $exercisecode, $data->title, $data->description, $data->language, $data->difficulty, 
													     $optime, $data->type, $data->situation, $data->competence, $data->lingaspects, $_SESSION['uid']);
				
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
	
	/**
	 * Retrieves the names of the directories in which different kinds of videos are stored
	 */
	private function _getResourceDirectories(){
		$sql = "SELECT prefValue
		FROM preferences
		WHERE (prefName='exerciseFolder' OR prefName='responseFolder' OR prefName='evaluationFolder')
		ORDER BY prefName";
		$result = $this->conn->_multipleSelect($sql);
		if($result){
			$this->evaluationFolder = $result[0] ? $result[0]->prefValue : '';
			$this->exerciseFolder = $result[1] ? $result[1]->prefValue : '';
			$this->responseFolder = $result[2] ? $result[2]->prefValue : '';
		}
	}
	
	/**
	 * Encode the given array using Json
	 *
	 * @param Array $data
	 * @param bool $prettyprint
	 * @return mixed $data
	 */
	private function custom_json_encode($data, $prettyprint=0){
		$data = Zend_Json::encode($data,false);
		$data = preg_replace_callback('/\\\\u([0-9a-f]{4})/i', create_function('$match', 'return mb_convert_encoding(pack("H*", $match[1]), "UTF-8", "UCS-2BE");'), $data);
		if($prettyprint)
			$data = Zend_Json::prettyPrint($data);
		return $data;
	}
	
	/**
	 * Returns a provided character long random alphanumeric string
	 *
	 * @author Peter Mugane Kionga-Kamau
	 * http://www.pmkmedia.com
	 *
	 * @param int $length
	 * @param boolean $useupper
	 * @param boolean $usenumbers
	 */
	public function str_makerand ($length, $useupper, $usenumbers)
	{
		$key= '';
		$charset = "abcdefghijklmnopqrstuvwxyz";
		if ($useupper)
			$charset .= "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
		if ($usenumbers)
			$charset .= "0123456789";
		for ($i=0; $i<$length; $i++)
			$key .= $charset[(mt_rand(0,(strlen($charset)-1)))];
			return $key;
	}
}