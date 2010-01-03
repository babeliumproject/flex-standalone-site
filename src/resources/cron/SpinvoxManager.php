<?php

                                            
require_once ("../Config.php");
require_once ("../Datasource.php");

require_once './SpinvoxConnection.php';

class SpinvoxManager {
	
	const system = "spinvox";
	
	const STATUS_PENDING = "pending";
	const STATUS_REQUEST_ERROR = "request_error";
	const STATUS_PROCESSING = "processing";
	
	private $dbLink;
	private $spinvoxPrefs;
	private $ffmpegPath;
	
	//The maximun number of transcriptions that will be retrieved in each time
	private $maxTranscriptions = 10;
	//The maximun number of requests that will be sent in each time
	private $maxRequests = 50;
	//The path where the videos are located
	private $videoPath;
	
	private $spinvoxConnection;
	
	/**
	 * Constructor
	 *
	 * @param $devmode[optional] True if you want to use the SpinVox development url else false.
	 */
	function __construct() {
		$settings = new Config();
		$this->conn = new DataSource($settings->host, $settings->db_name, $settings->db_username, $settings->db_password);
		
		//$this->conn = new Datasource("localhost", "babelia", "babelia", "babelia");
		

		$this->spinvoxPrefs = $this->loadConfiguration(SpinvoxManager::system);
		$ffmpegPrefs = $this->loadConfiguration("ffmpeg");
		$this->ffmpegPath = $ffmpegPrefs["path"];
		$this->videoPath = $this->spinvoxPrefs['video_path'];
		$this->maxTranscriptions = $this->spinvoxPrefs['max_transcriptions'];
		$this->maxRequests = $this->spinvoxPrefs['max_requests'];
		
		if ($this->spinvoxPrefs['dev_mode'])
			$url = $this->spinvoxPrefs['protocol'] . '://' . $this->spinvoxPrefs['dev_url'] . ':' . $this->spinvoxPrefs['port'];
		else
			$url = $this->spinvoxPrefs['protocol'] . '://' . $this->spinvoxPrefs['live_url'] . ':' . $this->spinvoxPrefs['port'];
			
		$this->spinvoxConnection = new SpinvoxConnection($url, $this->spinvoxPrefs['username'], $this->spinvoxPrefs['password'], $this->spinvoxPrefs['appname'], $this->spinvoxPrefs['account_id'], $this->spinvoxPrefs['useragent'], $this->ffmpegPath, $this->spinvoxPrefs['temp_folder']);
	}
	
	private function loadConfiguration($system) {
		$sql = "SELECT * FROM preferences WHERE prefName LIKE '" . $system . ".%'";
		$result = $this->conn->_execute($sql);
		
		$prefs = array();
		
		while ( $row = $this->conn->_nextRow($result) ) {
			$prefName = split('[.]', $row[1]);
			$prefs[$prefName[1]] = $row[2];
		}
		
		return $prefs;
	}
	
	/**
	 * Sends all the conversion requests to SpinVox. It looks for pending exercises and responses, and requests that must be sent again and sends a transcription request to SpinVox for each of them.
	 *
	 */
	public function sendRequests() {
		$slots = $this->maxRequests;
		
		$pendingResponses = $this->getPendingRequestsResponses($slots);
		$this->sendRequestsToSpinvox($pendingResponses);
		
		echo "Pending Responses:" . count($pendingResponses) . "<br>";
		
		$slots = $slots - count($pendingResponses);
		if ($slots <= 0)
			return;
		
		$pendingExercises = $this->getPendingRequestsExercises($slots);
		$this->sendRequestsToSpinvox($pendingExercises);
		
		echo "Pending Exercises:" . count($pendingExercises) . "<br>";
		
		$slots = $slots - count($pendingExercises);
		if ($slots <= 0)
			return;
		
		$repeatRequests = $this->getRequestsResponsesToRepeat($slots);
		$this->sendRequestsToSpinvox($repeatRequests);
		
		echo "Repeat Requests:" . count($repeatRequests) . "<br>";
		
		$slots = $slots - count($repeatRequests);
		if ($slots <= 0)
			return;
		
		$repeatExercises = $this->getRequestsExercisesToRepeat($slots);
		$this->sendRequestsToSpinvox($repeatExercises);
		
		echo "Repeat Exercises:" . count($repeatExercises) . "<br>";
	}
	
	/**
	 * Retrieves from SpinVox all the transcription that are completed.
	 *
	 */
	public function retrieveTranscriptions() {
		$pendingTrans = $this->getProcessingTranscritions($this->maxTranscriptions);
		$this->getTranscriptionsFromSpinvox($pendingTrans);
	}
	
	private function sendRequestsToSpinvox($list) {
		foreach ( $list as $i => $values ) {
			$response = $this->spinvoxConnection->transcript($this->videoPath . "/" . $values["name"] . ".flv", $values["id"] . "_" . date("ymd_His"));
			if ($response) {
				$errorCode = $response["error_code"];
				$this->insertSpinvoxRequest($response["x_error"], $response["location"], $response["date"], $values["id"]);
				if ($errorCode == 202)
					$this->updateTranscriptionStatus($values["id"], SpinvoxManager::STATUS_PROCESSING);
				else
					$this->updateTranscriptionStatus($values["id"], SpinvoxManager::STATUS_REQUEST_ERROR);
			}
		}
	}
	
