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

require_once 'vo/TranscriptionsVO.php';

/**
 * This class provides means for automatically transcribing an audio extracted from an short duration exercise using the
 * chosen transcription API (Default API is SpinVox)
 * 
 * @author Babelium Team
 *
 */
class Transcription {

	private $conn;

	public function __construct() {
		try {
			$verifySession = new SessionHandler(true);

			$settings = new Config();
			$this->conn = new Datasource($settings->host, $settings->db_name, $settings->db_username, $settings->db_password);
		} catch (Exception $e) {
			throw new Exception($e->getMessage());
		}
	}

	public function getResponseTranscriptions($responseId) {
		$sql = "SELECT T.id AS responseTranscriptionId, 
					   R.id AS responseId, 
					   R.fk_exercise_id AS exerciseId, 
					   T.adding_date AS responseTranscriptionAddingDate, 
					   T.status AS responseTranscriptionStatus, 
					   T.transcription AS responseTranscription, 
					   T.transcription_date AS responseTranscriptionDate, 
					   T.system AS responseTranscriptionSystem 
				FROM transcription AS T INNER JOIN response AS R ON T.id=R.fk_transcription_id 
				WHERE ( R.id = %d ) ";
		$resultResp = $this->conn->_singleSelect($sql, $responseId);
		if(!$resultResp){
			return null;
		}

		$sql = "SELECT T.id AS exerciseTranscriptionId, 
							E.id AS exerciseId, 
							T.adding_date AS exerciseTranscriptionAddingDate, 
							T.status AS exerciseTranscriptionStatus, 
							T.transcription AS exerciseTranscription, 
							T.transcription_date AS exerciseTranscriptionDate, 
							T.system AS system as exerciseTranscriptionSystem 
				FROM transcription AS T INNER JOIN exercise AS E ON T.id=E.fk_transcription_id 
				WHERE (E.id = %d)";
		$resultEx = $this->conn->_singleSelect($sql, $resultResp->exerciseId);
		
		if($resultEx){
			foreach($resultEx as $key=>$value){
				$resultResp->$key = $value;
			}
		} else {
			return null;
		}

		return $this->conn->recast('TranscriptionVO', $resultResp);
	}

	public function enableTranscriptionToExercise($exerciseId, $transcriptionSystem) {
		if ($exerciseId > 0 && $transcriptionSystem != null && $_SERVER['uid'] > 0) {

			if(!$this->checkAutoevaluationSupportExercise($exerciseId, $transcriptionSystem))
			return "transcription not supported for this video";
				
			//Check if user is admin
			$sql = "SELECT isAdmin FROM users WHERE id = %d";
			$result = $this->conn->_singleSelect($sql, $_SESSION['uid']);
			if ($result->isAdmin <= 0)
				return "only admin users can enable transcriptions to exercises";
				
			$sql = "SELECT * FROM transcription AS T INNER JOIN exercise AS E ON T.id=E.fk_transcription_id WHERE E.id = %d";
			$result = $this->conn->_singleSelect($sql, $exerciseId);
			if (!$result) {
				$insert = "INSERT INTO transcription (id, adding_date, status, transcription, transcription_date, system) VALUES (null, now(), 'pending' , null, null, '%s')";
				$i = $this->conn->_insert($insert, strtolower($transcriptionSystem));
				if ($i > 0) {
					$update = "UPDATE exercise SET fk_transcription_id = LAST_INSERT_ID() WHERE id = %d";
					if ($this->conn->_update($update, $exerciseId) > 0)
						return $i;
					else
						return "error";
				} else
					return -1;
			} else
				return "transcription already exists";
		} else
			return "wrong data";
	}

	public function enableTranscriptionToResponse($responseId, $transcriptionSystem) {
		if ($responseId > 0 && $transcriptionSystem != null) {

			if(!$this->checkAutoevaluationSupportResponse($responseId, $transcriptionSystem))
			return "transcription not supported for this video";

			$sql = "SELECT * FROM transcription AS T INNER JOIN response AS R ON T.id=R.fk_transcription_id WHERE R.id = %d";
			$result = $this->conn->_singleSelect($sql, $responseId);
			if (!$result) {
				$insert = "INSERT INTO transcription (id, adding_date, status, transcription, transcription_date, system) VALUES (null, now(), 'pending' , null, null, '%s')";
				$i = $this->conn->_insert($insert, strtolower($transcriptionSystem));
				if ($i > 0) {
					$update = "UPDATE response SET fk_transcription_id = LAST_INSERT_ID() WHERE id = %d";
					if ($this->conn->_update($update, $responseId) > 0)
					return $i;
					else
					return "error";
				} else
				return -1;
			} else
			return "transcription already exists";
		} else
		return "wrong data";
	}

	// transcriptionSystem = spinvox (maybe we will change this system in the future)
	public function checkAutoevaluationSupportResponse($responseId, $transcriptionSystem) {
		if ($responseId > 0 && $transcriptionSystem != null) {
			$sql = "SELECT prefValue FROM preferences WHERE prefName='%s.max_duration'";
			$result = $this->conn->_singleSelect($sql, strtolower($transcriptionSystem));
			if ($result)
				$maxDuration = $result->prefValue;
			else
				$maxDuration = 0;

			// if
			// original video has a transcription
			// and video's response hasn't
			// and transcriptionSystem supports actual language (original video's language. The video's language code may be something like en_EN so the first part (en) must be extracted)
			// and response's duration <= transcription System's allowed duration
			//  return true
			// else return false;
			$sql = "SELECT R.id
			        FROM response AS R 
			             INNER JOIN exercise AS E ON R.fk_exercise_id=E.id  
			             INNER JOIN preferences AS P ON SUBSTRING_INDEX(E.language, '_', 1)=P.prefValue 
			        WHERE R.id=%d AND P.prefName = '%s.language' AND E.fk_transcription_id IS NOT NULL AND R.fk_transcription_id IS NULL";
				
			if ($maxDuration > 0)
				$sql = $sql . " AND R.duration<=%s";
				
			$result = $this->conn->_singleSelect($sql, $responseId, strtolower($transcriptionSystem), $maxDuration);
			return $result ? true : false;
		} else
			return false;
	}

	public function checkAutoevaluationSupportExercise($exerciseId, $transcriptionSystem) {
		if ($exerciseId > 0 && $transcriptionSystem != null) {
			$sql = "SELECT prefValue FROM preferences WHERE prefName='%s.max_duration'";
			$result = $this->conn->_singleSelect($sql, strtolower($transcriptionSystem));
			if ($result)
				$maxDuration = $result->prefValue;
			else
				$maxDuration = 0;

			// if
			// original video doesn't have a transcription
			// and transcriptionSystem supports video's language (The video's language code may be something like en_EN so the first part (en) must be extracted)
			// and video's duration <= transcription System's allowed duration
			//  return true
			// else return false;
			$sql = "SELECT E.id
					FROM exercise AS E 
						INNER JOIN preferences AS P ON SUBSTRING_INDEX(E.language, '_', 1)=P.prefValue 
					WHERE 
						E.id=%d AND P.prefName = '%s.language' 
						AND 
						E.fk_transcription_id IS NULL";
				
			if ($maxDuration > 0)
				$sql = $sql . " AND E.duration<=%d";
				
			$result = $this->conn->_singleSelect($sql, $exerciseId, strtolower($transcriptionSystem), $maxDuration);
			
			return $result ? true : false;
		} else
			return false;
	}

}
?>
