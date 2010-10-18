<?php

require_once 'utils/Config.php';
require_once 'utils/Datasource.php';
require_once 'utils/SessionHandler.php';

require_once 'vo/ResponseVO.php';
require_once 'vo/UserVO.php';

class ResponseDAO {

	private $conn;
	private $filePath;
	private $imagePath;
	private $red5Path;

	private $evaluationFolder = '';
	private $exerciseFolder = '';
	private $responseFolder = '';

	public function ResponseDAO() {
		try {
			$verifySession = new SessionHandler(true);
			$settings = new Config ( );
			$this->filePath = $settings->filePath;
			$this->imagePath = $settings->imagePath;
			$this->red5Path = $settings->red5Path;
			$this->conn = new Datasource ( $settings->host, $settings->db_name, $settings->db_username, $settings->db_password );

		} catch (Exception $e) {
			throw new Exception($e->getMessage());
		}
	}

	public function saveResponse(ResponseVO $data){
		set_time_limit(0);
		$this->_getResourceDirectories();
		$thumbnail = $data->thumbnailUri;
		$duration = $this->calculateVideoDuration($data->fileIdentifier);
		if(!$this->audioOnlyResponse($data->fileIdentifier)){
			$this->takeRandomSnapshot($data->fileIdentifier, $data->fileIdentifier);
			$thumbnail = $data->fileIdentifier.'.jpg';
		}

		$insert = "INSERT INTO response (fk_user_id, fk_exercise_id, file_identifier, is_private, thumbnail_uri, source, duration, adding_date, rating_amount, character_name, fk_subtitle_id) ";
		$insert = $insert . "VALUES ('%d', '%d', '%s', 1, '%s', '%s', '%s', now(), 0, '%s', %d ) ";

		return $this->_create($insert, $_SESSION['uid'], $data->exerciseId, $data->fileIdentifier,
		$thumbnail, $data->source, $duration, $data->characterName, $data->subtitleId );

	}

	public function makePublic(ResponseVO $data)
	{
		$result = 0;
		$responseId = $data->id;
		
		$this->conn->_startTransaction();
		
		$sql = "UPDATE response SET is_private = 0 WHERE (id = '%d' ) ";

		$update = $this->_databaseUpdate ( $sql, $responseId );
		if(!$update){
			$this->conn->_failedTransaction();
			throw new Exception("Response publication failed");
		}
		
		//Update the user's credit count
		$creditUpdate = $this->_subCreditsForEvalRequest();
		if(!$creditUpdate){
			$this->conn->_failedTransaction();
			throw new Exception("Credit addition failed");
		}

		//Update the credit history
		$creditHistoryInsert = $this->_addEvalRequestToCreditHistory($responseId);
		if(!$creditHistoryInsert){
			$this->conn->_failedTransaction();
			throw new Exception("Credit history update failed");
		}
		
		if($update && $creditUpdate && $creditHistoryInsert){
			$this->conn->_endTransaction();

			$result = $this->_getUserInfo();
		}
		
		return $result;
		
	}

	private function _subCreditsForEvalRequest() {
		$sql = "UPDATE (users u JOIN preferences p)
			SET u.creditCount=u.creditCount-p.prefValue 
			WHERE (u.ID=%d AND p.prefName='evaluationRequestCredits') ";
		return $this->_databaseUpdate ( $sql, $_SESSION['uid'] );
	}

	private function _addEvalRequestToCreditHistory($responseId){
		$sql = "SELECT prefValue FROM preferences WHERE ( prefName='evaluationRequestCredits' )";
		$result = $this->conn->_execute ( $sql );
		$row = $this->conn->_nextRow($result);
		if($row){
			$changeAmount = $row[0];
			$sql = "SELECT fk_exercise_id FROM response WHERE (id='%d')";
			$result = $this->conn->_execute($sql, $responseId);
			$row = $this->conn->_nextRow($result);
			if($row){
				$exerciseId = $row[0];
				$sql = "INSERT INTO credithistory (fk_user_id, fk_exercise_id, fk_response_id, changeDate, changeType, changeAmount) ";
				$sql = $sql . "VALUES ('%d', '%d', '%d', NOW(), '%s', '%d') ";
				return $this->_create($sql, $_SESSION['uid'], $exerciseId, $responseId, 'eval_request', $changeAmount);
			} else {
				return false;
			}
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

	private function takeRandomSnapshot($videoFileName,$outputImageName){
		$videoPath  = $this->red5Path .'/'. $this->responseFolder .'/'. $videoFileName . '.flv';
		// where you'll save the image
		$imagePath  = $this->imagePath .'/'. $outputImageName . '.jpg';
		// default time to get the image
		$second = 1;

		// get the duration and a random place within that
		$resultduration = (exec("ffmpeg -i '".$videoPath."' 2>&1",$cmd));
		if (preg_match('/Duration: ((\d+):(\d+):(\d+))/s', implode($cmd), $time)) {
			$total = ($time[2] * 3600) + ($time[3] * 60) + $time[4];
			$second = rand(1, ($total - 1));
		}
		$resultsnap = (exec("ffmpeg -y -i '".$videoPath."' -r 1 -ss $second -vframes 1 -r 1 -s 120x90 $imagePath 2>&1",$cmd));
		return $resultsnap;
	}

	private function audioOnlyResponse($videoFilename){
		$videoPath = $this->red5Path .'/'. $this->responseFolder .'/'. $videoFilename . '.flv';
		// Get videofile informationo
		$videoInfo = (exec("ffmpeg -i '".$videoPath."' 2>&1",$cmd));
		if(preg_match('/Could not find codec parameters/s', implode($cmd))){
			//The video resource seems to be only audio
			return true;
		} else {
			return false;
		}
	}

	private function calculateVideoDuration($videoFileName){
		$videoPath  = $this->red5Path .'/'. $this->responseFolder .'/'. $videoFileName . '.flv';
		$total = 0;

		$resultduration = (exec("ffmpeg -i '".$videoPath."' 2>&1",$cmd));
		if (preg_match('/Duration: ((\d+):(\d+):(\d+))/s', implode($cmd), $time)) {
			$total = ($time[2] * 3600) + ($time[3] * 60) + $time[4];
		}
		return $total;
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