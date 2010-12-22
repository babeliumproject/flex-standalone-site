<?php

require_once 'utils/Config.php';
require_once 'utils/Datasource.php';
require_once 'utils/SessionHandler.php';

require_once 'vo/MotdVO.php';

require_once 'EvaluationDAO.php';

class HomepageDAO{

	private $conn;

	public function HomepageDAO(){
		try {
			$verifySession = new SessionHandler();
			$settings = new Config ();
			$this->conn = new Datasource ( $settings->host, $settings->db_name, $settings->db_username, $settings->db_password );
		} catch (Exception $e) {
			throw new Exception($e->getMessage());
		}

	}

	public function unsignedMessagesOfTheDay($messageLocale){

		$sql = "SELECT title, message, code, language, resource FROM motd WHERE ( CURDATE() >= displayDate AND language='%s' AND displaywhenloggedin = false ) ";

		$searchResults = $this->_listMessagesOfTheDayQuery($sql, $messageLocale);

		return $searchResults;

	}

	public function signedMessagesOfTheDay($messageLocale){

		$sql = "SELECT title, message, code, language, resource FROM motd WHERE ( CURDATE() >= displayDate AND language='%s' AND displaywhenloggedin = true ) ";

		$searchResults = $this->_listMessagesOfTheDayQuery($sql, $messageLocale);

		return $searchResults;

	}

	private function _listMessagesOfTheDayQuery($query){

		$searchResults = array();
		$result = $this->conn->_execute ( func_get_args() );

		while ( $row = $this->conn->_nextRow($result)){
			$temp = new MotdVO();
			$temp->title = $row[0];
			$temp->message = $row[1];
			$temp->code = $row[2];
			$temp->language = $row[3];
			$temp->resourceUrl = $row[4];

			array_push ( $searchResults, $temp );
		}

		return $searchResults;
	}


	public function usersLatestReceivedAssessments(){
		$sql = "SELECT 
			    FROM evaluation A 
			    	 INNER JOIN response D ON A.fk_response_id = D.id
			    	 INNER JOIN exercise E ON D.fk_exercise_id = E.id
			    	 INNER JOIN users C ON D.fk_user_id = C.id
			    	 LEFT OUTER JOIN exercise_level F ON E.id=F.fk_exercise_id
			    	 LEFT OUTER JOIN evaluation_video B ON A.id = B.fk_evaluation_id 
				WHERE (C.fk_user_id = '%d') ";

		$searchResults = $this->_listAssessedResponsesQuery ( $sql, $_SESSION['uid'] );

		return $searchResults;
	}

	private function _listAssessedResponsesQuery(){
		$searchResults = array();
		$result = $this->conn->_execute(func_get_args());

		while ($row = $this->conn->_nextRow($result)){
			$temp = new EvaluationVO();

			array_push ( $searchResults, $temp );
		}

		return $searchResults;
	}

	public function usersLatestGivenAssessments(){

		$results = array();

		//List of all the assessments done by the user
		$evaluation = new EvaluationDAO();
		$givenAssessments = $evaluation->getResponsesAssessedByCurrentUser();

		/*
		 $secondsInAWeek = 604800;
		 $currentTime = time();

		 //Filter the results and show only the assessments done in the last weeek
		 foreach($givenAssessments as $givenAssessment){
			$evalTime = strtotime($givenAssessment->addingDate);
			if ($evalTime <= $currentTime && ($currentTime - $evalTime) < $secondsInAWeek)
				array_push($results, $givenAssessment);
			
		}
		*/

		if( count($givenAssessments) > 5 )
		$results = array_slice($givenAssessments, 0, 5);
		else
		$results = $givenAssessments;

		return $results;
	}

	public function usersLatestUploadedVideos(){

	}

	public function topScoreMostViewedVideos(){

	}

	public function latestAvailableVideos(){

	}


}
