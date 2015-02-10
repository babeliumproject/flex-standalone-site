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
require_once 'utils/SessionValidation.php';
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
	private $cfg;

	private $imagePath;
	private $posterPath;
	private $red5Path;

	private $evaluationFolder = '';
	private $exerciseFolder = '';
	private $responseFolder = '';
	private $evaluationThreshold = 4;

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
			$verifySession = new SessionValidation(true);
			$settings = new Config ( );
			$this->cfg = $settings;
			$this->imagePath = $settings->imagePath;
			$this->posterPath = $settings->posterPath;
			$this->red5Path = $settings->red5Path;
			$this->conn = new Datasource ( $settings->host, $settings->db_name, $settings->db_username, $settings->db_password );
			$this->mediaHelper = new VideoProcessor();

		} catch (Exception $e) {
			throw new Exception($e->getMessage());
		}
	}
	
	private function getAssessmentLimit(){
		$sql = "SELECT prefValue FROM preferences WHERE prefName='trial_threshold'";
		$result = $this->conn->_singleSelect ( $sql );
		if($result){
			$this->evaluationThreshold = $result->prefValue;
		}
	}

	/**
	 * Retrieves all the responses that haven't been evaluated (and can be evaluated) by the current user
	 *
	 * @return array $searchResults
	 * 		An array of objects with data about the responses that haven't been already evaluated by the current user
	 */
	public function getResponsesWaitingAssessment($offset=0, $rowcount=0) {
		
		$this->getAssessmentLimit();
		$assessmentlimit=$this->evaluationThreshold;

		$langpurpose = 'evaluate';
		
		$userid = $_SESSION['uid'];
		$userlanguages = $_SESSION['user-languages'];
		if($userlanguages){
			$term = "";
			foreach($userlanguages as $ul){
				if($ul->purpose==$langpurpose){
					$l = substr($ul->language,0,2);
					$term = $term . " B.language LIKE '".$l."\_%%' OR"; //% must be escaped using a double %%, otherwise vsprintf() fails
				}
			}
		}
		$finalterm=null;
		if(!empty($term)){
			$finalterm = "(".substr($term, 0, -2).")";
		}
		
		$sql = "SELECT DISTINCT A.file_identifier as responseFileIdentifier,
								A.id as responseId, 
								A.rating_amount as responseRatingAmount, 
								A.character_name as responseCharacterName, 
								A.fk_subtitle_id as responseSubtitleId,
		                        A.adding_date as responseAddingDate, 
		                        A.source as responseSource, 
		                        A.thumbnail_uri as responseThumbnailUri, 
		                        A.duration as responseDuration, 
		                        F.username as responseUserName, 
		                        B.id as exerciseId, 
		                        B.exercisecode as exerciseName, 
		                        B.language as exerciseLanguage, 
		                        B.title as exerciseTitle, 
		                        B.difficulty exerciseAvgDifficulty
				FROM response AS A INNER JOIN exercise AS B on A.fk_exercise_id = B.id 
				     INNER JOIN user AS F on A.fk_user_id = F.id
				WHERE B.status = 1 AND A.rating_amount < %d AND A.fk_user_id <> %d AND A.is_private = 0
				AND NOT EXISTS (SELECT D.id FROM evaluation AS D WHERE D.fk_response_id = A.id AND D.fk_user_id = %d)";
				
		if($finalterm){
			$sql.= " AND ".$finalterm;
		}
		
        $sql .= " GROUP BY A.id ORDER BY A.priority_date DESC, A.adding_date DESC";
		
		if($rowcount){
			$sql .= " LIMIT %d,%d";
			$tmpresults = $this->conn->_multipleSelect($sql, $assessmentlimit, $userid, $userid, $offset, $rowcount);
		} else {
			$tmpresults = $this->conn->_multipleSelect($sql, $assessmentlimit, $userid, $userid);
		}
		
		$defresults = null;
		if($tmpresults){	
			$defresults = array();
			foreach ($tmpresults as $r){
				$rf = $this->getResponseRelatedData($r);
				$rf = $this->checkMerged($rf);
				array_push($defresults, $rf);
			}
		}
		
		$searchResults = $this->conn->multipleRecast('EvaluationVO',$defresults);
		
		return $searchResults;
	}

	/**
	 * Retrieves those responses of the current user that have been evaluated by another user
	 *
	 * @return array $searchResults
	 * 		An array of objects with data about the responses of the current user that have been evaluated
	 */
	public function getResponsesAssessedToCurrentUser($offset=0, $rowcount=0){
		$userid = $_SESSION['uid'];

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
		               B.exercisecode as exerciseName, 
		               B.language AS exerciseLanguage, 
		               B.title AS exerciseTitle, 
		               AVG(C.score_overall) AS overallScoreAverage, 
		               AVG(C.score_intonation) AS intonationScoreAverage, 
		               AVG(score_fluency) AS fluencyScoreAverage, 
		               AVG(score_rhythm) AS rhythmScoreAverage, 
		               AVG(score_spontaneity) AS spontaneityScoreAverage,
		               B.difficulty as exerciseAvgDifficulty, 
		               MAX(C.adding_date) AS addingDate
		        FROM response AS A INNER JOIN exercise AS B ON B.id = A.fk_exercise_id
					 LEFT OUTER JOIN evaluation AS C ON C.fk_response_id = A.id 
				WHERE ( A.fk_user_id = '%d' AND B.status=1 ) 
				GROUP BY A.id,B.id 
				ORDER BY A.adding_date DESC";
		
		if($rowcount){
			$sql .= " LIMIT %d,%d";
			$tmpresults = $this->conn->_multipleSelect($sql, $userid, $offset, $rowcount);
		} else {
			$tmpresults = $this->conn->_multipleSelect($sql, $userid);
		}
		
		$defresults = null;
		if($tmpresults){
			$defresults = array();
			foreach ($tmpresults as $r){
				$rf = $this->getResponseRelatedData($r);
				$rf = $this->checkMerged($rf);
				array_push($defresults, $rf);
			}
		}

		$searchResults = $this->conn->multipleRecast('EvaluationVO',$defresults);

		return $searchResults;
	}

	/**
	 * Retrieves the responses which the current user evaluated to another user
	 *
	 * @return	array $searchResults
	 * 		Returns an array of objects with data about the responses the current user evaluated to another user
	 */
	public function getResponsesAssessedByCurrentUser($offset=0, $rowcount=0){
		
		$userid = $_SESSION['uid'];
		
		$sql = "SELECT DISTINCT A.file_identifier as responseFileIdentifier,
								A.id as responseId, 
								A.rating_amount as responseRatingAmount, 
								A.character_name as responseCharacterName, 
								A.fk_subtitle_id as responseSubtitleId,
		               			A.adding_date as responseAddingDate, 
		               			A.source as responseSource, 
		               			A.thumbnail_uri as responseThumbnailUri, 
		               			A.duration as responseDuration,
		               			U.username as responseUserName, 
		               			C.score_overall as overallScore, 
		               			C.score_intonation as intonationScore, 
		               			C.score_fluency as fluencyScore, 
		               			C.score_rhythm as rhythmScore,
		               			C.score_spontaneity as spontaneityScore, 
		               			C.comment, 
		               			C.adding_date as addingDate,
		               			B.id as exerciseId, 
		               			B.exercisecode as exerciseName, 
		               			B.language as exerciseLanguage, 
		               			B.difficulty as exerciseAvgDifficulty, 
		               			B.title as exerciseTitle, 
		               			E.video_identifier as evaluationVideoFileIdentifier, 
		               			E.thumbnail_uri as evaluationVideoThumbnailUri 
			    FROM response AS A INNER JOIN exercise AS B ON B.id = A.fk_exercise_id  
			         INNER JOIN evaluation AS C ON C.fk_response_id = A.id
			         INNER JOIN user AS U ON U.id = A.fk_user_id
			         LEFT OUTER JOIN evaluation_video AS E ON C.id = E.fk_evaluation_id
			    WHERE (C.fk_user_id = '%d' AND B.status=1)
			    ORDER BY C.adding_date DESC";
		
		if($rowcount){
			$sql .= " LIMIT %d,%d";
			$tmpresults = $this->conn->_multipleSelect($sql, $userid, $offset, $rowcount);
		} else {
			$tmpresults = $this->conn->_multipleSelect($sql, $userid);
		}
		
		$defresults = null;
		if($tmpresults){
			$defresults = array();
			foreach ($tmpresults as $r){
				$rf = $this->getResponseRelatedData($r);
				$rf = $this->checkMerged($rf);
				array_push($defresults, $rf);
			}
		}
		
		$searchResults = $this->conn->multipleRecast('EvaluationVO', $defresults);

		return $searchResults;
	}

	/**
	 * 
	 * Check if the video related to this evaluation-response has been 
	 * merged with its related exercise so it can be played as a single video
	 * @param array $results
	 * 		array of EvaluationVO objects
	 */
	public function checkMerged($response){
		if(!$response) return;
		
		$r = $response;

		//-1: unknown, 0: not merged, 1: merged
		$mergeStatus = $this->_mergedVideoReady($r->responseFileIdentifier);
		$r->mergeStatus = $mergeStatus;
		//
		//if($mergeStatus == 1){
		//	$r->responseFileIdentifier = $r->responseFileIdentifier . '_merge';
		//}
		return $r;
	}
	
	private function getResponseRelatedData($response){
		if(!$response) return;
	
		require_once 'Exercise.php';
		$ex = new Exercise();
		$r = $response;
	
		$exerciseid = $r->exerciseId;
		$ethumburl = $ex->getExerciseDefaultThumbnail($exerciseid);
		$rthumburl = $this->cfg->wwwroot . '/resources/images/thumbs/';
		if ($r->responseThumbnailUri == 'default.jpg') {
			$rthumburl .= $r->responseFileIdentifier . '/default.jpg';
		} else {
			$rthumburl .= 'nothumb.png';
		}
		
		$r->exerciseThumbnailUri = $ethumburl;
		$r->responseThumbnailUri = $rthumburl;
	
		return $r;
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
			throw new Exception("Invalid parameters", 1000);
				
		$response = $this->getResponseData($responseId);
		
		if($response){
			$sql = "SELECT C.username as userName,
					   A.score_overall as overallScore, 
					   A.score_intonation as intonationScore, 
					   A.score_fluency as fluencyScore, 
					   A.score_rhythm as rhythmScore, 
					   A.score_spontaneity as spontaneityScore,
					   A.score_comprehensibility as comprehensibilityScore,
					   A.score_pronunciation as pronunciationScore,
					   A.score_adequacy as adequacyScore,
					   A.score_range as rangeScore,
					   A.score_accuracy as accuracyScore,
					   A.adding_date as addingDate, 
					   A.comment as comment, 
					   B.video_identifier as evaluationVideoFileIdentifier, 
					   B.thumbnail_uri as evaluationVideoThumbnailUri
			    FROM (evaluation AS A INNER JOIN user AS C ON A.fk_user_id = C.id) 
			    	 LEFT OUTER JOIN evaluation_video AS B on A.id = B.fk_evaluation_id 
				WHERE (A.fk_response_id = '%d') ";

			$response->assessments = $this->conn->multipleRecast('EvaluationVO',$this->conn->_multipleSelect ( $sql, $responseId ));
		}

		return $response;
	}
	
	protected function getResponseById($responseid){
		if(!$responseid) return;
		
		$sql = "SELECT r.*, u.username
				FROM response r INNER JOIN user u ON r.fk_user_id=u.id
				WHERE r.id=%d";
		
		$result = $this->conn->_singleSelect($sql, $responseid);
		return $result;
	}
	
	public function getResponseData($responseId){
		if(!$responseId)
			throw new Exception("Invalid parameters", 1000);
		
		$response = $this->getResponseById($responseId);
		if(!$response)
			throw new Exception("Response id does not exist",1006);
		
		//require_once 'Exercise.php';
		//$exservice = new Exercise();
		
		$status = 2; //Available media
		$exmedia = $this->getMediaById($response->fk_media_id,$status);
		if($exmedia){
			$response->leftMedia = $exmedia;
			
			$rightMedia = new stdClass();
			$rightMedia->netConnectionUrl = $this->cfg->streamingserver;
			$rightMedia->mediaUrl = 'responses/'.$response->file_identifier.'.flv';
			
			$response->rightMedia = $rightMedia;
		}
		
		return isset($response->leftMedia) ? $response : null;
	}
	
	protected function getMediaById($mediaid,$status){
		if(!$mediaid)
			throw new Exception("Invalid parameters",1000);
		
		$sql = "SELECT m.id, m.mediacode, m.instanceid, m.component, m.type, m.duration, m.level, m.defaultthumbnail, mr.status, mr.filename
				FROM media m INNER JOIN media_rendition mr ON m.id=mr.fk_media_id
				WHERE m.id=%d";
		 
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
		$sql .= " LIMIT 1";
		 
		$result = $this->conn->_singleSelect($sql, $mediaid, $sparam);
		if($result){
			$result->netConnectionUrl = $this->cfg->streamingserver;
			$result->mediaUrl = 'exercises/'.$result->filename;
		}
		return $result;
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
		$sql = "SELECT U.username as userName,
				E.score_overall as overallScore, 
				E.comment
				FROM evaluation AS E INNER JOIN user AS U ON E.fk_user_id = U.id 
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
				WHERE id = '%d' AND rating_amount < (SELECT prefValue FROM preferences WHERE prefName='trial_threshold')";
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

		$sql = "INSERT INTO evaluation (fk_response_id, fk_user_id, score_overall, score_intonation, score_fluency, score_rhythm, score_spontaneity, 
		                                score_comprehensibility, score_pronunciation, score_adequacy, score_range, score_accuracy, comment, adding_date) VALUES (";
		$sql = $sql . "'%d', ";
		$sql = $sql . "'%d', ";
		$sql = $sql . "'%d', ";
		$sql = $sql . "'%d', ";
		$sql = $sql . "'%d', ";
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
		$evalData->spontaneityScore, $evalData->comprehensibilityScore, $evalData->pronunciationScore, $evalData->adequacyScore, $evalData->rangeScore, $evalData->accuracyScore, $evalData->comment );
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
		$sql = "UPDATE (user u JOIN preferences p)
				SET u.creditCount=u.creditCount+p.prefValue
				WHERE (u.id=%d AND p.prefName='evaluatedWithVideoCredits') ";
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
		//First check if the user has recorded any responses to avoid false-negatives in the affected_rows call.
		$result = 1;
		$sql = "SELECT id FROM response WHERE fk_user_id = '%d'";
		$responses = $this->conn->_multipleSelect( $sql, $_SESSION['uid'] );
		if($responses){
			//The user has recorded some responses, update their priorities as a way of giving thanks
			$sql = "UPDATE response SET priority_date = NOW() WHERE fk_user_id = '%d' ";
			$result = $this->conn->_update ( $sql, $_SESSION['uid'] );
		}
		return $result;

	}

	/**
	 * Retrieves current user's data
	 *
	 * @return mixed $result
	 * 		Returns an object with the user's info or false when the query didn't have any results
	 */
	private function _getUserInfo(){

		$sql = "SELECT username, creditCount, joiningDate, isAdmin FROM user WHERE (id = %d) ";
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
						'ASSESSMENT_LINK' => 'http://'.$_SERVER['HTTP_HOST'].'/#/assessments/view/'.$evaluation->responseId,
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

	private function _mergedVideoReady($identifier){
		
		if(!$this->responseFolder || strlen($this->responseFolder))
			$this->_getResourceDirectories();
		$responsefile = $this->red5Path . '/' . $this->responseFolder . '/' . $identifier . '_merge.flv';
		
		if(is_readable($responsefile)){
			return @is_link($responsefile) ? 0 : 1;
		} else {
			return -1;
		}
	}
}


?>
