<?php

require_once 'utils/Config.php';
require_once 'utils/Datasource.php';
require_once 'utils/SessionHandler.php';

require_once 'vo/ExerciseVO.php';
require_once 'vo/ExerciseReportVO.php';
require_once 'vo/ExerciseScoreVO.php';
require_once 'vo/ExerciseLevelVO.php';
require_once 'vo/UserVO.php';

class ExerciseDAO {

	private $conn;
	private $filePath;
	private $imagePath;
	private $red5Path;

	private $evaluationFolder = '';
	private $exerciseFolder = '';
	private $responseFolder = '';

	private $exerciseGlobalAvgRating;
	private $exerciseMinRatingCount;

	public function ExerciseDAO() {

		try {
			$verifySession = new SessionHandler();
			$settings = new Config ( );
			$this->filePath = $settings->filePath;
			$this->imagePath = $settings->imagePath;
			$this->red5Path = $settings->red5Path;
			$this->conn = new Datasource ( $settings->host, $settings->db_name, $settings->db_username, $settings->db_password );

		} catch (Exception $e) {
			throw new Exception($e->getMessage());
		}
	}

	public function addUnprocessedExercise($exercise) {

		try {
			$verifySession = new SessionHandler(true);

			$exerciseLevel = new ExerciseLevelVO();
			$exerciseLevel->userId = $_SESSION['uid'];
			$exerciseLevel->suggestedLevel = $exercise->avgDifficulty;

			$sql = "INSERT INTO exercise (name, title, description, tags, language, source, fk_user_id, adding_date, duration, license, reference) ";
			$sql .= "VALUES ('%s', '%s', '%s', '%s', '%s', 'Red5', '%d', now(), '%d', '%s', '%s') ";

			$lastExerciseId = $this->_create( $sql, $exercise->name, $exercise->title, $exercise->description, $exercise->tags,
			$exercise->language, $_SESSION['uid'], $exercise->duration, $exercise->license, $exercise->reference );
			if($lastExerciseId){
				$exerciseLevel->exerciseId = $lastExerciseId;
				if($this->addExerciseLevel($exerciseLevel))
				return $lastExerciseId;
			}

		} catch (Exception $e) {
			throw new Exception($e->getMessage());
		}

	}

	public function addWebcamExercise($exercise) {

		try {

			$verifySession = new SessionHandler(true);
			
			$result = 0;

			set_time_limit(0);
			$this->_getResourceDirectories();

			$duration = $this->calculateVideoDuration($exercise->name);
			$this->takeRandomSnapshot($exercise->name, $exercise->name);

			$exerciseLevel = new ExerciseLevelVO();
			$exerciseLevel->userId = $_SESSION['uid'];
			$exerciseLevel->suggestedLevel = $exercise->avgDifficulty;
				
			$this->conn->_startTransaction();

			$sql = "INSERT INTO exercise (name, title, description, tags, language, source, fk_user_id, adding_date, status, thumbnail_uri, duration, license, reference) ";
			$sql .= "VALUES ('%s', '%s', '%s', '%s', '%s', 'Red5', '%d', now(), 'Available', '%s', '%d', '%s', '%s') ";

			$lastExerciseId = $this->_create( $sql, $exercise->name, $exercise->title, $exercise->description, $exercise->tags,
			$exercise->language, $_SESSION['uid'], $exercise->name.'.jpg', $duration, $exercise->license, $exercise->reference );
				
			if(!$lastExerciseId){
				$this->conn->_failedTransaction();
				throw new Exception ("Exercise save failed.");
			}
				
			$exerciseLevel->exerciseId = $lastExerciseId;
			$insertLevel = $this->addExerciseLevel($exerciseLevel);
			if(!$insertLevel){
				$this->conn->_failedTransaction();
				throw new Exception ("Exercise level save failed.");
			}
				
			//Update the user's credit count
			$creditUpdate = $this->_addCreditsForUploading();
			if(!$creditUpdate){
				$this->conn->_failedTransaction();
				throw new Exception("Credit addition failed");
			}

			//Update the credit history
			$creditHistoryInsert = $this->_addUploadingToCreditHistory($lastExerciseId);
			if(!$creditHistoryInsert){
				$this->conn->_failedTransaction();
				throw new Exception("Credit history update failed");
			}
				
			if($lastExerciseId && $insertLevel && $creditUpdate && $creditHistoryInsert){
				$this->conn->_endTransaction();
				$result = $this->_getUserInfo();
			}
				
			return $result;

		} catch (Exception $e) {
			throw new Exception($e->getMessage());
		}
	}

