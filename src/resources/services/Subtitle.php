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
require_once 'utils/CosineMeasure.php';

require_once 'vo/ExerciseVO.php';
require_once 'vo/ExerciseRoleVO.php';
require_once 'vo/SubtitleLineVO.php';
require_once 'vo/SubtitleAndSubtitleLinesVO.php';
require_once 'vo/UserVO.php';

/**
 * This class performs subtitle related operations
 * 
 * @author Babelium Team
 */
class Subtitle {

	private $conn;

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
			$this->conn = new Datasource ( $settings->host, $settings->db_name, $settings->db_username, $settings->db_password );
		} catch (Exception $e) {
			throw new Exception($e->getMessage());
		}
	}

	/**
	 * Gets the exercise roles of the provided exercise
	 * 
	 * @param int $exerciseId
	 * 		An exercise identificator
	 * @return mixed
	 * 		An array of stdClass with information about this exercise's roles. False on error or empty set.
	 */
	private function getExerciseRoles($exerciseId = 0) {
		if(!$exerciseId)
			return false;
			
		$sql = "SELECT MAX(id) as id,
					   fk_exercise_id as exerciseId,
					   character_name as characterName
				FROM exercise_role WHERE (fk_exercise_id = %d) 
				GROUP BY exercise_role.character_name ";

		$searchResults = $this->conn->_multipleSelect( $sql, $exerciseId );

		return $this->conn->multipleRecast('ExerciseRoleVO',$searchResults);
	}


	/**
	 * Returns an array of subtitle lines for the given exercise.
	 * When subtitleId is not set the returned lines are the latest available ones.
	 * When subtitleId is set the returned lines are the ones of that particular subtitle.
	 * 
	 * @param stdClass $subtitle
	 * 		An object with info about a subtitle such as the language and the exercise it should be used with
	 * @return mixed
	 * 		An array of stdClass with info about the subtitle lines. False on error or empty set.
	 */
	public function getSubtitleLines($subtitle=null) {
		if(!$subtitle)
			return false;
		$subtitleId = $subtitle->id;
		$exerciseId = $subtitle->exerciseId;
		$language = $subtitle->language;

		if(!$subtitleId){

			$sql = "SELECT  SL.id,
							SL.show_time as showTime,
							SL.hide_time as hideTime, 
							SL.text, 
							SL.fk_exercise_role_id as exerciseRoleId, 
							ER.character_name as exerciseRoleName, 
							S.id as subtitleId
            		FROM (subtitle_line AS SL INNER JOIN subtitle AS S ON 
						 SL.fk_subtitle_id = S.id) INNER JOIN exercise AS E ON E.id = 
						 S.fk_exercise_id RIGHT OUTER JOIN exercise_role AS ER ON ER.id=SL.fk_exercise_role_id
					WHERE  S.id = (SELECT MAX(SS.id)
						       	   FROM subtitle SS 
						       	   WHERE SS.fk_exercise_id ='%d' AND SS.language = '%s') ";


			$searchResults = $this->conn->_multipleSelect ( $sql, $exerciseId, $language );
		} else {
			$sql = "SELECT  SL.id,
							SL.show_time as showTime,
							SL.hide_time as hideTime, 
							SL.text, 
							SL.fk_exercise_role_id as exerciseRoleId, 
							ER.character_name as exerciseRoleName, 
							S.id as subtitleId
            		FROM (subtitle_line AS SL INNER JOIN subtitle AS S ON 
						 SL.fk_subtitle_id = S.id) INNER JOIN exercise AS E ON E.id = 
						 S.fk_exercise_id RIGHT OUTER JOIN exercise_role AS ER ON ER.id=SL.fk_exercise_role_id
					WHERE  S.id='%d'";	
			$searchResults = $this->conn->_multipleSelect ( $sql, $subtitleId );
		}

		$recastedResults = $this->conn->multipleRecast('SubtitleLineVO',$searchResults);
		//Store the last retrieved subtitle lines to check if there are changes when saving the subtitles.
		if($recastedResults)
			$_SESSION['unmodified-subtitles'] = $recastedResults;

		return $recastedResults;
	}
	
	/**
	 * Gets the lines of the provided subtitle identificator
	 * 
	 * @param int $subtitleId
	 * 		The subtitle idenntificator
	 * @return mixed
	 * 		An array of stdClass with info about the subtitle lines. False on error or empty set.
	 */
	public function getSubtitleLinesUsingId($subtitleId = 0) {
		if(!$subtitleId)
			return false;
		$sql = "SELECT SL.id,
					   SL.show_time as showTime,
					   SL.hide_time as hideTime, 
					   SL.text, 
					   SL.fk_exercise_role_id as exerciseRoleId, 
					   ER.character_name as exerciseRoleName, 
					   S.id as subtitleId
            	FROM (subtitle_line AS SL INNER JOIN subtitle AS S ON SL.fk_subtitle_id = S.id) 
            		 RIGHT OUTER JOIN exercise_role AS ER ON ER.id=SL.fk_exercise_role_id 
				WHERE ( S.id = %d )";

		$searchResults = $this->conn->_multipleSelect( $sql, $subtitleId );

		return $this->conn->multipleRecast('SubtitleLineVO', $searchResults);
	}


	/**
	 * Wrapper function for adding a new subtitle and subtitle lines to the database.
	 * Checks if the user is currently logged-in and if so calls the actual subtitle saving method.
	 * 
	 * @param stdClass $subtitleData
	 * 		An object with data about the new subtitle and its subtitle lines 
	 * @return mixed
	 * 		An object with data of the currently logged in user. False on error.
	 * @throws Exception
	 * 		Throws an error if the one trying to access this class is not successfully logged in on the system 
	 * 		or there was any problem querying the database.
	 */
	public function saveSubtitles($subtitleData = null){
		try {
			$verifySession = new SessionValidation(true);
			if(!$subtitleData)
				return false;
			else
				return $this->saveSubtitlesAuth($subtitleData);
		} catch (Exception $e) {
			throw new Exception($e->getMessage());
		}
	}

	/**
	 * Adds a new subtitle and subtitle lines to the database for the currently logged-in user
	 * 
	 * @param stdClass $subtitles
	 * 		An object with data about the new subtitle and it subtitle lines
	 * @return mixed $return
	 * 		An object with data of the currently logged-in user. False on error.
	 * @throws Exception
	 * 		Throws an error if there was a problem querying the database
	 */
	private function saveSubtitlesAuth($subtitles) {

		$result = 0;
		$subtitleLines = $subtitles->subtitleLines;
		$exerciseId = $subtitles->exerciseId;
		
		if(!$this->_subtitlesWereModified($subtitleLines))
 			return "Provided subtitles have no modifications";
 
 		if(($errors = $this->_checkSubtitleErrors($subtitleLines)) != "")
 			return $errors;
			

		$this->conn->_startTransaction();

		//Insert the new subtitle on the database
		$s_sql = "INSERT INTO subtitle (fk_exercise_id, fk_user_id, language, adding_date, complete) ";
		$s_sql .= "VALUES (%d, %d, '%s', NOW(), %d ) ";
		$subtitleId = $this->conn->_insert($s_sql, $subtitles->exerciseId, $_SESSION['uid'], $subtitles->language, $subtitles->complete );
		if(!$subtitleId){
			$this->conn->_failedTransaction();
			throw new Exception("Subtitle save failed");
		}

		//Insert the new exercise_roles
		$er_sql = "INSERT INTO exercise_role (fk_exercise_id, fk_user_id, character_name) VALUES ";
		$params = array();
		$distinctRoles = array();	
		foreach($subtitleLines as $line){
			if(count($distinctRoles)==0){
				$distinctRoles[] = $line->exerciseRoleName;
				$er_sql .= " ('%d', '%d', '%s' ),";
				array_push($params, $subtitles->exerciseId, $_SESSION['uid'], $line->exerciseRoleName );
			}
			else if(!in_array($line->exerciseRoleName,$distinctRoles)){
				$distinctRoles[] = $line->exerciseRoleName;
				$er_sql .= " ('%d', '%d', '%s' ),";
				array_push($params, $subtitles->exerciseId, $_SESSION['uid'], $line->exerciseRoleName);
			}
		}
		unset($line);
		$er_sql = substr($er_sql,0,-1);
		// put sql query and all params in one array
		$merge = array_merge((array)$er_sql, $params);
		$lastRoleId = $this->conn->_insert($merge);
		if(!$lastRoleId){
			$this->conn->_failedTransaction();
			throw new Exception("Subtitle save failed");
		}


		//Insert the new subtitle_lines
		$params = array();
		$userRoles = $this->_getUserRoles($subtitles->exerciseId, $_SESSION['uid']);
		$sl_sql = "INSERT INTO subtitle_line (fk_subtitle_id, show_time, hide_time, text, fk_exercise_role_id) VALUES ";
		foreach($subtitleLines as $line){
			foreach($userRoles as $role){
				if ($role->characterName == $line->exerciseRoleName){
					$line->exerciseRoleId = $role->id;
					$sl_sql .= " ('%d', '%s', '%s', '%s', '%d' ),";
					array_push($params, $subtitleId, $line->showTime, $line->hideTime, $line->text, $line->exerciseRoleId);
					break;
				}
			}
			unset($role);
		}
		unset($line);
		$sl_sql = substr($sl_sql,0,-1);
		// put sql query and all params in one array
		$merge = array_merge((array)$sl_sql, $params);
		$lastSubtitleLineId = $this->conn->_insert($merge);
		if(!$lastSubtitleLineId){
			$this->conn->_failedTransaction();
			throw new Exception("Subtitle save failed");
		}

		//Update the user's credit count
		$creditUpdate = $this->_addCreditsForSubtitling();
		if(!$creditUpdate){
			$this->conn->_failedTransaction();
			throw new Exception("Credit addition failed");
		}

		//Update the credit history
		$creditHistoryInsert = $this->_addSubtitlingToCreditHistory($exerciseId);
		if(!$creditHistoryInsert){
			$this->conn->_failedTransaction();
			throw new Exception("Credit history update failed");
		}

		if ($subtitleId && $lastRoleId && $lastSubtitleLineId && $creditUpdate && $creditHistoryInsert){
			$this->conn->_endTransaction();

			$result = $this->_getUserInfo();
		}

		return $result;

	}

	/**
	 * Gets the roles the currently logged-in user has added for the current exercise
	 * 
	 * @param int $exerciseId
	 * 		An exercise identificator
	 * @param int $userId
	 * 		An user identificator
	 * @return mixed $searchResults
	 * 		An array of user role ids. False on error.
	 */
	private function _getUserRoles($exerciseId, $userId){
		$sql = "SELECT MAX(id) as id,
					   fk_exercise_id as exerciseId, 
					   character_name as characterName
		    	FROM exercise_role WHERE (fk_exercise_id = %d AND fk_user_id= %d) 
		    	GROUP BY exercise_role.character_name ";

		$searchResults = $this->conn->_multipleSelect ( $sql, $exerciseId, $userId );

		return $searchResults;
	}

	/**
	 * Adds some credits to the currently logged-in user to award its collaboration
	 * 
	 * @return int
	 * 		Returns the number of rows affected by the latest database update
	 */
	private function _addCreditsForSubtitling() {
		$sql = "UPDATE (user u JOIN preferences p)
				SET u.creditCount=u.creditCount+p.prefValue 
				WHERE (u.id=%d AND p.prefName='subtitleAdditionCredits') ";
		return $this->conn->_update ( $sql, $_SESSION['uid'] );
	}

	/**
	 * Adds an entry to the credits history so the user is able to review when he/she got credits for subtitling an exercise
	 * 
	 * @param int $exerciseId
	 * 		An exercise identificator
	 * @return int
	 * 		The id of the latest inserted credit history row. False on error
	 */
	private function _addSubtitlingToCreditHistory($exerciseId){
		$sql = "SELECT prefValue FROM preferences WHERE ( prefName='subtitleAdditionCredits' )";
		$result = $this->conn->_singleSelect ( $sql );
		if($result){
			$sql = "INSERT INTO credithistory (fk_user_id, fk_exercise_id, changeDate, changeType, changeAmount) ";
			$sql = $sql . "VALUES ('%d', '%d', NOW(), '%s', '%d') ";
			return $this->conn->_insert($sql, $_SESSION['uid'], $exerciseId, 'subtitling', $result->prefValue);
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

		$sql = "SELECT username, 
					   creditCount, 
					   joiningDate, 
					   isAdmin
				FROM user WHERE (id = %d) ";

		return $this->conn->recast('UserVO', $this->conn->_singleSelect($sql, $_SESSION['uid']));
	}

	/**
	 * Compares the subtitles the user is adding with the latest available subtitles since last database query.
	 * Determines if they were modified using a set of checks, such as time differences and text differences.
	 * 
	 * @param array $compareSubject
	 * 		A list of subtitle lines to be compared
	 * @return boolean $modified
	 * 		True if the new subtitles are a modified version of the latest available subtitles. False when not.
	 */
	private function _subtitlesWereModified($compareSubject)
	{
		$modified=false;
		$unmodifiedSubtitlesLines = $_SESSION['unmodified-subtitles'];
		if (count($unmodifiedSubtitlesLines) != count($compareSubject))
			$modified=true;
		else
		{
			for ($i=0; $i < count($unmodifiedSubtitlesLines); $i++)
			{
				$unmodifiedItem = $unmodifiedSubtitlesLines[$i];
				$compareItem = $compareSubject[$i];
				if (($unmodifiedItem->text != $compareItem->text) || ($unmodifiedItem->showTime != $compareItem->showTime) || ($unmodifiedItem->hideTime != $compareItem->hideTime))
				{
					$modified=true;
					break;
				}
			}
		}
		return $modified;
	}

	/**
	 * Checks if the provided subtitle lines have invalid characters or errors such as time overlaps or empty lines
	 * 
	 * @param array $subtitleCollection
	 * 		A list of subtitle lines to check for errors
	 * @return String $errorMessage
	 * 		Returns the errors found during the subtitle line check, empty string when the strings have no errors
	 */
	private function _checkSubtitleErrors($subtitleCollection)
	{
		$errorMessage="";
			
		//Check empty roles, time overlappings and empty texts
		for ($i=0; $i < count($subtitleCollection); $i++)
		{
			if ($subtitleCollection[$i]->exerciseRoleId < 1)
				$errorMessage.="The role on the line " . ($i + 1) . " is empty.\n";
			$lineText = $subtitleCollection[$i]->text;
			$lineText = preg_replace("/[ ,\;.\:\-_?����!���$']*/", "", $lineText);
			if (count($lineText) < 1)
				$errorMessage.="The text on the line " . ($i + 1) . " is empty.\n";
			if ($i > 0)
			{
				if ($subtitleCollection[($i-1)]->hideTime + 0.2 >= $subtitleCollection[$i]->showTime)
					$errorMessage.="The subtitle on the line " . $i . " overlaps with the next subtitle.\n";
			}
		}
		return $errorMessage;
	}

	/**
	 * TODO
	 * Returns the modification rate of the provided subtitle lines compared to the latest subtitles from the database
	 * 
	 * @param array $compareSubject
	 * 		A list of subtitle lines to compare to the latest subtitle lines
	 * @return double $modificationRate
	 * 		Returns the modification rate of the new subtitles using the cosine measure
	 */
	private function _modificationRate($compareSubject){
		$unmodifiedSubtitlesLines = $_SESSION['unmodified-subtitles'];
		$currentText = '';
		$unmodifiedText = '';
		
		foreach ($compareSubject as $cline)
			$currentText .= preg_replace("/[ ,\;.\:\-_?����!���$']*/", "", $cline->text)."\n";
		foreach ($unmodifiedSubtitlesLines as $uline)
			$unmodifiedText .= preg_replace("/[ ,\;.\:\-_?����!���$']*/", "", $uline->text)."\n";
		$cosmeas = new CosineMeasure($currentText,$unmodifiedText);
		$cosmeas->compareTexts(); 
		$modificationRate = (strlen($unmodifiedText) - similar_text($unmodifiedText, $currentText)) * (strlen($unmodifiedText)/100);
		
	}
	
	/**
	 * Returns all the subtitles available to the provided exercise
	 * 
	 * @param int $exerciseId
	 * 		An exercise identificator
	 * @return mixed
	 * 		An array of stdClass with info about the subtitles of an exercise. False on error
	 */
	public function getExerciseSubtitles($exerciseId = 0){
		if(!$exerciseId)
			return false;
		$sql = "SELECT s.id, 
					   s.fk_exercise_id as exerciseId, 
					   u.username as userName, 
					   s.language, 
					   s.translation, 
					   s.adding_date as addingDate
				FROM subtitle s inner join user u on s.fk_user_id=u.id
				WHERE fk_exercise_id='%d'
				ORDER BY s.adding_date DESC";
		$searchResults = $this->conn->_multipleSelect ( $sql, $exerciseId );

		return $this->conn->multipleRecast('SubtitleAndSubtitleLinesVO', $searchResults);
	}

	/**
	 * Removes all the previous versions of a subtitle, removing all the old subitle lines
	 * 
	 * @param int $exerciseId
	 * 		An exercise identificator
	 * @return int
	 * 		Returns the amount of rows affected by the latest delete
	 */
	private function _deletePreviousSubtitles($exerciseId){
		//Retrieve the subtitle id to be deleted
		$sql = "SELECT DISTINCT s.id
				FROM subtitle_line sl INNER JOIN subtitle s ON sl.fk_subtitle_id = s.id
				WHERE (s.fk_exercise_id= '%d' )";

		$subtitleIdToDelete = $this->conn->_singleSelect($sql, $exerciseId);

		if($subtitleIdToDelete && $subtitleIdToDelete->id){
			//Delete the subtitle_line entries ->
			$sl_delete = "DELETE FROM subtitle_line WHERE (fk_subtitle_id = '%d')";
			$result = $this->conn->_delete($sl_delete, $subtitleIdToDelete->id);

			//The first query should suffice to delete all due to ON DELETE CASCADE clauses but
			//as it seems this doesn't work we delete the rest manually.

			//Delete the exercise_role entries
			$er_delete = "DELETE FROM exercise_role WHERE (fk_exercise_id = '%d')";
			$result = $this->conn->_delete($er_delete, $exerciseId);

			//Delete the subtitle entry
			$s_delete = "DELETE FROM subtitle WHERE (id ='%d')";
			$result = $this->conn->_delete($s_delete, $subtitleIdToDelete->id);
		}
	}
}

?>
