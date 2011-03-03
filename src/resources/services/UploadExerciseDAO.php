<?php

require_once 'utils/Config.php';
require_once 'utils/Datasource.php';
require_once 'utils/SessionHandler.php';

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

	public function UploadExerciseDAO(){
		try {
			$verifySession = new SessionHandler();

			$settings = new Config();
			$this->filePath = $settings->filePath;
			$this->imagePath = $settings->imagePath;
			$this->red5Path = $settings->red5Path;

			$this->frameWidth4_3 = $settings->frameWidth4_3;
			$this->frameWidth16_9 = $settings->frameWidth16_9;
			$this->frameHeight = $settings->frameHeight;

			$this->conn = new Datasource($settings->host, $settings->db_name, $settings->db_username, $settings->db_password);

			$this->_getResourceDirectories();

		} catch (Exception $e) {
			throw new Exception($e->getMessage());
		}
	}

	private function checkVideoFeatures($fileName){
		$correctMimetype = true;
		$correctDuration = true;
		$path = $this->filePath.'/'.$fileName;
		$this->videoObject = new ffmpeg_movie($path,false);
		if ($this->videoObject && checkMimeType($path)){
			//The video must be less than 3minutes long
			if($this->videoObject->getDuration() >= 180 ){
				$correctDuration = false;
			}
		} else{
			$correctMimetype = false;
		}
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

	private function checkMimeType($path){
		//$mimetype = system("file -bi " . $path);
		//$mimecode = split($mime, ";");
		return true;
	}

	public function processPendingVideos(){
		set_time_limit(0);
		$sql = "SELECT id, name, source, language, title, thumbnail_uri, duration, status, fk_user_id
				FROM exercise WHERE (status='Unprocessed') ";
		$transcodePendingVideos = $this->_listQuery($sql);
		if(count($transcodePendingVideos) > 0){
			echo "  * There are videos that need to be processed.\n";
			foreach($transcodePendingVideos as $pendingVideo){
				$this->setExerciseProcessing($pendingVideo->id);
				$path = $this->filePath.'/'.$pendingVideo->name;
				if(is_file($path) && filesize($path)>0){
					$outputHash = $this->str_makerand(11,1,1);
					$outputName = $outputHash . ".flv";
					$outputPath = $this->filePath .'/'. $outputName;
						
					$encoding_output = $this->balancedEncoding($path,$outputPath);
						
					//Check if the video already exists
					if(!$this->checkIfFileExists($outputPath)){
						//Asuming everything went ok, take a snapshot of the video
						$snapshot_output = $this->takeRandomSnapshot($outputName, $outputHash);

						//move the outputFile to it's final destination
						rename($outputPath, $this->red5Path .'/'. $this->exerciseFolder .'/'. $outputName);
						//Remove the old file
						@unlink($path);
						//Set the exercise as available and update it's data
							
						$movie = new ffmpeg_movie($this->red5Path .'/'. $this->exerciseFolder .'/'. $outputName, false);
						$duration = $movie->getDuration();

						$this->setExerciseAvailable($pendingVideo->id, $outputHash, $outputHash.'.jpg', $duration, md5_file($this->red5Path .'/'. $this->exerciseFolder .'/'. $outputName));
						$this->updateCreditCount($pendingVideo->userId, $pendingVideo->id);
						echo "\n";
						echo "          filename: ".$pendingVideo->name."\n";
						echo "          filesize: ".filesize($path)."\n";
						echo "          input path: ".$path."\n";
						echo "          output path: ".$this->red5Path .'/'. $this->exerciseFolder .'/'. $outputName."\n";
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

	private function qualityEncoding($inputFileName, $outputFileName){
		$movie = new ffmpeg_movie($inputFileName,false);
		$videoHeight = $movie->getFrameHeight();
		$videoWidth = $movie->getFrameWidth();

		$ratio = $this->encodingAspectRatio($videoHeight, $videoWidth);
		if ($ratio == 43){
			$width = $this->frameWidth4_3;
			$height = $this->frameHeight;
		} else {
			$width = $this->frameWidth16_9;
			$height = $this->frameHeight;
		}
		$result = (exec("ffmpeg -y -i '".$inputFileName."' -s " . $width . "x" . $height . " -g 300 -qmin 3 -b 512k -acodec libmp3lame -ar 22050 -ac 2  -f flv ".$outputFileName." 2>&1",$output));
	}

	private function balancedEncoding($inputFileName, $outputFileName){
		$movie = new ffmpeg_movie($inputFileName,false);
		$videoHeight = $movie->getFrameHeight();
		$videoWidth = $movie->getFrameWidth();

		$ratio = $this->encodingAspectRatio($videoHeight, $videoWidth);
		if ($ratio == 43){
			$width = $this->frameWidth4_3;
			$height = $this->frameHeight;
		} else {
			$width = $this->frameWidth16_9;
			$height = $this->frameHeight;
		}
		$result = (exec("ffmpeg -y -i '".$inputFileName."' -s " . $width . "x" . $height . " -g 300 -qmin 3 -acodec libmp3lame -ar 22050 -ac 2  -f flv ".$outputFileName." 2>&1",$output));
		return $result;
	}

	private function encodingAspectRatio($frameHeight, $frameWidth){
		if($frameWidth > $frameHeight){
			$originalRatio = $frameWidth / $frameHeight;
			$deviation16_9 = abs(((16/9)-$originalRatio));
			$deviation4_3 = abs(((4/3)-$originalRatio));
			if($deviation4_3 < $deviation16_9){
				//Aspect ratio is likely to be 4:3
				return 43;
			}else{
				//Aspect ratio is likely to be 16:9
				return 169;
			}
		} else{
			return 43;
		}
	}

	public function takeRandomSnapshot($videoFileName,$outputImageName){
		$videoPath  = $this->filePath .'/'. $videoFileName;
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

	private function setExerciseAvailable($exerciseId, $newName, $newThumbnail, $newDuration, $fileHash){

		$sql = "UPDATE exercise SET name='%s', thumbnail_uri='%s', duration='%s', filehash='%s', status='Available'
            WHERE (id=%d) ";
		return $this->conn->_execute ( $sql, $newName, $newThumbnail, $newDuration, $fileHash, $exerciseId );
	}

	private function setExerciseProcessing($exerciseId){
		$sql = "UPDATE exercise SET status='Processing' WHERE (id=%d) ";
		return $this->conn->_execute($sql, $exerciseId);
	}

	private function setExerciseRejected($exerciseId){
		$sql = "UPDATE exercise SET status='Rejected' WHERE (id=%d) ";
		return $this->conn->_execute($sql, $exerciseId);
	}

	private function updateCreditCount($exerciseId){
		$creditData = new CreditHistoryVO();
		$creditData->changeType = "exercise_upload";
		$creditData->changeAmount = 2;
		$creditData->videoExerciseId = $exerciseId;

		$creditDAO = new CreditDAO();
		$creditDAO->addCreditsForUploading();
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
			$temp->title = $row[4];
			$temp->thumbnailUri = $row[5];
			$temp->duration = $row[6];
			$temp->status = $row[7];
			$temp->userId = $row[8];

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

	/*
	 Author: Peter Mugane Kionga-Kamau
	 http://www.pmkmedia.com
	 */
	private function str_makerand ($length, $useupper, $usenumbers)
	{
		$key= '';
		$charset = "abcdefghijklmnopqrstuvwxyz";
		if ($useupper)
		$charset .= "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
		if ($usenumbers)
		$charset .= "0123456789";
		for ($i=0; $i<$length; $i++)
		$key .= $charset[(mt_rand(0,(strlen($charset)-1)))];
		return $key;
	}
}

?>