	private function addExerciseLevel($exerciseLevel){
		$sql = "INSERT INTO exercise_level (fk_exercise_id, fk_user_id, suggested_level, suggest_date)
						 VALUES ('%d', '%d', '%d', NOW()) ";
		return $this->_create($sql, $exerciseLevel->exerciseId, $_SESSION['uid'], $exerciseLevel->suggestedLevel);
	}
	
	private function _addCreditsForUploading() {
		$sql = "UPDATE (users u JOIN preferences p)
				SET u.creditCount=u.creditCount+p.prefValue
				WHERE (u.ID=%d AND p.prefName='uploadExerciseCredits') ";
		return $this->_databaseUpdate ( $sql, $_SESSION['uid'] );
	}
	
	private function _addUploadingToCreditHistory($exerciseId){
		$sql = "SELECT prefValue FROM preferences WHERE ( prefName='uploadExerciseCredits' )";
		$result = $this->conn->_execute ( $sql );
		$row = $this->conn->_nextRow($result);
		if($row){
			$sql = "INSERT INTO credithistory (fk_user_id, fk_exercise_id, changeDate, changeType, changeAmount) ";
			$sql = $sql . "VALUES ('%d', '%d', NOW(), '%s', '%d') ";
			return $this->_create($sql, $_SESSION['uid'], $exerciseId, 'exercise_upload', $row[0]);
		} else {
			return false;
		}
	}

	private function _getUserInfo(){

		$sql = "SELECT name, creditCount, joiningDate, isAdmin FROM users WHERE (id = %d) ";

		return $this->_singleQuery($sql, $_SESSION['uid']);
	}

	private function _singleQuery(){
		$valueObject = new UserVO();
		$result = $this->conn->_execute(func_get_args());

		$row = $this->conn->_nextRow($result);
		if ($row)
		{
			$valueObject->name = $row[0];
			$valueObject->creditCount = $row[1];
			$valueObject->joiningDate = $row[2];
			$valueObject->isAdmin = $row[3]==1;
		}
		else
		{
			return false;
		}
		return $valueObject;
	}

	private function takeRandomSnapshot($videoFileName,$outputImageName){

		$videoPath  = $this->red5Path .'/'. $this->exerciseFolder .'/'. $videoFileName . '.flv';
		// where you'll save the image
		$imagePath  = $this->imagePath .'/'. $outputImageName . '.jpg';
		// default time to get the image
		$second = 1;

		// get the duration and a random place within that
		$resultduration = (exec("ffmpeg -i $videoPath 2>&1",$cmd));
		if (preg_match('/Duration: ((\d+):(\d+):(\d+))/s', implode($cmd), $time)) {
			$total = ($time[2] * 3600) + ($time[3] * 60) + $time[4];
			$second = rand(1, ($total - 1));
		}
		$resultsnap = (exec("ffmpeg -y -i $videoPath -r 1 -ss $second -vframes 1 -r 1 -s 120x90 $imagePath 2>&1",$cmd));
		return $resultsnap;
	}

