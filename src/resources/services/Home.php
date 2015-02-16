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

require_once 'vo/MotdVO.php';

require_once 'Evaluation.php';
require_once 'Exercise.php';

/**
 * Class to perform user's recent activity or homepage activy operations
 * 
 * @author Babelium Team
 *
 */
class Home{

	private $conn;

	/**
	 * Constructor function
	 * 
	 * @throws Exception
	 * 		Thrown if there is a problem establishing a connection with the database
	 */
	public function __construct(){
		try {
			$verifySession = new SessionValidation();
			$settings = new Config ();
			$this->conn = new Datasource ( $settings->host, $settings->db_name, $settings->db_username, $settings->db_password );
		} catch (Exception $e) {
			throw new Exception($e->getMessage());
		}

	}

	/**
	 * Returns the messages of the day (in the specified language) that visitor users can see 
	 * 
	 * @param String $messageLocale
	 * 		The locale of the messages that are going to be retrieved in the IETF language format (http://en.wikipedia.org/wiki/BCP_47). For example, en_US
	 * @return mixed
	 * 		An array of stdClass with message of the day data. False on empty set or error
	 */
	public function unsignedMessagesOfTheDay($messageLocale = 0){

		if(!$messageLocale)
			return false;
		$sql = "SELECT title, 
					   message, 
					   code, 
					   language, 
					   resource as resourceUrl
				FROM motd 
				WHERE ( CURDATE() >= displayDate AND language='%s' AND displaywhenloggedin = false ) ";

		$searchResults = $this->conn->_multipleSelect($sql, $messageLocale);

		return $this->conn->multipleRecast('MotdVO', $searchResults);

	}

	/**
	 * Returns the messages of the day (in the specified language) that a logged-in user can see
	 * 
	 * @param String $messageLocale
	 * 		The locale of the messages that are going to be retrieved in the IETF language format (http://en.wikipedia.org/wiki/BCP_47). For example, en_US
	 * @return mixed
	 * 		An array of stdClass with message of the day data. False on empty set or error
	 */
	public function signedMessagesOfTheDay($messageLocale = 0){

		if(!$messageLocale)
			return false;
		$sql = "SELECT title, 
					   message, 
					   code, 
					   language, 
					   resource as resourceUrl 
				FROM motd 
				WHERE ( CURDATE() >= displayDate AND language='%s' AND displaywhenloggedin = true ) ";

		$searchResults = $this->conn->_multipleSelect($sql, $messageLocale);

		return $this->conn->multipleRecast('MotdVO', $searchResults);

	}

	/**
	 * Returns the latest 5 assessments the currently logged-in user has received
	 * 
	 * @return mixed
	 * 		An array of stdClass with evaluation data. False on empty set or error.
	 */
	public function usersLatestReceivedAssessments(){
		$sql = "SELECT D.file_identifier as responseFileIdentifier, 
					   D.id as responseId, 
					   D.rating_amount as responseRatingAmount, 
					   D.character_name as responseCharacterName, 
					   D.fk_subtitle_id as responseSubtitleId,
		               D.adding_date as responseAddingDate, 
		               D.source as responseSource, 
		               D.thumbnail_uri as responseThumbnailUri, 
		               D.duration as responseDuration,
		               C.username as responseUserName, 
		               A.score_overall as overallScore, 
		               A.score_intonation as intonationScore, 
		               A.score_fluency as fluencyScore, 
		               A.score_rhythm as rhythmScore,
		               A.score_spontaneity as spontaneityScore, 
		               A.comment, 
		               A.adding_date as addingDate,
		               E.id as exerciseId, 
		               E.name as exerciseName, 
		               E.duration as exerciseDuration, 
		               E.language as exerciseLanguage, 
		               E.thumbnail_uri as exerciseThumbnailUri, 
		               E.title as exerciseTitle, 
		               E.source as exerciseSource 
			    FROM evaluation A 
			    	 INNER JOIN response D ON A.fk_response_id = D.id
			    	 INNER JOIN exercise E ON D.fk_exercise_id = E.id
			    	 INNER JOIN user C ON A.fk_user_id = C.id
				WHERE (D.fk_user_id = '%d') 
				ORDER BY A.adding_date DESC";
		
		/*
		 * If we change the data displaying widget later on we could add this to the sql statement
		 * 
		 * LEFT OUTER JOIN exercise_level F ON E.id=F.fk_exercise_id
		 * LEFT OUTER JOIN evaluation_video B ON A.id = B.fk_evaluation_id 
		 */

		$searchResults = $this->conn->_multipleSelect ( $sql, $_SESSION['uid'] );

		$slicedResults = $this->sliceResultsByNumber($searchResults,5);

		return $this->conn->multipleRecast('EvaluationVO', $slicedResults);
	}

	/**
	 * Returns the latest 5 assessments the currently logged-in user has done to other users
	 
	 * @return mixed
	 * 		An array of stdClass with evaluation data. False on empty set or error.
	 */
	public function usersLatestGivenAssessments(){

		$results = array();

		//List of all the assessments done by the user
		$evaluation = new Evaluation();
		$givenAssessments = $evaluation->getResponsesAssessedByCurrentUser();

		return $this->sliceResultsByNumber($givenAssessments, 5);
	}
	
