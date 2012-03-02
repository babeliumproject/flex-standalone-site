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

require_once 'utils/Datasource.php';
require_once 'utils/Config.php';
require_once 'utils/SessionHandler.php';
require_once 'utils/EmailAddressValidator.php';
require_once 'utils/Mailer.php';
require_once 'vo/UserVO.php';
require_once 'vo/ExerciseVO.php';

require_once 'Exercise.php';

/**
 * This class performs user related operations
 * 
 * @author Babelium Team
 *
 */
class User {
	private $conn;

	public function __construct(){
		$settings = new Config();
		try {
			$verifySession = new SessionHandler();
			$this->conn = new Datasource($settings->host, $settings->db_name, $settings->db_username, $settings->db_password);
		} catch (Exception $e) {
			throw new Exception($e->getMessage());
		}
	}

	public function getTopTenCredited()
	{
		$sql = "SELECT name, 
					   creditCount 
				FROM users AS U WHERE U.active = 1 ORDER BY creditCount DESC LIMIT 10";

		$searchResults = $this->conn->_multipleSelect($sql);

		return $this->conn->multipleRecast('UserVO',$searchResults);
	}

	public function keepAlive(){

		try {
			$verifySession = new SessionHandler(true);

			$sessionId = session_id();
			if(empty($sessionId))
				throw new Exception("Error. Session not set.");

			//Check that there's not another active session for this user
			$sql = "SELECT * FROM user_session WHERE ( session_id = '%s' AND fk_user_id = '%d' AND closed = 0 )";
			$result = $this->conn->_singleSelect ( $sql, $sessionId, $_SESSION['uid'] );
			if($result){
				$sql = "UPDATE user_session SET keep_alive = 1 WHERE fk_user_id = '%d' AND closed=0";

				return $this->conn->_update($sql, $_SESSION['uid']);
			}
		} catch (Exception $e) {
			throw new Exception($e->getMessage());
		}
	}

	public function changePass($oldpass = null, $newpass = null)
	{
		try {
			$verifySession = new SessionHandler(true);

			if(!$oldpass || !$newpass)
				return false;
			
			$sql = "SELECT * FROM users WHERE id = %d AND password = '%s'";
			$result = $this->conn->_singleSelect($sql, $_SESSION['uid'], $oldpass);
			if (!$result)
				return false;

			$sql = "UPDATE users SET password = '%s' WHERE id = %d AND password = '%s'";
			$result = $this->conn->_update($sql, $newpass, $_SESSION['uid'], $oldpass);

			return $result;
		} catch (Exception $e) {
			throw new Exception($e->getMessage());
		}
	}

	//The parameter should be an array of UserLanguageVO
	public function modifyUserLanguages($languages = null) {

		try {
			$verifySession = new SessionHandler(true);
			
			if(!$languages)
				return false;

			$sql = "SELECT prefValue FROM preferences WHERE ( prefName='positives_to_next_level' )";
			$result = $this->conn->_singleSelect($sql);
			$positivesToNextLevel = $result ? $result->prefValue : 15;

			$currentLanguages = $_SESSION['user-languages'];

			$this->conn->_startTransaction();

			//Delete the languages that have changed
			$sql = "DELETE FROM user_languages WHERE fk_user_id = '%d'";
			$result = $this->conn->_delete($sql, $_SESSION['uid']);

			if(!$result){
				$this->conn->_failedTransaction();
				throw new Exception("Language modification failed");
			}

			//Insert the new languages
			$params = array();

			$sql = "INSERT INTO user_languages (fk_user_id, language, level, purpose, positives_to_next_level) VALUES ";
			foreach($languages as $language) {
				$sql .= " ('%d', '%s', '%d', '%s', '%d'),";
				array_push($params, $_SESSION['uid'], $language->language, $language->level, $language->purpose, $positivesToNextLevel);
			}
			unset($language);
			$sql = substr($sql,0,-1);
			// put sql query and all params in one array
			$merge = array_merge((array)$sql, $params);

			$result = $this->conn->_insert($merge);

			if (!$result){
				$this->conn->_failedTransaction();
				throw new Exception("Language modification failed");
			} else {
				$this->conn->_endTransaction();
			}

			$result = $this->_getUserLanguages();
			if($result){
				$_SESSION['user-languages'] = $result;
			}
			return $result;
				
		} catch (Exception $e) {
			throw new Exception($e->getMessage());
		}

	}
	
	public function modifyUserPersonalData($personalData = null){
		try {
			$verifySession = new SessionHandler(true);
			
			if(!$personalData)
				return false;
			
			$validator = new EmailAddressValidator();
			if(!$validator->check_email_address($personalData->email)){
				return 'wrong_email';
			} else {
			
				$currentPersonalData = $_SESSION['user-data'];
			
				$sql = "UPDATE users SET realName='%s', realSurname='%s', email='%s' WHERE id='%d'";
			
				$updateData = $this->conn->_update($sql, $personalData->realName, $personalData->realSurname, $personalData->email, $_SESSION['uid']);
				if($updateData){
					$currentPersonalData->realName = $personalData->realName;
					$currentPersonalData->realSurname = $personalData->realSurname;
					$currentPersonalData->email = $personalData->email;
					$_SESSION['user-data'] = $currentPersonalData;
					return $personalData;
				} else {
					return 'wrong_data';
				}
			}
			
		} catch (Exception $e) {
			throw new Exception($e->getMessage());
		}	
	}
	