	private function calculateVideoDuration($videoFileName){
		$videoPath  = $this->red5Path .'/'. $this->exerciseFolder .'/'. $videoFileName . '.flv';
		$total = 0;

		$resultduration = (exec("ffmpeg -i $videoPath 2>&1",$cmd));
		if (preg_match('/Duration: ((\d+):(\d+):(\d+))/s', implode($cmd), $time)) {
			$total = ($time[2] * 3600) + ($time[3] * 60) + $time[4];
		}
		return $total;
	}

	private function _getResourceDirectories(){
		$sql = "SELECT prefValue FROM preferences
				WHERE (prefName='exerciseFolder' OR prefName='responseFolder' OR prefName='evaluationFolder') 
				ORDER BY prefName";
		$result = $this->conn->_execute($sql);

		$row = $this->conn->_nextRow($result);
		$this->evaluationFolder = $row ? $row[0] : '';
		$row = $this->conn->_nextRow($result);
		$this->exerciseFolder = $row ? $row[0] : '';
		$row = $this->conn->_nextRow($result);
		$this->responseFolder = $row ? $row[0] : '';
	}

	public function getExercises(){
		$sql = "SELECT e.id, e.title, e.description, e.language, e.tags, e.source, e.name, e.thumbnail_uri,
       				   e.adding_date, e.duration, u.name, 
       				   avg (suggested_level) as avgLevel, e.status, license, reference
				FROM   exercise e INNER JOIN users u ON e.fk_user_id= u.ID
       				   LEFT OUTER JOIN exercise_score s ON e.id=s.fk_exercise_id
       				   LEFT OUTER JOIN exercise_level l ON e.id=l.fk_exercise_id
       			WHERE (e.status = 'Available')
				GROUP BY e.id
				ORDER BY e.adding_date DESC";

		$searchResults = $this->_exerciseListQuery($sql);

		return $searchResults;
	}
	
	public function getExercisesWithoutSubtitles(){
		try {
			$verifySession = new SessionHandler(true);
			
			$sql = "SELECT e.id, e.title, e.description, e.language, e.tags, e.source, e.name, e.thumbnail_uri,
       					   e.adding_date, e.duration, u.name, avg (suggested_level) as avgLevel, e.status, license, reference
					FROM exercise e 
					 	 INNER JOIN users u ON e.fk_user_id= u.ID
	 				 	 LEFT OUTER JOIN exercise_score s ON e.id=s.fk_exercise_id
       				 	 LEFT OUTER JOIN exercise_level l ON e.id=l.fk_exercise_id
       			 	 	 WHERE e.status = 'Available' AND 
					 	   	   e.id NOT IN (SELECT fk_exercise_id FROM subtitle) AND
					 	   	   e.language IN (SELECT language FROM user_languages WHERE fk_user_id= '%d' AND purpose = 'evaluate')
				 	GROUP BY e.id
				 	ORDER BY e.adding_date DESC";

			$searchResults = $this->_exerciseListQuery($sql, $_SESSION['uid']);

			return $searchResults;
		} catch (Exception $e){
			throw new Exception($e->getMessage());
		}
	}

	public function getRecordableExercises(){
		$sql = "SELECT e.id, e.title, e.description, e.language, e.tags, e.source, e.name, e.thumbnail_uri,
       					e.adding_date, e.duration, u.name, 
       					avg (suggested_level) as avgLevel, e.status, license, reference
				 FROM   exercise e 
				 		INNER JOIN users u ON e.fk_user_id= u.ID
				 		INNER JOIN subtitle t ON e.id=t.fk_exercise_id
       				    LEFT OUTER JOIN exercise_score s ON e.id=s.fk_exercise_id
       				    LEFT OUTER JOIN exercise_level l ON e.id=l.fk_exercise_id
       			 WHERE (e.status = 'Available')
				 GROUP BY e.id
				 ORDER BY e.adding_date DESC, e.language DESC";

		$searchResults = $this->_exerciseListQuery($sql);
		
		try {
			$verifySession = new SessionHandler(true);
			$filteredResults = $this->filterRecordableExercises($searchResults);
			return $filteredResults;
		} catch (Exception $e) {
			return $searchResults;
		}
		
	}
	