	/**
	 * Returns the first $length positions of the provided data array
	 * 
	 * @param mixed $searchResults
	 * 		The array of data to be cut
	 * @param int $length
	 * 		How many positions from the start are going to be returned
	 * @return array $results
	 * 		A subset of the provided array
	 */
	private function sliceResultsByNumber($searchResults, $length){
		$results = array();
		
		if( count($searchResults) > $length )
			$results = array_slice($searchResults, 0, $length);
		else
			$results = $searchResults;

		return $results;
	}
	
	/**
	 * Returns only the items whose date is newer than the provided time interval
	 * 
	 * @param array $searchResults
	 * @param int $timeInterval
	 * 		A time interval measured in seconds the item needs to meet in order to be returned. 
	 * 		For example, 3600 will give you the items that were added less than an hour ago
	 * @return array $results
	 * 		An array of items that are more recent than the specified time interval
	 */
	private function sliceResultsByDate($searchResults, $timeInterval){
		$results = array();
		$currentTime = time();

		 //Filter the results and show only the assessments done in the last weeek
		 foreach($searchResults as $searchResult){
			$evalTime = strtotime($searchResult->addingDate);
			if ($evalTime <= $currentTime && ($currentTime - $evalTime) < $timeInterval)
				array_push($results, $searchResult);
		}
		return $results;
	}

	/**
	 * TODO
	 * Returns the latest videos uplodaded by the currently logged-in user
	 * 
	 * @return array $results
	 * 		An array of stdClass with info about the latest uploaded exercises
	 */
	public function usersLatestUploadedVideos(){
		$results = array();
		return $results;
	}

	/**
	 * Returns a list of the exercises with best scores and most views
	 * 
	 * @return mixed
	 * 		An array of stdClass with info about the exercise. False on empty set or error.
	 */
	public function topScoreMostViewedVideos(){
		$exercise = new Exercise();
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
		               u.username as userName, 
		               avg (suggested_level) as avgDifficulty, 
		               e.status, 
		               e.license, 
		               e.reference, 
		               a.complete as isSubtitled,
		               e.ismodel
				FROM exercise e 
					 INNER JOIN user u ON e.fk_user_id= u.id
	 				 LEFT OUTER JOIN exercise_score s ON e.id=s.fk_exercise_id
       				 LEFT OUTER JOIN exercise_level l ON e.id=l.fk_exercise_id
       				 LEFT OUTER JOIN subtitle a ON e.id=a.fk_exercise_id
       			WHERE e.status = 'Available' AND e.ismodel=0
				GROUP BY e.id
				ORDER BY e.adding_date DESC";
		
		$searchResults = $this->conn->_multipleSelect($sql);
		foreach($searchResults as $searchResult){
			$searchResult->avgRating = $exercise->getExerciseAvgBayesianScore($searchResult->id)->avgRating;
		}

		$filteredResults = $exercise->filterByLanguage($searchResults, 'practice');
		
		usort($filteredResults, array($this, 'sortResultsByScore'));
		$slicedResults = $this->sliceResultsByNumber($filteredResults, 10);
		
		return $this->conn->multipleRecast('ExerciseVO', $slicedResults);
	}
	
	/**
	 * Compares two exercises and sorts them using their average rating
	 * 
	 * @param stdClass $exerciseA
	 * 		An object with exercise data
	 * @param stdClass $exerciseB
	 * 		An object with exercise data
	 * @return int
	 * 		A number that tells the caller which of the exercises had a better average rating
	 */
	private function sortResultsByScore($exerciseA, $exerciseB){
		if ($exerciseA->avgRating == $exerciseB->avgRating) {
        	return 0;
    	}
    	return ($exerciseA->avgRating < $exerciseB->avgRating) ? -1 : 1;
	}

	/**
	 * Returns a list of the most recently uploaded videos that are available to be subtitled or practiced
	 * 
	 * @return mixed
	 * 		An array of stdClass with info about the exercises. False on empty set or error.
	 */
	public function latestAvailableVideos(){
		$exercise = new Exercise();
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
		               u.username as userName, 
		               avg (suggested_level) as avgDifficulty, 
		               e.status, 
		               e.license, 
		               e.reference, 
		               a.complete as isSubtitled,
		               e.ismodel
				FROM exercise e 
					 INNER JOIN user u ON e.fk_user_id= u.id
	 				 LEFT OUTER JOIN exercise_score s ON e.id=s.fk_exercise_id
       				 LEFT OUTER JOIN exercise_level l ON e.id=l.fk_exercise_id
       				 LEFT OUTER JOIN subtitle a ON e.id=a.fk_exercise_id
       			WHERE e.status = 'Available' AND e.ismodel=0
				GROUP BY e.id
				ORDER BY e.adding_date DESC";
		
		$searchResults = $this->conn->_multipleSelect($sql);
		foreach($searchResults as $searchResult){
			$searchResult->avgRating = $exercise->getExerciseAvgBayesianScore($searchResult->id)->avgRating;
		}

		$filteredResults = $exercise->filterByLanguage($searchResults, 'practice');
		$slicedResults = $this->sliceResultsByNumber($filteredResults, 10);
		return $this->conn->multipleRecast('ExerciseVO', $slicedResults);
	}


}