	private function getTranscriptionsFromSpinvox($list) {
		foreach ( $list as $i => $values ) {
			$transcription = $this->spinvoxConnection->getTranscription($values["url"]);
			if ($transcription) {
				if ($transcription["status"] == "Converted")
					$this->saveTranscription($values["id"], $transcription["status"], $transcription["text"]);
				else
					$this->updateTranscriptionStatus($values["id"], $transcription["status"]);
			}
		}
	}
	
	private function getPendingRequestsExercises($limit) {
		$sql = "SELECT T.id, E.name, E.language FROM transcription AS T INNER JOIN exercise AS E ON T.id=E.fk_transcription_id INNER JOIN preferences AS P ON E.language = P.prefValue WHERE T.status = '" . SpinvoxManager::STATUS_PENDING . "' AND P.prefName = 'spinvox.language' ORDER BY T.adding_date ASC LIMIT $limit";
		$result = $this->conn->_execute($sql);
		
		$list = array();
		
		while ( $row = $this->conn->_nextRow($result) )
			$list[] = array("id" => $row[0], "name" => $row[1], "language" => $row[2]);
		
		return $list;
	}
	
	private function getPendingRequestsResponses($limit) {
		$sql = "SELECT T.id, R.file_identifier, E.language FROM transcription AS T INNER JOIN response AS R ON T.id=R.fk_transcription_id INNER JOIN exercise AS E ON R.fk_exercise_id=E.id INNER JOIN preferences AS P ON E.language = P.prefValue WHERE T.status = '" . SpinvoxManager::STATUS_PENDING . "' AND P.prefName = 'spinvox.language' ORDER BY T.adding_date ASC LIMIT $limit";
		$result = $this->conn->_execute($sql);
		
		$list = array();
		
		while ( $row = $this->conn->_nextRow($result) )
			$list[] = array("id" => $row[0], "name" => $row[1], "language" => $row[2]);
		
		return $list;
	}
	
	private function getRequestsExercisesToRepeat($limit) {
		$sql = "SELECT S.fk_transcription_id AS id, E.name, E.language FROM spinvox_request AS S NATURAL JOIN exercise AS E WHERE S.x_error >= 500 AND S.x_error < 600 AND S.date <= DATE_SUB(NOW(),INTERVAL 30 MINUTE) ORDER BY date ASC LIMIT $limit";
		$result = $this->conn->_execute($sql);
		
		$list = array();
		
		while ( $row = $this->conn->_nextRow($result) )
			$list[] = array("id" => $row[0], "name" => $row[1], "language" => $row[2]);
		
		return $list;
	}
	
	private function getRequestsResponsesToRepeat($limit) {
		$sql = "SELECT S.fk_transcription_id AS id, R.file_identifier, E.language FROM spinvox_request AS S NATURAL JOIN response AS R INNER JOIN exercise AS E ON R.fk_exercise_id=E.id WHERE S.x_error >= 500 AND S.x_error < 600 AND S.date <= DATE_SUB(NOW(),INTERVAL 30 MINUTE) ORDER BY date ASC LIMIT $limit";
		$result = $this->conn->_execute($sql);
		
		$list = array();
		
		while ( $row = $this->conn->_nextRow($result) )
			$list[] = array("id" => $row[0], "name" => $row[1], "language" => $row[2]);
		
		return $list;
	}
	
	private function getProcessingTranscritions($limit) {
		$sql = "SELECT T.id, url FROM spinvox_request AS S INNER JOIN transcription AS T ON S.fk_transcription_id=T.id WHERE T.status='" . SpinvoxManager::STATUS_PROCESSING . "' ORDER BY S.date ASC LIMIT $limit";
		$result = $this->conn->_execute($sql);
		
		$list = array();
		
		while ( $row = $this->conn->_nextRow($result) )
			$list[] = array("id" => $row[0], "url" => $row[1]);
		
		return $list;
	}
	
	private function insertSpinvoxRequest($xerror, $url, $date, $ref) {
		$delete = "DELETE FROM spinvox_request WHERE fk_transcription_id = $ref";
		$result = $this->conn->_execute($delete);
		
		$update = "INSERT INTO spinvox_request (x_error, url, date, fk_transcription_id) VALUES ('$xerror','$url','$date','$ref')";
		$result = $this->conn->_execute($update);
		
		return $result;
	}
	
	private function saveTranscription($id, $status, $text) {
		$update = "UPDATE transcription SET status='$status', transcription='$text', transcription_date=NOW() WHERE id=$id";
		$result = $this->conn->_execute($update);
		return $result;
	}
	
	private function updateTranscriptionStatus($transId, $status) {
		$update = "UPDATE transcription SET status='$status' WHERE id=$transId";
		$result = $this->conn->_execute($update);
		return $result;
	}
}
?>