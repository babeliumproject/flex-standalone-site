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

require_once 'vo/ResponseVO.php';
require_once 'vo/UserVO.php';

/**
 * This class performs exercise response related operations
 * 
 * @author Babelium Team
 *
 */
class Response {

	private $conn;
	private $filePath;
	private $imagePath;
	private $posterPath;
	private $red5Path;

	private $evaluationFolder = '';
	private $exerciseFolder = '';
	private $responseFolder = '';
	
	private $mediaHelper;

	/**
	 * Constructor function
	 *
	 * @throws Exception
	 * 		Throws an error if the one trying to access this class is not successfully logged in on the system
	 * 		or there was any problem establishing a connection with the database.
	 */
	public function __construct() {
		try {
			$verifySession = new SessionValidation(true);
			$settings = new Config ( );
			$this->filePath = $settings->filePath;
			$this->imagePath = $settings->imagePath;
			$this->posterPath = $settings->posterPath;
			$this->red5Path = $settings->red5Path;
			$this->conn = new Datasource ( $settings->host, $settings->db_name, $settings->db_username, $settings->db_password );
			
			$this->mediaHelper = new VideoProcessor();

		} catch (Exception $e) {
			throw new Exception($e->getMessage());
		}
	}

	/**
	 * Saves a response attempt of the user so that other users can assess his/her work
	 * 
	 * @param stdClass $data
	 * 		The data of the newly recorded response media file
	 * @return int
	 * 		The id of the latest inserted response
	 * @throws Exception
	 * 		There was a problem with the database
	 */
	public function saveResponse($data = null){
		
		if(!$data)
			return false;
		
		set_time_limit(0);
		$this->_getResourceDirectories();
		$thumbnail = 'nothumb.png';
		
		try{
			$videoPath = $this->red5Path .'/'. $this->responseFolder .'/'. $data->fileIdentifier . '.flv';
			$mediaData = $this->mediaHelper->retrieveMediaInfo($videoPath);
			$duration = $mediaData->duration;

			if($mediaData->hasVideo){
				$snapshot_output = $this->mediaHelper->takeFolderedRandomSnapshots($videoPath, $this->imagePath, $this->posterPath);
				$thumbnail = 'default.jpg';
			}
		} catch (Exception $e){
			throw new Exception($e->getMessage());
		}
		

		$insert = "INSERT INTO response (fk_user_id, fk_exercise_id, file_identifier, is_private, thumbnail_uri, source, duration, adding_date, rating_amount, character_name, fk_subtitle_id) ";
		$insert = $insert . "VALUES ('%d', '%d', '%s', 1, '%s', '%s', '%s', now(), 0, '%s', %d ) ";

		return $this->conn->_insert($insert, $_SESSION['uid'], $data->exerciseId, $data->fileIdentifier, $thumbnail, $data->source, $duration, $data->characterName, $data->subtitleId );

	}

	/**
	 * Makes a response public which means it can be assessed by other users with enough knowledge of the target language
	 * 
	 * @param stdClass $data
	 * 		An object with data about the response
	 * @throws Exception
	 * 		There was a problem with the database
	 */
	public function makePublic($data)
	{
		if(!$data)
			return false;
		
		$result = 0;
		$responseId = $data->id;
		
		$this->conn->_startTransaction();
		
		$sql = "UPDATE response SET is_private = 0 WHERE (id = '%d' ) ";

		$update = $this->conn->_update ( $sql, $responseId );
		if(!$update){
			$this->conn->_failedTransaction();
			throw new Exception("Response publication failed");
		}
		
		//Update the user's credit count
		$creditUpdate = $this->_subCreditsForEvalRequest();
		if(!$creditUpdate){
			$this->conn->_failedTransaction();
			throw new Exception("Credit addition failed");
		}

		//Update the credit history
		$creditHistoryInsert = $this->_addEvalRequestToCreditHistory($responseId);
		if(!$creditHistoryInsert){
			$this->conn->_failedTransaction();
			throw new Exception("Credit history update failed");
		}
		
		if($update && $creditUpdate && $creditHistoryInsert){
			$this->conn->_endTransaction();

			$result = $this->_getUserInfo();
		}
		
		return $result;
		
	}
	
	public function addDummyVideo($responseId){
		if(!$responseId)
			return;
			
		$this->_getResourceDirectories();
		
		try{
			$dummyImagePath = $this->imagePath.'/8x8.png';
			$basePath = $this->red5Path .'/'. $this->responseFolder;
			$suffix = "_v";
			$inputPath = $basePath .'/'. $responseId . '.flv';
			$outputPath = $basePath .'/'. $responseId . $suffix . '.flv'; 
			$mediaData = $this->mediaHelper->retrieveMediaInfo($inputPath);

			if(!$mediaData->hasVideo){
				@rename($inputPath,$outputPath);
				$output = $this->mediaHelper->addDummyVideo($dummyImagePath,$outputPath,$inputPath);
				//TODO rename the response with dummy video to the original response identifier
				return $responseId;
			} else {
				return;
			}
		} catch (Exception $e){
			throw new Exception($e->getMessage());
		}
	}

	/**
	 * Rests an amount of credits to the currently logged-in user for asking other user's collaboration
	 * 
	 * @return int
	 * 		The amount of rows affected by the update operation
	 */
	private function _subCreditsForEvalRequest() {
		$sql = "UPDATE (users u JOIN preferences p)
			SET u.creditCount=u.creditCount-p.prefValue 
			WHERE (u.ID=%d AND p.prefName='evaluationRequestCredits') ";
		return $this->conn->_update ( $sql, $_SESSION['uid'] );
	}

	/**
	 * Adds an entry to the currently logged-in user's credit history stating he/she has requested to be assessed by other users
	 * 
	 * @param int $responseId
	 * 		The response id the user wants to be assesssed by other users
	 * @return int
	 * 		The latest credit history id. False on error.
	 */
	private function _addEvalRequestToCreditHistory($responseId){
		$sql = "SELECT prefValue FROM preferences WHERE ( prefName='evaluationRequestCredits' )";
		$row = $this->conn->_singleSelect ( $sql );
		if($row){
			$changeAmount = $row->prefValue;
			$sql = "SELECT fk_exercise_id FROM response WHERE (id='%d')";
			$row = $this->conn->_singleSelect($sql, $responseId);
			if($row){
				$exerciseId = $row->fk_exercise_id;
				$sql = "INSERT INTO credithistory (fk_user_id, fk_exercise_id, fk_response_id, changeDate, changeType, changeAmount) ";
				$sql = $sql . "VALUES ('%d', '%d', '%d', NOW(), '%s', '%d') ";
				return $this->conn->_insert($sql, $_SESSION['uid'], $exerciseId, $responseId, 'eval_request', $changeAmount);
			} else {
				return false;
			}
		} else {
			return false;
		}
	}

	/**
	 * Returns profile information of the currently logged-in user
	 * 
	 * @return mixed
	 * 		An object with the currently logged-in user data. False on empty set or error
	 */
	private function _getUserInfo(){

		$sql = "SELECT name, 
					   creditCount, 
					   joiningDate, 
					   isAdmin 
				FROM users WHERE (id = %d) ";

		return $this->conn->recast('UserVO',$this->conn->_singleSelect($sql, $_SESSION['uid']));
	}

	/**
	 * Retrieves the directory names of several media resources
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

}

?>
