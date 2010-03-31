<?php

require_once ("../Config.php");
require_once ("../Datasource.php");

require_once './SpinvoxConnection.php';

class SpinvoxManager {
	
	const system = "spinvox";
	
	const STATUS_PENDING = "pending";
	const STATUS_CONVERTED = "converted";
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

		$this->spinvoxPrefs = $this->loadConfiguration(SpinvoxManager::system);
		$ffmpegPrefs = $this->loadConfiguration("ffmpeg");
		$this->ffmpegPath = $ffmpegPrefs["path"];
		$this->videoPath = $this->spinvoxPrefs['video_path'];
		$this->maxTranscriptions = $this->spinvoxPrefs['max_transcriptions'];
		$this->maxRequests = $this->spinvoxPrefs['max_requests'];
		
		if ($this->spinvoxPrefs['dev_mode']){
			echo "Conversion in DEV mode<br>";
			$url = $this->spinvoxPrefs['protocol'] . '://' . $this->spinvoxPrefs['dev_url'] . ':' . $this->spinvoxPrefs['port'];
		} else{
			echo "Conversion in LIVE mode<br>";
			$url = $this->spinvoxPrefs['protocol'] . '://' . $this->spinvoxPrefs['live_url'] . ':' . $this->spinvoxPrefs['port'];
		}
		
