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
require_once 'utils/Mailer.php';
require_once 'utils/SessionHandler.php';
require_once 'utils/VideoProcessor.php';

require_once 'vo/EvaluationVO.php';
require_once 'vo/UserVO.php';

/**
 * This class stores all the methods that have something to do with the evaluation of the exercises and their responses
 *
 * @author Babelium Team
 */
class Evaluation {

	private $conn;

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
	public function __construct(){
		try {
			$verifySession = new SessionHandler(true);
			$settings = new Config ( );
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
	 * Retrieves all the responses that haven't been evaluated (and can be evaluated) by the current user
	 *
	 * @return array $searchResults
	 * 		An array of objects with data about the responses that haven't been already evaluated by the current user
	 */
	public function getResponsesWaitingAssessment() {
		$sql = "SELECT prefValue FROM preferences WHERE (prefName='trial.threshold') ";

		$result = $this->conn->_singleSelect ( $sql );
		if($result)
		$evaluationThreshold = $result->prefValue;

		$sql = "SELECT DISTINCT A.file_identifier as responseFileIdentifier,
								A.id as responseId, 
								A.rating_amount as responseRatingAmount, 
								A.character_name as responseCharacterName, 
								A.fk_subtitle_id as responseSubtitleId,
		                        A.adding_date as responseAddingDate, 
		                        A.source as responseSource, 
		                        A.thumbnail_uri as responseThumbnailUri, 
		                        A.duration as responseDuration, 
		                        F.name as responseUserName, 
		                        B.id as exerciseId, 
		                        B.name as exerciseName, 
		                        B.duration as exerciseDuration, 
		                        B.language as exerciseLanguage, 
		                        B.thumbnail_uri as exerciseThumbnailUri, 
		                        B.title as exerciseTitle, 
		                        B.source as exerciseSource, 
		                        AVG(EL.suggested_level) AS exerciseAvgDifficulty
				FROM response AS A INNER JOIN exercise AS B on A.fk_exercise_id = B.id 
				     INNER JOIN users AS F on A.fk_user_id = F.ID
				     LEFT OUTER JOIN exercise_level EL ON B.id=EL.fk_exercise_id 
		     		 LEFT OUTER JOIN evaluation AS C on C.fk_response_id = A.id
				WHERE B.status = 'Available' AND A.rating_amount < %d AND A.fk_user_id <> %d AND A.is_private = 0
				AND NOT EXISTS (SELECT *
                                FROM evaluation AS D INNER JOIN response AS E on D.fk_response_id = E.id
                                WHERE E.id = A.id AND D.fk_user_id = %d)
                GROUP BY A.id
                ORDER BY A.priority_date DESC, A.adding_date DESC";

		$searchResults = $this->conn->multipleRecast('EvaluationVO',$this->conn->_multipleSelect($sql, $evaluationThreshold, $_SESSION['uid'], $_SESSION['uid']));

		return $searchResults;
	}

	/**
	 * Retrieves those responses of the current user that have been evaluated by another user
	 *
	 * @return array $searchResults
	 * 		An array of objects with data about the responses of the current user that have been evaluated
	 */
	public function getResponsesAssessedToCurrentUser(){

		$querySortField = 'last_date';
		$queryLimitOffset = 0;
		$hitCount = 0;

		$sql = "SELECT A.file_identifier as responseFileIdentifier,
					   A.id as responseId, 
					   A.rating_amount AS responseRatingAmount, 
					   A.character_name as responseCharacterName, 
					   A.fk_subtitle_id as responseSubtitleId,
		               A.adding_date as responseAddingDate, 
		               A.source as responseSource, 
		               A.thumbnail_uri as responseThumbnailUri, 
		               A.duration as responseDuration,
		               B.id as exerciseId, 
		               B.name as exerciseName, 
		               B.duration as exerciseDuration, 
		               B.language AS exerciseLanguage, 
		               B.thumbnail_uri as exerciseThumbnailUri, 
		               B.title AS exerciseTitle, 
		               B.source as exerciseSource,
		               AVG(C.score_overall) AS overallScoreAverage, 
		               AVG(C.score_intonation) AS intonationScoreAverage, 
		               AVG(score_fluency) AS fluencyScoreAverage, 
		               AVG(score_rhythm) AS rhythmScoreAverage, 
		               AVG(score_spontaneity) AS spontaneityScoreAverage,
		               AVG(suggested_level) as exerciseAvgDifficulty, 
		               MAX(C.adding_date) AS addingDate
		        FROM response AS A INNER JOIN exercise AS B ON B.id = A.fk_exercise_id
					 INNER JOIN evaluation AS C ON C.fk_response_id = A.id 
					 LEFT OUTER JOIN exercise_level E ON B.id=E.fk_exercise_id
				WHERE ( A.fk_user_id = '%d' ) 
				GROUP BY A.id,B.id 
				ORDER BY '%s'";

		$searchResults = $this->conn->multipleRecast('EvaluationVO',$this->conn->_multipleSelect($sql, $_SESSION['uid'], $querySortField));

		$result = new stdClass();
		$result->hitCount = $hitCount;
		$result->data = $searchResults;

		return $result;
	}

	/**
	 * Retrieves the responses which the current user evaluated to another user
	 *
	 * @return	array $searchResults
	 * 		Returns an array of objects with data about the responses the current user evaluated to another user
	 */
	public function getResponsesAssessedByCurrentUser(){
		$sql = "SELECT DISTINCT A.file_identifier as responseFileIdentifier,
								A.id as responseId, 
								A.rating_amount as responseRatingAmount, 
								A.character_name as responseCharacterName, 
								A.fk_subtitle_id as responseSubtitleId,
		               			A.adding_date as responseAddingDate, 
		               			A.source as responseSource, 
		               			A.thumbnail_uri as responseThumbnailUri, 
		               			A.duration as responseDuration,
		               			U.name as responseUserName, 
		               			C.score_overall as overallScore, 
		               			C.score_intonation as intonationScore, 
		               			C.score_fluency as fluencyScore, 
		               			C.score_rhythm as rhythmScore,
		               			C.score_spontaneity as spontaneityScore, 
		               			C.comment, 
		               			C.adding_date as addingDate,
		               			B.id as exerciseId, 
		               			B.name as exerciseName, 
		               			B.duration as exerciseDuration, 
		               			B.language as exerciseLanguage, 
		               			B.thumbnail_uri as exerciseThumbnailUri, 
		               			B.title as exerciseTitle, 
		               			B.source as exerciseSource, 
		               			E.video_identifier as evaluationVideoFileIdentifier, 
		               			E.thumbnail_uri as evaluationVideoThumbnailUri 
			    FROM response AS A INNER JOIN exercise AS B ON B.id = A.fk_exercise_id  
			         INNER JOIN evaluation AS C ON C.fk_response_id = A.id
			         INNER JOIN users AS U ON U.ID = A.fk_user_id
			         LEFT OUTER JOIN evaluation_video AS E ON C.id = E.fk_evaluation_id
			    WHERE (C.fk_user_id = '%d')
			    ORDER BY A.adding_date DESC";

		$searchResults = $this->conn->multipleRecast('EvaluationVO', $this->conn->_multipleSelect ( $sql, $_SESSION['uid'] ));

		return $searchResults;
	}

	/**
	 * Retrieves the details of the assessment(s) of a particular response
	 *
	 * @param int $responseId
	 * 		Identification number of a response
	 * @return array $searchResults
	 * 		Returns an array of objects with the scores, comments and videocomments each assessor gave to this response
	 */
	public function detailsOfAssessedResponse($responseId = 0){
		if(!$responseId)
		return false;
		$sql = "SELECT C.name as userName,
					   A.score_overall as overallScore, 
					   A.score_intonation as intonationScore, 
					   A.score_fluency as fluencyScore, 
					   A.score_rhythm as rhythmScore, 
					   A.score_spontaneity as spontaneityScore,
					   A.adding_date as addingDate, 
					   A.comment as comment, 
					   B.video_identifier as evaluationVideoFileIdentifier, 
					   B.thumbnail_uri as evaluationVideoThumbnailUri
			    FROM (evaluation AS A INNER JOIN users AS C ON A.fk_user_id = C.id) 
			    	 LEFT OUTER JOIN evaluation_video AS B on A.id = B.fk_evaluation_id 
				WHERE (A.fk_response_id = '%d') ";

		$searchResults = $this->conn->multipleRecast('EvaluationVO',$this->conn->_multipleSelect ( $sql, $responseId ));

		return $searchResults;
	}

	/**
	 * Retrieves the assessment data of a particular response to build a chart
	 * @param int $responseId
	 * 		Identification number of a response
	 * @return array $searchResults
	 *	 	Returns an array of objects with the scores, comments and videocomments each assessor gave to this response
	 */
	public function getEvaluationChartData($responseId = 0){
		if(!$responseId)
		return false;
		$sql = "SELECT U.name as userName,
				E.score_overall as overallScore, 
				E.comment
				FROM evaluation AS E INNER JOIN users AS U ON E.fk_user_id = U.ID 
				     INNER JOIN response AS R ON E.fk_response_id = R.id 
				WHERE (R.id = '%d') ";

		$searchResults = $this->conn->multipleRecast('EvaluationVO',$this->conn->_multipleSelect($sql, $responseId));

		return $searchResults;
	}


	/**
	 * Checks whether a response has been evaluated by the current user or not
	 * @param int $responseId
	 * 		Identification number of a response
	 * @return boolean $evaluated
	 * 		Returns true if the given response hasn't been evaluated by the current user or false when it's been already evaluated
	 */
	private function _responseNotEvaluatedByUser($responseId){
		$sql = "SELECT *
				FROM evaluation e INNER JOIN response r ON e.fk_response_id = r.id
				WHERE (r.id = '%d' AND e.fk_user_id = '%d')";
		return !$this->conn->_singleSelect($sql, $responseId, $_SESSION['uid']);
	}

	/**
	 * Checks if the response is being assessed less times than the threshold value that establishes when a response can
	 * be considered fully assessed
	 *
	 * @param int $responseId
	 * @return boolean $notFullyAssessed
	 * 		Returns true if the assessment count for this response is less than the threshold value. Return false otherways.
	 */
	private function _responseRatingCountBelowThreshold($responseId){
		$sql = "SELECT *
				FROM response
				WHERE id = '%d' AND rating_amount < (SELECT prefValue FROM preferences WHERE prefName='trial.threshold')";
		return $this->conn->_singleSelect($sql, $responseId);
	}


	/**
	 * Adds new assessment data to the provided response
	 *
	 * @param stdClass $evalData
	 * 		An object with the following properties: (responseId, overallScore, intonationScore, fluencyScore, rhythmScore, spontaneityScore, comment)
	 * @throws Exception
	 * 		Throws an exception when the sql transaction stops unexpectedly at some point
	 */
	public function addAssessment($evalData = null){
		if(!$evalData)
		return false;

		$result = 0;
		$responseId = $evalData->responseId;

		//Ensure that this user can evaluate this response
		if(!$this->_responseNotEvaluatedByUser($responseId) || !$this->_responseRatingCountBelowThreshold($responseId))
		return $result;

		$this->conn->_startTransaction();

		$sql = "INSERT INTO evaluation (fk_response_id, fk_user_id, score_overall, score_intonation, score_fluency, score_rhythm, score_spontaneity, comment, adding_date) VALUES (";
		$sql = $sql . "'%d', ";
		$sql = $sql . "'%d', ";
		$sql = $sql . "'%d', ";
		$sql = $sql . "'%d', ";
		$sql = $sql . "'%d', ";
		$sql = $sql . "'%d', ";
		$sql = $sql . "'%d', ";
		$sql = $sql . "'%s', NOW() )";

		$evaluationId = $this->conn->_insert ( $sql, $evalData->responseId, $_SESSION['uid'], $evalData->overallScore,
		$evalData->intonationScore, $evalData->fluencyScore, $evalData->rhythmScore,
		$evalData->spontaneityScore, $evalData->comment );
		if(!$evaluationId){
			$this->conn->_failedTransaction();
			throw new Exception("Evaluation save failed");
		}

		$update = $this->_updateResponseRatingAmount($responseId);
		if(!$update){
			$this->conn->_failedTransaction();
			throw new Exception("Evaluation save failed");
		}

		//Update the user's credit count
		$creditUpdate = $this->_addCreditsForEvaluating();
		if(!$creditUpdate){
			$this->conn->_failedTransaction();
			throw new Exception("Credit addition failed");
		}

		//Update the credit history
		$creditHistoryInsert = $this->_addEvaluatingToCreditHistory($responseId, $evaluationId);
		if(!$creditHistoryInsert){
			$this->conn->_failedTransaction();
			throw new Exception("Credit history update failed");
		}

		//Update the priority of the pending assessments of this user
		$pendingAssessmentsPriority = $this->_updatePendingAssessmentsPriority();
		 if(!isset($pendingAssessmentsPriority)){
			$this->conn->_failedTransaction();
			throw  new Exception("Pending assessment priority update failed");
		}

		if($evaluationId && $update && $creditUpdate && $creditHistoryInsert 
				&& isset($pendingAssessmentsPriority)){
			$this->conn->_endTransaction();
			$result = $this->_getUserInfo();
			$this->_notifyUserAboutResponseBeingAssessed($evalData);
		}

		return $result;
	}

	/**
	 * Adds new assessment data to the provided response (plus video-comment data)
	 *
	 * @param stdClass $evalData
	 * 		An object with the following properties: (responseId, overallScore, intonationScore, fluencyScore, rhythmScore, spontaneityScore, comment, evaluationVideoFileIdentifier)
	 * @throws Exception
	 * 		Throws an exception when the sql transaction stops unexpectedly at some point
	 */
	public function addVideoAssessment($evalData = null){
		if(!$evalData)
		return false;

		$result = 0;
		$responseId = $evalData->responseId;

		//Ensure that this user can evaluate this response
		if(!$this->_responseNotEvaluatedByUser($responseId) || !$this->_responseRatingCountBelowThreshold($responseId))
		return $result;


		$this->conn->_startTransaction();

		//Insert the evaluation data
		$sql = "INSERT INTO evaluation (fk_response_id, fk_user_id, score_overall, score_intonation, score_fluency, score_rhythm, score_spontaneity, comment, adding_date) VALUES (";
		$sql = $sql . "'%d', ";
		$sql = $sql . "'%d', ";
		$sql = $sql . "'%d', ";
		$sql = $sql . "'%d', ";
		$sql = $sql . "'%d', ";
		$sql = $sql . "'%d', ";
		$sql = $sql . "'%d', ";
		$sql = $sql . "'%s', NOW() )";

		$evaluationId = $this->conn->_insert ( $sql, $evalData->responseId, $_SESSION['uid'], $evalData->overallScore,
		$evalData->intonationScore, $evalData->fluencyScore, $evalData->rhythmScore,
		$evalData->spontaneityScore, $evalData->comment );

		if(!$evaluationId){
			$this->conn->_failedTransaction();
			throw new Exception("Evaluation save failed");
		}

		//Insert video evaluation data
		$this->_getResourceDirectories();

		try{
			$videoPath = $this->red5Path .'/'. $this->evaluationFolder .'/'. $evalData->evaluationVideoFileIdentifier . '.flv';
			$mediaData = $this->mediaHelper->retrieveMediaInfo($videoPath);
			$duration = $mediaData->duration;
			$thumbnail = 'nothumb.png';
			if($mediaData->hasVideo){
				$snapshot_output = $this->mediaHelper->takeFolderedRandomSnapshots($videoPath, $this->imagePath, $this->posterPath);
				$thumbnail = 'default.jpg';
			}
		} catch (Exception $e){
			throw new Exception($e->getMessage());
		}



		$sql = "INSERT INTO evaluation_video (fk_evaluation_id, video_identifier, source, thumbnail_uri) VALUES (";
		$sql = $sql . "'%d', ";
		$sql = $sql . "'%s', ";
		$sql = $sql . "'Red5', ";
		$sql = $sql . "'%s')";
		$evaluationVideoId = $this->conn->_insert ( $sql, $evaluationId, $evalData->evaluationVideoFileIdentifier, $thumbnail );
		if(!$evaluationVideoId){
			$this->conn->_failedTransaction();
			throw new Exception("Evaluation save failed");
		}

		//Update the rating count for this response

		$update = $this->_updateResponseRatingAmount($responseId);
		if(!$update){
			$this->conn->_failedTransaction();
			throw new Exception("Evaluation save failed");
		}

		//Update the user's credit count
		$creditUpdate = $this->_addCreditsForEvaluating();
		if(!$creditUpdate){
			$this->conn->_failedTransaction();
			throw new Exception("Credit addition failed");
		}

		//Update the credit history
		$creditHistoryInsert = $this->_addEvaluatingToCreditHistory($responseId, $evaluationId);
		if(!$creditHistoryInsert){
			$this->conn->_failedTransaction();
			throw new Exception("Credit history update failed");
		}

		if($evaluationId && $update && $creditUpdate && $creditHistoryInsert){
			$this->conn->_endTransaction();
			$result = $this->_getUserInfo();
			$this->_notifyUserAboutResponseBeingAssessed($evalData);
		}

		return $result;

	}

	/**
	 * Grants the current user some credits for assessing other user, and thus, collaborating with the system
	 * @return mixed $results
	 * 		Returns true when the sql operation went well or null when an error happened
	 */
	private function _addCreditsForEvaluating() {
		$sql = "UPDATE (users u JOIN preferences p)
				SET u.creditCount=u.creditCount+p.prefValue
				WHERE (u.ID=%d AND p.prefName='evaluatedWithVideoCredits') ";
		return $this->conn->_update ( $sql, $_SESSION['uid'] );
	}

	/**
	 * Adds an entry in the user's credit history stating that he/she has done an assessment
	 *
	 * @param int $responseId
	 * 		Response identificator
	 * @param int $evaluationId
	 * 		Assessment identificator
	 * @return int $insert
	 * 		Returns true if data was successfully inserted. Returns false otherways.
	 */
	private function _addEvaluatingToCreditHistory($responseId, $evaluationId){
		$sql = "SELECT prefValue FROM preferences WHERE ( prefName= 'evaluatedWithVideoCredits' )";
		$row = $this->conn->_singleSelect ( $sql );
		if($row){
			$changeAmount = $row->prefValue;
			$sql = "SELECT fk_exercise_id FROM response WHERE (id='%d')";
			$row = $this->conn->_singleSelect($sql, $responseId);
			if($row){
				$exerciseId = $row->fk_exercise_id;
				$sql = "INSERT INTO credithistory (fk_user_id, fk_exercise_id, fk_response_id, fk_eval_id, changeDate, changeType, changeAmount) ";
				$sql = $sql . "VALUES ('%d', '%d', '%d', '%d', NOW(), '%s', '%d') ";
				return $this->conn->_insert($sql, $_SESSION['uid'], $exerciseId, $responseId, $evaluationId, 'evaluation', $changeAmount);
			} else {
				return false;
			}
		} else {
			return false;
		}
	}

	/**
	 * Each time the current user assesses another user's responses it's own responses get a boost in the pending response queue
	 *
	 * @return int $result
	 * 		Returns true if the query was successful. Returns null otherways.
	 */
	private function _updatePendingAssessmentsPriority(){
		$sql = "UPDATE response SET priority_date = NOW() WHERE fk_user_id = '%d' ";

		return $this->conn->_update ( $sql, $_SESSION['uid'] );
	}

	/**
	 * Retrieves current user's data
	 *
	 * @return mixed $result
	 * 		Returns an object with the user's info or false when the query didn't have any results
	 */
	private function _getUserInfo(){

		$sql = "SELECT name, creditCount, joiningDate, isAdmin FROM users WHERE (id = %d) ";
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

	/**
	 * Attempts to send an email to notify the user whose response's being assessed of this fact
	 *
	 * @param stdClass $evaluation
	 * 		An object with the following properties: (responseId, responseUserName, responseAddingDate, exerciseTitle, userName, responseFileIdentifier)
	 * @return boolean $sent
	 * 		Returns true if the smtp server procedures were successful or false otherways.
	 */
	private function _notifyUserAboutResponseBeingAssessed($evaluation){

		$sql = "SELECT language
				FROM user_languages 
				WHERE ( level=7 AND fk_user_id = (SELECT fk_user_id FROM response WHERE id='%d') ) LIMIT 1";
		$row = $this->conn->_singleSelect($sql, $evaluation->responseId);
		
		//If the user has not languages defined, fallback to en_US by default
		$locale = $row ? $row->language : 'en_US';

		$mail = new Mailer($evaluation->responseUserName);

		$subject = 'Babelium Project: You have been assessed';

		$args = array(
						'DATE' => $evaluation->responseAddingDate,
						'EXERCISE_TITLE' => $evaluation->exerciseTitle,
						'EVALUATOR_NAME' => $evaluation->userName,
						'ASSESSMENT_LINK' => 'http://'.$_SERVER['HTTP_HOST'].'/Main.html#/evaluation/revise/'.$evaluation->responseFileIdentifier,
						'SIGNATURE' => 'The Babelium Project Team');

		if ( !$mail->makeTemplate("assessment_notify", $args, $locale) )
			return null;

		return ($mail->send($mail->txtContent, $subject, $mail->htmlContent));
	}

	/**
	 * Increments the given responses assessment count by one unit
	 *
	 * @param int $responseId
	 *
	 * @return boolean $result
	 * 		Returns true if successful query. Return false otherways.
	 */
	private function _updateResponseRatingAmount($responseId){
		$sql = "UPDATE response SET rating_amount = (rating_amount + 1)
		        WHERE (id = '%d')";

		return $this->conn->_update ( $sql, $responseId );
	}

}


?>
