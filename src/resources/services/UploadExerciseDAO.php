<?php

require_once 'utils/Config.php';
require_once 'utils/Datasource.php';
require_once 'utils/VideoProcessor.php';
require_once 'vo/ExerciseVO.php';
require_once 'vo/CreditHistoryVO.php';

require_once 'CreditDAO.php';

class UploadExerciseDAO{

	private $filePath;
	private $imagePath;
	private $red5Path;
	
	private $evaluationFolder;
	private $exerciseFolder;
	private $responseFolder;

	private $frameWidth4_3;
	private $frameWidth16_9;
	private $frameHeight;

	private $conn;
	private $videoProcessor;

	public function UploadExerciseDAO(){
		$settings = new Config();
		$this->filePath = $settings->filePath;
		$this->imagePath = $settings->imagePath;
		$this->red5Path = $settings->red5Path;

		$this->frameWidth4_3 = $settings->frameWidth4_3;
		$this->frameWidth16_9 = $settings->frameWidth16_9;
		$this->frameHeight = $settings->frameHeight;

		$this->conn = new Datasource($settings->host, $settings->db_name, $settings->db_username, $settings->db_password);
		
		//This class handles all the video processing tasks
		$this->videoProcessor = new VideoProcessor();
		
		//We retrieve the resource directories from the database
		$this->_getResourceDirectories();
	}

	private function checkVideoFeatures($fileName){
		$correctMimetype = true;
		$correctDuration = true;
		$path = $this->filePath.'/'.$fileName;
		
		if ($this->videoProcessor->isVideoFile($path) && $this->videoProcessor->checkMimeType($path)){
			//The video must be less than 3minutes long
			if($this->videoProcessor->calculateVideoDuration($path) >= 180 ){
				$correctDuration = false;
			}
		} else{
			$correctMimetype = false;
		}
	}

	public function processPendingVideos(){
		set_time_limit(0);
		$sql = "SELECT id, name, source, language, fk_user_id, title, thumbnail_uri, duration, status
				FROM exercise WHERE (status='Unprocessed') ";
		$transcodePendingVideos = $this->_listQuery($sql);
		if(count($transcodePendingVideos) > 0){
			echo "  * There are videos that need to be processed.\n";
			foreach($transcodePendingVideos as $pendingVideo){
				$this->setExerciseProcessing($pendingVideo->id);
				$path = $this->filePath.'/'.$pendingVideo->name;
				if(is_file($path) && filesize($path)>0){
					$outputHash = $this->videoProcessor->str_makerand(11,1,1);
					$outputName = $outputHash . ".flv";
					$outputPath = $this->filePath .'/'. $outputName;
					
					$encoding_output = $this->videoProcessor->balancedEncoding($path,$outputPath);
					
					//Check if the video already exists
					if(!$this->checkIfFileExists($outputPath)){
						//Asuming everything went ok, take a snapshot of the video
						$snapshot_output = $this->videoProcessor->takeRandomSnapshot($outputName, $outputHash);
		
						//move the outputFile to it's final destination
						$finalPath = $this->red5Path. '/'. $this->exerciseFolder . '/' . $outputName;
						rename($outputPath, $finalPath);
						//Remove the old file
						@unlink($path);
		 
						$duration = $this->videoProcessor->calculateVideoDuration($finalPath);
						
						//Set the exercise as available and update it's data
						$this->setExerciseAvailable($pendingVideo->id, $outputHash, $outputHash.'.jpg', $duration, md5_file($finalPath));
						$this->updateCreditCount($pendingVideo->userId, $pendingVideo->id);
						echo "\n";
						echo "          filename: ".$pendingVideo->name."\n";
						echo "          filesize: ".filesize($path)."\n";
						echo "          input path: ".$path."\n";
						echo "          output path: ".$this->red5Path. '/'. $outputName."\n";
						echo "          encoding output: ".$encoding_output."\n";
						echo "          snapshot output: ".$snapshot_output."\n";
					} else {
						//Remove the non-valid files
						@unlink($path);
						@unlink($outputPath);
						$this->setExerciseRejected($pendingVideo->id);
						echo "\n";
						echo "          filename: ".$pendingVideo->name."\n";
						echo "          filesize: ".filesize($path)."\n";
						echo "          input path: ".$path."\n";
						echo "          error: Duplicated file\n";
					}
				}
			}
		} else {
			echo "  * There aren't videos that need to be processed.\n";		
		}
	}

	private function setExerciseAvailable($exerciseId, $newName, $newThumbnail, $newDuration, $fileHash){

		$sql = "UPDATE exercise SET name='%s', thumbnail_uri='%s', duration='%s', filehash='%s', status='Available'
            WHERE (id=%d) ";
		return $this->_databaseUpdate ( $sql, $newName, $newThumbnail, $newDuration, $fileHash, $exerciseId );
	}
	
	private function setExerciseProcessing($exerciseId){
		$sql = "UPDATE exercise SET status='Processing' WHERE (id=%d) ";
		return $this->_databaseUpdate($sql, $exerciseId);
	}
	
	private function setExerciseRejected($exerciseId){
		$sql = "UPDATE exercise SET status='Rejected' WHERE (id=%d) ";
		return $this->_databaseUpdate($sql, $exerciseId);
	}
	
	private function updateCreditCount($userId, $exerciseId){
		$creditData = new CreditHistoryVO();
		$creditData->changeType = "exercise_upload";
		$creditData->changeAmount = 2;
		$creditData->userId = $userId;
		$creditData->videoExerciseId = $exerciseId;
		
		$creditDAO = new CreditDAO();
		$creditDAO->addCreditsForUploading($userId);
		$creditDAO->addEntryToCreditHistory($creditData);
	}


	private function _listQuery() {
		$searchResults = array ();
		$result = $this->conn->_execute ( func_get_args() );

		while ( $row = $this->conn->_nextRow ( $result ) ) {
			$temp = new ExerciseVO ( );
			$temp->id = $row[0];
			$temp->name = $row[1];
			$temp->source = $row[2];
			$temp->language = $row[3];
			$temp->userId = $row[4];
			$temp->title = $row[5];
			$temp->thumbnailUri = $row[6];
			$temp->duration = $row[7];
			$temp->status = $row[8];

			array_push ( $searchResults, $temp );
		}

		return $searchResults;
	}

	private function _listHash(){
		$searchResults = array();
		$result = $this->conn->_execute(func_get_args());

		while ($row = $this->conn->_nextRow ($result)){
			array_push($searchResults, $row[0]);
		}
		return $searchResults;
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

	private function _databaseUpdate() 
	{	
		$result = $this->conn->_execute ( func_get_args() );

		return $result;
	}

	private function checkIfFileExists($path){
		$fileExists = false;
		$currentHash = md5_file($path);
		$sql = "SELECT filehash FROM exercise";
		$videoHashes = $this->_listHash($sql);
		foreach($videoHashes as $existingHash){
			if ($existingHash == $currentHash){
				$fileExists = true;
				break;
			}
		}
		return $fileExists;
	}
}

?>
