<?php

require_once 'utils/Config.php';
require_once 'utils/Datasource.php';
require_once 'utils/SessionHandler.php';

class UserHomepageDAO{

	private $conn;

	public function UserHomepageDAO(){
		try {
			$verifySession = new SessionHandler(true);
			$settings = new Config ( );
			$this->conn = new Datasource ( $settings->host, $settings->db_name, $settings->db_username, $settings->db_password );
		} catch (Exception $e) {
			throw new Exception($e->getMessage());
		}
	}

	public function usersLatestReceivedAssessments(){
		
	}

	public function detailsOfAssessedResponse($responseId){
		$sql = "SELECT C.name, A.score_overall, A.score_intonation, A.score_fluency, A.score_rhythm, A.score_spontaneity,
					   A.adding_date, A.comment, B.video_identifier 
			    FROM evaluation A 
			    	 INNER JOIN response D ON A.fk_response_id = D.id
			    	 INNER JOIN exercise E ON D.fk_exercise_id = E.id
			    	 INNER JOIN users C ON D.fk_user_id = C.id
			    	 LEFT OUTER JOIN exercise_level F ON E.id=F.fk_exercise_id
			    	 LEFT OUTER JOIN evaluation_video B ON A.id = B.fk_evaluation_id 
				WHERE (C.fk_user_id = '%d') ";

		$searchResults = $this->_listDetailsOfAssessedResponseQuery ( $sql, $_SESSION['uid'] );

		return $searchResults;
	}

	private function _listDetailsOfAssessedResponseQuery(){
		$searchResults = array();
		$result = $this->conn->_execute(func_get_args());

		while ($row = $this->conn->_nextRow($result)){
			$temp = new EvaluationVO();

			$temp->userName = $row[0];
			$temp->overallScore = $row[1];
			$temp->intonationScore = $row[2];
			$temp->fluencyScore = $row[3];
			$temp->rhythmScore = $row[4];
			$temp->spontaneityScore = $row[5];
			$temp->addingDate = $row[6];
			$temp->comment = $row[7];
			$temp->evaluationVideoFileIdentifier = $row[8];

			array_push ( $searchResults, $temp );
		}

		return $searchResults;
	}

	public function usersLatestGivenAssessments(){
		
		$secondsInAWeek = 604800;
		$results = array();
		
		//List of all the assessments done by the user
		$evaluation = new EvaluationDAO();
		$givenAssessments = $evaluation->getResponsesAssessedByCurrentUser();
		
		$currentTime = time();
		
		//Filter the results and show only the assessments done in the last weeek
		foreach($givenAssessments as $givenAssessment){
			$evalTime = strtotime($givenAssessment->addingDate);
			if ($evalTime <= $currentTime && ($currentTime - $evalTime) < $secondsInAWeek){
				array_push($results, $givenAssessment);
			}
		}
		return $results;
	}

	public function usersLatestUploadedVideos(){

	}

	public function topScoreMostViewedVideos(){

	}

	public function latestAvailableVideos(){

	}


}