<?php

require_once 'Datasource.php';
require_once 'Config.php';
require_once 'UserVideoHistoryVO.php';

class UserVideoHistoryDAO{

	private $conn;

	public function UserVideoHistoryDAO(){
		$settings = new Config ( );
		$this->conn = new Datasource ( $settings->host, $settings->db_name, $settings->db_username, $settings->db_password );
	}

	public function exerciseWatched($videoHistoryData){

		if($sessionId = $this->_currentSessionData($videoHistoryData->userId)){

			$sql = "INSERT INTO user_videohistory (fk_user_id, fk_user_session_id, fk_exercise_id, subtitles_are_used, fk_subtitle_id) 
			    	VALUES ('%d','%d','%d','%d','%d')";
			return $this->_create($sql, $videoHistoryData->userId, $sessionId, $videoHistoryData->exerciseId, $videoHistoryData->subtitlesAreUsed, $videoHistoryData->subtitleId);
		} else {
			return false;
		}
	}
	
	public function exerciseAttemptResponse($videoHistoryData){
		if($sessionId = $this->_currentSessionData($videoHistoryData->userId)){
			$sql = "INSERT INTO user_videohistory (fk_user_id, fk_user_session_id, fk_exercise_id, response_attempt, subtitles_are_used, fk_subtitle_id, fk_exercise_role_id) 
					VALUES ('%d', '%d', '%d', 1, '%d', '%d', '%d')";
			return $this->_create($sql, $videoHistoryData->userId, $sessionId, $videoHistoryData->exerciseId, 
								  $videoHistoryData->subtitlesAreUsed, $videoHistoryData->subtitleId, $videoHistoryData->exerciseRoleId);
		} else {
			return false;
		}
	}
	
	public function exerciseSaveResponse($videoHistoryData){
		if($sessionId = $this->_currentSessionData($videoHistoryData->userId)){
			$sql = "INSERT INTO user_videohistory (fk_user_id, fk_user_session_id, fk_exercise_id, fk_response_id, subtitles_are_used, fk_subtitle_id, fk_exercise_role_id) 
					VALUES ('%d', '%d', '%d', '%d', '%d', '%d', '%d')";
			return $this->_create($sql, $videoHistoryData->userId, $sessionId, $videoHistoryData->exerciseId, $videoHistoryData->responseId, 
								  $videoHistoryData->subtitlesAreUsed, $videoHistoryData->subtitleId, $videoHistoryData->exerciseRoleId);
		} else {
			return false;
		}
	}

	private function _currentSessionData($userId){
		//Initialize session
		session_start();
		$sessionId = session_id();

		$sql = "SELECT id, session_id FROM user_session WHERE ( session_id = '%s' AND fk_user_id = '%d' AND closed = 0 )";
		$result = $this->conn->_execute ( $sql, $sessionId, $userId );
		$row = $this->conn->_nextRow($result);
		if($row){
			return $row[0];
		} else {
			return false;
		}
	}



	private function _create() {

		$this->conn->_execute ( func_get_args() );

		$sql = "SELECT last_insert_id()";
		$result = $this->conn->_execute ( $sql );

		$row = $this->conn->_nextRow ( $result );
		if ($row) {
			return $row [0];
		} else {
			return false;
		}
	}
}

?>
