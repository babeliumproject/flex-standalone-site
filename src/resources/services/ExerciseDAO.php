<?php

require_once 'utils/Datasource.php';
require_once 'utils/Config.php';
require_once 'vo/ExerciseVO.php';
require_once 'vo/ExerciseReportVO.php';
require_once 'vo/ExerciseScoreVO.php';
require_once 'vo/ExerciseLevelVO.php';

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
			$settings = new Config ( );
			$this->filePath = $settings->filePath;
			$this->imagePath = $settings->imagePath;
			$this->red5Path = $settings->red5Path;
			$this->conn = new Datasource ( $settings->host, $settings->db_name, $settings->db_username, $settings->db_password );
	}
	
	public function addExercise(ExerciseVO $local, ExerciseVO $youtube) {
		$this->deleteLocalVideoCopy ( $local->name );
		
		$sql = "INSERT INTO exercise (name, title, description, tags, language, source, fk_user_id, thumbnail_uri, adding_date, duration) ";
		$sql = $sql . "VALUES ('%s', '%s', '%s', '%s', '%s', '%s', '%d', '%s', now(), 0 ) ";
		
		return $this->_create ( $sql, $youtube->name, $local->title, $local->description, $local->tags,
									$local->language, $local->source, $local->userId, $youtube->thumbnailUri );
	
	}
	
	public function addUnprocessedExercise(ExerciseVO $exercise) {
		
		$exerciseLevel = new ExerciseLevelVO();
		$exerciseLevel->userId = $exercise->userId;
		$exerciseLevel->suggestedLevel = $exercise->avgDifficulty;
		
		$sql = "INSERT INTO exercise (name, title, description, tags, language, source, fk_user_id, adding_date, duration, license, reference) ";
		$sql .= "VALUES ('%s', '%s', '%s', '%s', '%s', 'Red5', '%d', now(), '%d', '%s', '%s') ";
		
		$lastExerciseId = $this->_create( $sql, $exercise->name, $exercise->title, $exercise->description, $exercise->tags,
										  $exercise->language, $exercise->userId, $exercise->duration, $exercise->license, $exercise->reference );
		if($lastExerciseId){
			$exerciseLevel->exerciseId = $lastExerciseId;
			if($this->addExerciseLevel($exerciseLevel))
				return $lastExerciseId;
		}
	}
	
	public function addWebcamExercise(ExerciseVO $exercise) {
		set_time_limit(0);
		$this->_getResourceDirectories();
		
		$duration = $this->calculateVideoDuration($exercise->name);
		$this->takeRandomSnapshot($exercise->name, $exercise->name);
		
		$exerciseLevel = new ExerciseLevelVO();
		$exerciseLevel->userId = $exercise->userId;
		$exerciseLevel->suggestedLevel = $exercise->avgDifficulty;
		
		$sql = "INSERT INTO exercise (name, title, description, tags, language, source, fk_user_id, adding_date, status, thumbnail_uri, duration, license, reference) ";
		$sql .= "VALUES ('%s', '%s', '%s', '%s', '%s', 'Red5', '%d', now(), 'Available', '%s', '%d', '%s', '%s') ";
		
		$lastExerciseId = $this->_create( $sql, $exercise->name, $exercise->title, $exercise->description, $exercise->tags,
								          $exercise->language, $exercise->userId, $exercise->name.'.jpg', $duration, $exercise->license, $exercise->reference );
		if($lastExerciseId){
			$exerciseLevel->exerciseId = $lastExerciseId;
			if($this->addExerciseLevel($exerciseLevel))
				return $lastExerciseId;
		}
	}
	
	public function addExerciseLevel(ExerciseLevelVO $exerciseLevel){
		$sql = "INSERT INTO exercise_level (fk_exercise_id, fk_user_id, suggested_level, suggest_date) 
						 VALUES ('%d', '%d', '%d', NOW()) ";
		return $this->_create($sql, $exerciseLevel->exerciseId, $exerciseLevel->userId, $exerciseLevel->suggestedLevel);
	}
	
	public function takeRandomSnapshot($videoFileName,$outputImageName){
	
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
       				   e.adding_date, e.fk_user_id, e.duration, u.name, 
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
	
	/**
	 * Returns an array of ExerciseVO. The returned exercises are those that have already been subtitled and are
	 * ready to be used on a recording workflow.
	 */
	public function getRecordableExercises(){
		$sql = "SELECT e.id, e.title, e.description, e.language, e.tags, e.source, e.name, e.thumbnail_uri,
       					e.adding_date, e.fk_user_id, e.duration, u.name, 
       					avg (suggested_level) as avgLevel, e.status, license, reference
				 FROM   exercise e 
				 		INNER JOIN users u ON e.fk_user_id= u.ID
				 		INNER JOIN subtitle t ON e.id=t.fk_exercise_id
       				    LEFT OUTER JOIN exercise_score s ON e.id=s.fk_exercise_id
       				    LEFT OUTER JOIN exercise_level l ON e.id=l.fk_exercise_id
       			 WHERE (e.status = 'Available')
				 GROUP BY e.id
				 ORDER BY e.adding_date DESC";
		
		$searchResults = $this->_exerciseListQuery($sql);
		
		return $searchResults;
	}
	
	/**
	 * Returns an array of ExerciseVO based on $userId user's language preferences. Thus, it will only return
	 * recordable exercises that are on a language he/she wants to learn.
	 * @param int $userId
	 */
	public function getUserRecordableExercises($userId){
		$sql = "SELECT e.id, e.title, e.description, e.language, e.tags, e.source, e.name, e.thumbnail_uri,
       					e.adding_date, e.fk_user_id, e.duration, u.name, 
       					avg (suggested_level) as avgLevel, e.status, license, reference
				 FROM   exercise e 
				 		INNER JOIN users u ON e.fk_user_id= u.ID
				 		INNER JOIN subtitle t ON e.id=t.fk_exercise_id
       				    LEFT OUTER JOIN exercise_score s ON e.id=s.fk_exercise_id
       				    LEFT OUTER JOIN exercise_level l ON e.id=l.fk_exercise_id
       			 WHERE (e.status = 'Available' AND e.language IN (SELECT language FROM user_languages WHERE fk_user_id= '%d' AND level < 7))
				 GROUP BY e.id
				 ORDER BY e.adding_date DESC";
		
		$searchResults = $this->_exerciseListQuery($sql);
		
		return $searchResults;
	}
	
	/**
	 * Returns an array of ExerciseVO. These exercises are the ones that the $userId has uploaded.
	 * @param int $userId
	 */
	public function getUserContributedExercises($userId){
		$sql = "SELECT e.id, e.title, e.description, e.language, e.tags, e.source, e.name, e.thumbnail_uri,
       					e.adding_date, e.fk_user_id, e.duration, u.name, 
       					avg (suggested_level) as avgLevel, e.status, license, reference
				 FROM   exercise e INNER JOIN users u ON e.fk_user_id= u.ID
       				    LEFT OUTER JOIN exercise_score s ON e.id=s.fk_exercise_id
       				    LEFT OUTER JOIN exercise_level l ON e.id=l.fk_exercise_id
				 WHERE (e.fk_user_id = '%d' ) 
       			 GROUP BY e.id
				 ORDER BY e.adding_date DESC";
		
		
		$searchResults = $this->_listQuery($sql, $userId);
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
	
	public function addInappropriateExerciseReport(ExerciseReportVO $report){
		$result = $this->userReportedExercise($report);
		
		if (!$result){
			// The user is reporting an innapropriate exercise
			$sql = "INSERT INTO exercise_report (fk_exercise_id, fk_user_id, reason, report_date) 
				    VALUES ('%d', '%d', '%s', NOW() )";
			
			return $this->_create($sql, $report->exerciseId, $report->userId, $report->reason);
			
		} else {
			return 0;
		}
	}
	
	public function addExerciseScore(ExerciseScoreVO $score){
		
		$result = $this->userRatedExercise($score);
		if (!$result){
			//The user can add a score
			
			$sql = "INSERT INTO exercise_score (fk_exercise_id, fk_user_id, suggested_score, suggestion_date) 
			        VALUES ( '%d', '%d', '%d', NOW() )";
			
			$insert_result = $this->_create($sql, $score->exerciseId, $score->userId, $score->suggestedScore);
			
			//return $this->getExerciseAvgScore($score->exerciseId);
			return $this->getExerciseAvgBayesianScore($score->exerciseId);
			
		} else {
			//The user has already given a score ignore the input.
			return 0;
		}	
	}
	
	public function userRatedExercise(ExerciseScoreVO $score){
		$sql = "SELECT * 
		        FROM exercise_score 
		        WHERE ( fk_exercise_id='%d' AND fk_user_id='%d' AND CURDATE() <= suggestion_date )";
		$result = $this->conn->_execute ( $sql, $score->exerciseId, $score->userId);
		$row = $this->conn->_nextRow ($result);
		if ($row){
			return true;
		} else {
			return false;
		}
	}
	
	public function userReportedExercise(ExerciseReportVO $report){
		//Check if the user has already reported about this exercise
		$sql = "SELECT * 
				FROM exercise_report 
				WHERE ( fk_exercise_id='%d' AND fk_user_id='%d' )";
		$result = $this->conn->_execute ($sql, $report->exerciseId, $report->userId);
		$row = $this->conn->_nextRow ($result);
		if ($row){
			return true;
		} else {
			return false;
		}
	}
	
	public function getExerciseAvgScore($exerciseId){
		
		$sql = "SELECT e.id, avg (suggested_score) as avgScore, count(suggested_score) as scoreCount 
				FROM exercise e LEFT OUTER JOIN exercise_score s ON e.id=s.fk_exercise_id    
				WHERE (e.id = '%d' )";
		
		return $this->_singleScoreQuery($sql, $exerciseId);
	}
	
	public function getExerciseAvgBayesianScore($exerciseId){
		
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
		
		$exerciseBayesianAvg = ($exerciseAvgRating*($exerciseRatingCount/($exerciseRatingCount + $this->exerciseMinRatingCount))) + 
							   ($this->exerciseGlobalAvgRating*($this->exerciseMinRatingCount/($exerciseRatingCount + $this->exerciseMinRatingCount)));
							   
		return $exerciseBayesianAvg;
		
	}
	
	public function getExercisesGlobalAvgScore(){
		$sql = "SELECT avg(suggested_score) as globalAvgScore FROM exercise_score ";
		
		$result = $this->conn->_execute($sql);
		$row = $this->conn->_nextRow($result);
		if($row)
			return $row[0]; //The avg of all the exercises so far
		else
			return 0;
	}
	
	public function deactivateReportedVideos(){
		
		$sql = "SELECT prefValue FROM preferences WHERE (prefName='reports_to_delete')";
		$result = $this->conn->_execute($sql);
		$row = $this->conn->_nextRow ($result);
		if ($row){
			
			$reportsToDeletion = $row[0];
			
			$sql = "UPDATE exercise AS E SET status='Unavailable' 
		       	    WHERE '%d' <= (SELECT count(*) 
		        		          FROM exercise_report WHERE fk_exercise_id=E.id ) ";
			return $this->_databaseUpdate($sql, $reportsToDeletion);
		}
	}
	
	private function deleteLocalVideoCopy($fileName) {
		$path = $this->filePath . "/" . $fileName;
		$success = @unlink ( $path );
		return $success;
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
			$temp->userId = $row[9];
			$temp->duration = $row[10];
			$temp->userName = $row[11];
			$temp->avgDifficulty = $row[12];
			$temp->status = $row[13];
			$temp->license = $row[14];
			$temp->reference = $row[15];
			
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