<?php

require_once 'Datasource.php';
require_once 'Config.php';
require_once 'ResponseVO.php';

class ResponseDAO {
	
	private $conn;
	private $filePath;
	private $imagePath;
	private $red5Path;
	
	public function ResponseDAO() {
		$settings = new Config ( );
		$this->filePath = $settings->filePath;
		$this->imagePath = $settings->imagePath;
		$this->red5Path = $settings->red5Path;
		$this->conn = new Datasource ( $settings->host, $settings->db_name, $settings->db_username, $settings->db_password );
	}
	
	public function saveResponse(ResponseVO $data){
		set_time_limit(0);
		$thumbnail = $data->thumbnailUri;
		$videoFile = $data->fileIdentifier.'.flv';
		$duration = $this->calculateVideoDuration($videoFile);
		if(!audioOnlyResponse($videoFile)){
			$this->takeRandomSnapshot($videoFile, $data->fileIdentifier);
			$thumbnail = $data->fileIdentifier.'.jpg';
		}
		
		$insert = "INSERT INTO response (fk_user_id, fk_exercise_id, file_identifier, is_private, thumbnail_uri, source, duration, adding_date, rating_amount, character_name, fk_subtitle_id) ";
		$insert = $insert . "VALUES ('%d', '%d', '%s', 1, '%s', '%s', '%s', now(), 0, '%s', %d ) ";
		
		return $this->_create($insert, $data->userId, $data->exerciseId, $data->fileIdentifier,
							  $thumbnail, $data->source, $duration, $data->characterName, $data->subtitleId );
		
	}
	
	public function makePublic(ResponseVO $data)
	{
		$sql = "UPDATE response SET is_private = 0 WHERE (id = '%d' ) ";
		
		return $this->_databaseUpdate ( $sql, $data->id );
	}
	
	private function takeRandomSnapshot($videoFileName,$outputImageName){
		$videoPath  = $this->red5Path .'/'. $videoFileName;
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
	
	private function audioOnlyResponse($videoFilename){
		$videoPath = $this->red5Path .'/'. $videoFilename;
		// Get videofile informationo
		$videoInfo = (exec("ffmpeg -i $videoPath 2>&1",$cmd));
		if(preg_match('/Could not find codec parameters (Video:/s', implode($cmd))){
			//The video resource seems to be only audio
			return true;
		} else {
			return false;
		}
	}
	
	private function calculateVideoDuration($videoFileName){
		$videoPath  = $this->red5Path .'/'. $videoFileName;
		$total = 0;
		
		$resultduration = (exec("ffmpeg -i $videoPath 2>&1",$cmd));
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