	public function retrieveUserVideos(){
		try {
			$verifySession = new SessionHandler(true);
			
			$sql = "SELECT e.id, 
						   e.title, 
						   e.description, 
						   e.language, 
						   e.tags, 
						   e.source, 
						   e.name, 
						   e.thumbnail_uri as thumbnailUri, 
						   e.adding_date as addingDate,
		               	   e.duration, 
		               	   avg (suggested_level) as avgDifficulty, 
		               	   e.status, 
		               	   license, 
		               	   reference, 
		               	   a.complete as isSubtitled
				FROM exercise e 
	 				 LEFT OUTER JOIN exercise_score s ON e.id=s.fk_exercise_id
       				 LEFT OUTER JOIN exercise_level l ON e.id=l.fk_exercise_id
       				 LEFT OUTER JOIN subtitle a ON e.id=a.fk_exercise_id
     			WHERE e.fk_user_id = %d AND e.status <> 'Unavailable' 
				GROUP BY e.id
				ORDER BY e.adding_date DESC";
			
			
			
			$searchResults = $this->conn->_multipleSelect($sql, $_SESSION['uid']);
			$exercise = new Exercise();
			foreach($searchResults as $searchResult){
				$searchResult->isSubtitled = $searchResult->isSubtitled ? true : false;
				$searchResult->avgRating = $exercise->getExerciseAvgBayesianScore($searchResult->id)->avgRating;
			}
			
			return $this->conn->multipleRecast('ExerciseVO', $searchResults);
			
		} catch (Exception $e) {
			throw new Exception($e->getMessage());
		}	
	}
	
	public function deleteSelectedVideos($selectedVideos = null){
		try {
			$verifySession = new SessionHandler(true);
			
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
			$verifySession = new SessionHandler(true);
			
			if(!$videoData)
				return false;
			
			$sql = "UPDATE exercise SET title='%s', description='%s', tags='%s', license='%s', reference='%s', language='%s' 
					WHERE ( name='%s' AND fk_user_id=%d )";
			
			$updateData = $this->conn->_update($sql, $videoData->title, $videoData->description, $videoData->tags, $videoData->license, $videoData->reference, $videoData->language, $videoData->name, $_SESSION['uid']);
			
			$sql = "INSERT INTO exercise_level (fk_exercise_id, fk_user_id, suggested_level) VALUES (%d, %d, %d)";
			
			$insertData = $this->conn->_insert($sql, $videoData->id, $_SESSION['uid'], $videoData->avgDifficulty);
			
			return $updateData && $insertData ? true : false;
			
			
		} catch (Exception $e){
			throw new Exception ($e->getMessage());
		}
	}

	private function _getUserLanguages(){
		$sql = "SELECT language, 
					   level, 
					   positives_to_next_level as positivesToNextLevel, 
					   purpose
				FROM user_languages WHERE (fk_user_id='%d')";
		return $this->conn->multipleRecast('UserLanguageVO', $this->conn->_multipleSelect($sql, $_SESSION['uid']));
	}

	public function restorePass($username = 0)
	{
		if(!$username)
			return false;
		
		$id = -1;
		$email = "";
		$user = "";
		$realName = "";

		$aux = "name";
		if ( Mailer::checkEmail($username) )
			$aux = "email";

		// Username or email checking
		$sql = "SELECT id, name, email, realName FROM users WHERE $aux = '%s'";
		$result = $this->conn->_singleSelect($sql, $username);
		if ($result)
		{
			$id = $result->id;
			$user = $result->name;
			$email = $result->email;
			$realName = $result->realName;
		}

		if ( $realName == '' || $realName == 'unknown' ) 
			$realName = $user;

		//User doesn't exist
		if ( $id == -1 ) 
			return "Unregistered user";

		$newPassword = $this->_createNewPassword();
		
		$this->conn->_startTransaction();

		$sql = "UPDATE users SET password = '%s' WHERE id = %d";
		$result = $this->conn->_update($sql, sha1($newPassword), $id);
		
		if($result == 1){

			$args = array(
							'REAL_NAME' => $realName,
							'USERNAME' => $user,
							'PASSWORD' => $newPassword,
							'SIGNATURE' => 'The Babelium Project Team');

			$mail = new Mailer($email);

			if ( !$mail->makeTemplate("restorepass", $args, "es_ES") ) 
				return null;

			$subject = "Your password has been reseted";

			$mail->send($mail->txtContent, $subject, $mail->htmlContent);
			
			$this->conn->_endTransaction();

			return "Done";
		} else {
			$this->conn->_failedTransaction();
			throw new Exception("Error while restoring user password");
		}
	}

	private function _createNewPassword()
	{
		$pass = "";
		$chars = "zbcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
		$length = rand(8, 14);

		// Generate password
		for ( $i = 0; $i < $length; $i++ )
		$pass .= substr($chars, rand(0, strlen($chars)-1), 1);  // java: chars.charAt( random );

		return $pass;
	}

}

?>