		$this->spinvoxConnection = new SpinvoxConnection($url, $this->spinvoxPrefs['username'], $this->spinvoxPrefs['password'], $this->spinvoxPrefs['appname'], $this->spinvoxPrefs['account_id'], $this->spinvoxPrefs['useragent'], $this->ffmpegPath, $this->spinvoxPrefs['temp_folder']);
	}
	
	private function loadConfiguration($system) {
		$sql = "SELECT * FROM preferences WHERE prefName LIKE '%s.%%'";
		$result = $this->conn->_execute($sql, $system);
		
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
	public function sendTranscriptionRequests() {
		$slots = $this->maxRequests;
		
		echo "Slots: " . $slots . " <br>";
		echo "Starting...<br>";
		
		if ($slots <= 0)
			return;
		
		//Pending Responses
		$sql = "SELECT T.id, R.file_identifier, E.language FROM transcription AS T INNER JOIN response AS R ON T.id=R.fk_transcription_id INNER JOIN exercise AS E ON R.fk_exercise_id=E.id INNER JOIN preferences AS P ON E.language = P.prefValue WHERE T.status = '" . SpinvoxManager::STATUS_PENDING . "' AND P.prefName = 'spinvox.language' ORDER BY T.adding_date ASC LIMIT %d";
		$pendingResponses = $this->sendRequests($sql, $slots);
		//$this->sendRequestsToSpinvox($pendingResponses);
		

		echo "Pending Responses:" . $pendingResponses . " ; Remaining slots: " . $slots . "<br>";
		
		$slots = $slots - $pendingResponses;
		if ($slots <= 0)
			return;
			
		//Pending Exercises
		$sql = "SELECT T.id, E.name, E.language FROM transcription AS T INNER JOIN exercise AS E ON T.id=E.fk_transcription_id INNER JOIN preferences AS P ON E.language = P.prefValue WHERE T.status = '" . SpinvoxManager::STATUS_PENDING . "' AND P.prefName = 'spinvox.language' ORDER BY T.adding_date ASC LIMIT %d";
		$pendingExercises = $this->sendRequests($sql, $slots);
		//$this->sendRequestsToSpinvox($pendingExercises);
		

		echo "Pending Exercises:" . $pendingExercises . " ; Remaining slots: " . $slots . "<br>";
		
		$slots = $slots - $pendingExercises;
		if ($slots <= 0)
			return;
			
		//Repeat Responses
		$sql = "SELECT S.fk_transcription_id AS id, R.file_identifier, E.language FROM spinvox_request AS S NATURAL JOIN response AS R INNER JOIN exercise AS E ON R.fk_exercise_id=E.id WHERE S.x_error >= 500 AND S.x_error < 600 AND S.date <= DATE_SUB(NOW(),INTERVAL 30 MINUTE) ORDER BY date ASC LIMIT %d";
		$repeatResponses = $this->sendRequests($sql, $slots);
		//$this->sendRequestsToSpinvox($repeatResponses);
		

		echo "Repeat Responses:" . $repeatResponses . " ; Remaining slots: " . $slots . "<br>";
		
		$slots = $slots - $repeatResponses;
		if ($slots <= 0)
			return;
			
		//Repeat Exercises
		$sql = "SELECT S.fk_transcription_id AS id, R.file_identifier, E.language FROM spinvox_request AS S NATURAL JOIN response AS R INNER JOIN exercise AS E ON R.fk_exercise_id=E.id WHERE S.x_error >= 500 AND S.x_error < 600 AND S.date <= DATE_SUB(NOW(),INTERVAL 30 MINUTE) ORDER BY date ASC LIMIT %d";
		$repeatExercises = $this->sendRequests($sql, $slots);
		//$this->sendRequestsToSpinvox($repeatExercises);
		

		echo "Repeat Exercises:" . $repeatExercises . " ; Remaining slots: " . $slots . "<br>";
		
		echo "Finished";
	}
	
	/**
	 * Retrieves from SpinVox all the transcription that are completed.
	 *
	 */
	public function retrieveTranscriptions() {
		//Transcriptions with PROCESSING status
		$sql = "SELECT T.id, url FROM spinvox_request AS S INNER JOIN transcription AS T ON S.fk_transcription_id=T.id WHERE T.status='" . SpinvoxManager::STATUS_PROCESSING . "' ORDER BY S.date ASC LIMIT %d";
		$pendingTrans = $this->getTranscritions($sql, $this->maxTranscriptions);
		echo "Transcriptions retrieved:" . $pendingTrans . "<br>";
	}
	
	private function sendRequestsToSpinvox($id, $name, $language) {
		$language = "";
		
		$response = $this->spinvoxConnection->transcript($this->videoPath . "/" . $name . ".flv", $id . "_" . date("ymd_His"), $language);
		if ($response) {
			$errorCode = $response["error_code"];
			$this->insertSpinvoxRequest($response["x_error"], $response["location"], $response["date"], $id);
			if ($errorCode == 202)
				$this->updateTranscriptionStatus($id, SpinvoxManager::STATUS_PROCESSING);
			else
				$this->updateTranscriptionStatus($id, SpinvoxManager::STATUS_REQUEST_ERROR);
		}
	}
	
	private function getTranscriptionsFromSpinvox($id, $url) {
		$transcription = $this->spinvoxConnection->getTranscription($url);
		if ($transcription) {
			if (strtoupper($transcription["status"]) == strtoupper(SpinvoxManager::STATUS_CONVERTED))
				$this->saveTranscription($id, $transcription["status"], $transcription["text"]);
			else
				$this->updateTranscriptionStatus($id, $transcription["status"]);
		}
	}
	
	private function sendRequests($sql, $limit) {
		$result = $this->conn->_execute($sql, $limit);
		
		$count = 0;
		while ( $row = $this->conn->_nextRow($result) ) {
			$this->sendRequestsToSpinvox($row[0], $row[1], $row[2]);
			$count++;
		}
		
		return $count;
	}
	
	private function getTranscritions($sql, $limit) {
		$result = $this->conn->_execute($sql, $limit);
		
		$count = 0;
		
		while ( $row = $this->conn->_nextRow($result) ) {
			$this->getTranscriptionsFromSpinvox($row[0], $row[1]);
			$count++;
		}
		
		return $count;
	}
	
	private function insertSpinvoxRequest($xerror, $url, $date, $id) {
		$delete = "DELETE FROM spinvox_request WHERE fk_transcription_id = %d";
		$result = $this->conn->_execute($delete, $id);
		
		$update = "INSERT INTO spinvox_request (x_error, url, date, fk_transcription_id) VALUES ('%s','%s','%s',%d)";
		$result = $this->conn->_execute($update, $xerror, $url, $date, $id);
		
		return $result;
	}
	
	private function saveTranscription($id, $status, $text) {
		$update = "UPDATE transcription SET status='%s', transcription='%s', transcription_date=NOW() WHERE id=%d";
		$result = $this->conn->_execute($update, $status, $text, $id);
		return $result;
	}
	
	private function updateTranscriptionStatus($transId, $status) {
		$update = "UPDATE transcription SET status='%s' WHERE id=%d";
		$result = $this->conn->_execute($update, $status, $transId);
		return $result;
	}
}
?>