	private function filterRecordableExercises($exerciseList){
		$filteredList = array();
		foreach ($exerciseList as $exercise){
			foreach ($_SESSION['user-languages'] as $userLanguage) {
				if($userLanguage->purpose == 'practice'){
					if($exercise->language == $userLanguage->language && $exercise->avgDifficulty <= $userLanguage->level){
						array_push($filteredList, $exercise);
						break;
					}
				}
			}
		}
		return $filteredList;
	}

	public function getExerciseLocales($exerciseId) {
		$sql = "SELECT DISTINCT language FROM subtitle
				WHERE fk_exercise_id = %d";

		$searchResults = array ();
		$result = $this->conn->_execute ( $sql, $exerciseId );

		while ( $row = $this->conn->_nextRow ( $result ) )
		array_push($searchResults, $row[0]);

		return $searchResults; // return languages
	}

	public function addInappropriateExerciseReport($report){
		try {
			$verifySession = new SessionHandler(true);

			$result = $this->userReportedExercise($report);

			if (!$result){
				// The user is reporting an innapropriate exercise
				$sql = "INSERT INTO exercise_report (fk_exercise_id, fk_user_id, reason, report_date)
				    VALUES ('%d', '%d', '%s', NOW() )";

				return $this->_create($sql, $report->exerciseId, $_SESSION['uid'], $report->reason);

			} else {
				return 0;
			}
		} catch (Exception $e) {
			throw new Exception($e->getMessage());
		}
	}

	public function addExerciseScore($score){
		try {
			$verifySession = new SessionHandler(true);

			$result = $this->userRatedExercise($score);
			if (!$result){
				//The user can add a score

				$sql = "INSERT INTO exercise_score (fk_exercise_id, fk_user_id, suggested_score, suggestion_date)
			        VALUES ( '%d', '%d', '%d', NOW() )";

				$insert_result = $this->_create($sql, $score->exerciseId, $_SESSION['uid'], $score->suggestedScore);

				//return $this->getExerciseAvgScore($score->exerciseId);
				return $this->getExerciseAvgBayesianScore($score->exerciseId);

			} else {
				//The user has already given a score ignore the input.
				return 0;
			}
		} catch (Exception $e) {
			throw new Exception($e->getMessage());
		}
	}

	/**
	 * Check if the user has already rated this exercise today
	 * @param ExerciseScoreVO $score
	 * @throws Exception
	 */
	public function userRatedExercise($score){
		try {
			$verifySession = new SessionHandler(true);

			$sql = "SELECT *
		        FROM exercise_score 
		        WHERE ( fk_exercise_id='%d' AND fk_user_id='%d' AND CURDATE() <= suggestion_date )";
			$result = $this->conn->_execute ( $sql, $score->exerciseId, $_SESSION['uid']);
			$row = $this->conn->_nextRow ($result);
			if ($row){
				return true;
			} else {
				return false;
			}
		} catch (Exception $e) {
			throw new Exception($e->getMessage());
		}
	}

	/**
	 * Check if the user has already reported about this exercise
	 * @param ExerciseReportVO $report
	 */
	public function userReportedExercise($report){
		try {
			$verifySession = new SessionHandler(true);

			$sql = "SELECT *
				FROM exercise_report 
				WHERE ( fk_exercise_id='%d' AND fk_user_id='%d' )";
			$result = $this->conn->_execute ($sql, $report->exerciseId, $_SESSION['uid']);
			$row = $this->conn->_nextRow ($result);
			if ($row){
				return true;
			} else {
				return false;
			}
		} catch (Exception $e) {
			throw new Exception($e->getMessage());
		}
	}

	private function getExerciseAvgScore($exerciseId){

		$sql = "SELECT e.id, avg (suggested_score) as avgScore, count(suggested_score) as scoreCount
				FROM exercise e LEFT OUTER JOIN exercise_score s ON e.id=s.fk_exercise_id    
				WHERE (e.id = '%d' ) GROUP BY e.id";

		return $this->_singleScoreQuery($sql, $exerciseId);
	}

	/**
	 * The average score is not accurate information in statistical terms, so we use a weighted value
	 * @param int $exerciseId
	 */
	private function getExerciseAvgBayesianScore($exerciseId){

		if(!isset($this->exerciseMinRatingCount)){
			$sql = "SELECT prefValue FROM preferences WHERE (prefName = 'minVideoRatingCount')";

			$result = $this->conn->_execute($sql);
			$row = $this->conn->_nextRow($result);

			if($row)
			$this->exerciseMinRatingCount = $row[0];
			else
			$this->exerciseMinRatingCount = 0;
		}

		if(!isset($this->exerciseGlobalAvgRating)){
			$this->exerciseGlobalAvgRating = $this->getExercisesGlobalAvgScore();
		}

		$exerciseRatingData = $this->getExerciseAvgScore($exerciseId);

		$exerciseAvgRating = $exerciseRatingData->avgRating;
		$exerciseRatingCount = $exerciseRatingData->ratingCount;

		/* Avoid division by zero errors */
		if ($exerciseRatingCount == 0) $exerciseRatingCount = 1;

		$exerciseBayesianAvg = ($exerciseAvgRating*($exerciseRatingCount/($exerciseRatingCount + $this->exerciseMinRatingCount))) +
		($this->exerciseGlobalAvgRating*($this->exerciseMinRatingCount/($exerciseRatingCount + $this->exerciseMinRatingCount)));

		$exerciseRatingData->avgRating = $exerciseBayesianAvg;
		
		return $exerciseRatingData;

	}

	private function getExercisesGlobalAvgScore(){
		$sql = "SELECT avg(suggested_score) as globalAvgScore FROM exercise_score ";

		$result = $this->conn->_execute($sql);
		$row = $this->conn->_nextRow($result);
		if($row)
		return $row[0]; //The avg of all the exercises so far
		else
		return 0;
	}

	private function _singleScoreQuery(){
		$exercise = new ExerciseVO ( );
		$result = $this->conn->_execute(func_get_args());
		$row = $this->conn->_nextRow ($result);
		if ($row){
			$exercise->id = $row[0];
			$exercise->avgRating = $row[1];
			$exercise->ratingCount = $row[2];
		} else {
			return false;
		}
		return $exercise;

	}

	private function _exerciseListQuery() {
		$searchResults = array ();
		$result = $this->conn->_execute ( func_get_args() );

		while ( $row = $this->conn->_nextRow ( $result ) ) {
			$temp = new ExerciseVO ( );

			$temp->id = $row[0];
			$temp->title = $row[1];
			$temp->description = $row[2];
			$temp->language = $row[3];
			$temp->tags = $row[4];
			$temp->source = $row[5];
			$temp->name = $row[6];
			$temp->thumbnailUri = $row[7];
			$temp->addingDate = $row[8];
			$temp->duration = $row[9];
			$temp->userName = $row[10];
			$temp->avgDifficulty = $row[11];
			$temp->status = $row[12];
			$temp->license = $row[13];
			$temp->reference = $row[14];

			$temp->avgRating = $this->getExerciseAvgBayesianScore($temp->id);

			array_push ( $searchResults, $temp );
		}

		return $searchResults;
	}

	private function _create() {
		$this->conn->_execute ( func_get_args() );

		$sql = "SELECT last_insert_id()";
		$result = $this->_databaseUpdate ( $sql );

		$row = $this->conn->_nextRow ( $result );

		if ($row) {
			return $row [0];
		} else {
			return false;
		}
	}

	private function _databaseUpdate() {
		$result = $this->conn->_execute ( func_get_args() );

		return $result;
	}

}

?>