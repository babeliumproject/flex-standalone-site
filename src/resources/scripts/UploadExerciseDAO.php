<?php

if(!defined('CLI_SERVICE_PATH'))
	define('CLI_SERVICE_PATH', '/var/www/babelium/services');

require_once CLI_SERVICE_PATH . '/utils/Datasource.php';
require_once CLI_SERVICE_PATH . '/utils/Config.php';
require_once CLI_SERVICE_PATH . '/utils/VideoProcessor.php';

//Zend Framework should be on php.ini's include_path
require_once 'Zend/Loader.php';

class UploadExerciseDAO{

	private $filePath;
	private $imagePath;
	private $red5Path;
	
	// Youtube video slice properties
	private $email;
	private $passwd;
	private $devKey;
	private $maxDuration;

	private $evaluationFolder;
	private $exerciseFolder;
	private $responseFolder;

	private $conn;
	private $mediaHelper;

	public function UploadExerciseDAO(){
		$settings = new Config();
		$this->filePath = $settings->filePath;
		$this->imagePath = $settings->imagePath;
		$this->posterPath = $settings->posterPath;
		$this->red5Path = $settings->red5Path;

		$this->conn = new Datasource($settings->host, $settings->db_name, $settings->db_username, $settings->db_password);
		$this->mediaHelper = new VideoProcessor();

		$this->_getResourceDirectories();
		$this->_loadZendGdataClasses();
	}
	
	private function _loadZendGdataClasses(){
		Zend_Loader::loadClass ( 'Zend_Gdata_YouTube' );
		Zend_Loader::loadClass ( 'Zend_Gdata_ClientLogin' );
		Zend_Loader::loadClass ( 'Zend_Gdata_App_Exception' );
		Zend_Loader::loadClass ( 'Zend_Gdata_App_Extension_Control' );
		Zend_Loader::loadClass ( 'Zend_Gdata_App_CaptchaRequiredException' );
		Zend_Loader::loadClass ( 'Zend_Gdata_App_HttpException' );
		Zend_Loader::loadClass ( 'Zend_Gdata_App_AuthException' );
		Zend_Loader::loadClass ( 'Zend_Gdata_YouTube_VideoEntry' );
		Zend_Loader::loadClass ( 'Zend_Gdata_App_Entry' );
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
	
	private function authenticate() {
		try {
			$client = Zend_Gdata_ClientLogin::getHttpClient ( $this->email, $this->passwd, 'youtube' );
		} catch ( Zend_Gdata_App_CaptchaRequiredException $cre ) {
			throw new Exception ( "Captcha required: " . $cre->getCaptchaToken () . "\n" . "URL of CAPTCHA image: " . $cre->getCaptchaUrl () . "\n" );
		} catch ( Zend_Gdata_App_AuthException $ae ) {
			throw new Exception ( "Problem authenticating: " . $ae->getMessage () . "\n" );
		}
	
		$client->setHeaders ( 'X-GData-Key', 'key=' . $this->devKey );
		return $client;
	}

	public function processPendingVideos(){
		set_time_limit(0);
		$sql = "SELECT id, name, source, language, title, thumbnail_uri, duration, status, fk_user_id
				FROM exercise WHERE (status='Unprocessed' OR status='UnprocessedNoPractice') ";
		$transcodePendingVideos = $this->_listQuery($sql);
		if(count($transcodePendingVideos) > 0){
			echo "  * There are videos that need to be processed.\n";
			foreach($transcodePendingVideos as $pendingVideo){
				//We want the whole process to be rollbacked when something unexpected happens
				$this->conn->_startTransaction();
				$processingFlag = $this->setExerciseProcessing($pendingVideo->id);
				$path = $this->filePath.'/'.$pendingVideo->name;
				if(is_file($path) && filesize($path)>0 && $processingFlag){
					$outputHash = $this->mediaHelper->str_makerand(11,true,true);
					$outputName = $outputHash . ".flv";
					$outputPath = $this->filePath .'/'. $outputName;

					try {
						$encoding_output = $this->mediaHelper->transcodeToFlv($path,$outputPath);
							
						//Check if the video already exists
						if(!$this->checkIfFileExists($outputPath)){
							//Asuming everything went ok, take a snapshot of the video
							$snapshot_output = $this->mediaHelper->takeFolderedRandomSnapshots($outputPath, $this->imagePath, $this->posterPath);

							//move the outputFile to it's final destination
							$renameResult = rename($outputPath, $this->red5Path .'/'. $this->exerciseFolder .'/'. $outputName);
							if(!$renameResult){
								throw new Exception("Couldn't move transcoded file. Changes rollbacked.");
							}
								
							$mediaData = $this->mediaHelper->retrieveMediaInfo($this->red5Path .'/'. $this->exerciseFolder .'/'. $outputName);
							$duration = $mediaData->duration;

							//Set the exercise as available and update it's data
							//$this->conn->_startTransaction();
								
							$updateResult = $this->setExerciseAvailable($pendingVideo->id, $outputHash, $outputHash.'.jpg', $duration, md5_file($this->red5Path .'/'. $this->exerciseFolder .'/'. $outputName));
							if(!$updateResult){
								//$this->conn->_failedTransaction();
								throw new Exception("Database operation error. Changes rollbacked.");
							}
							
							if($pendingVideo->status == 'UnprocessedNoPractice'){
							
								$sql = "UPDATE exercise SET name = NULL, thumbnail_uri='nothumb.png' WHERE ( id=%d )";
								$this->conn->_execute($sql,$pendingVideo->id);
								if(!$this->conn->_affectedRows())
									throw new Exception("Couldn't update no-practice exercise. Changes rollbacked.");
								$sql = "INSERT INTO response (fk_user_id, fk_exercise_id, file_identifier, is_private, thumbnail_uri, source, duration, adding_date, rating_amount, character_name, fk_transcription_id, fk_subtitle_id)
										VALUES (%d, %d, '%s', false, 'default.jpg', 'Red5', %d, NOW(), 0, 'None', NULL, NULL)";
								$result = $this->conn->_insert($sql,$pendingVideo->userId,$pendingVideo->id,$outputHash,$duration);
								if(!$result)
									throw new Exception("Couldn't insert no-practice response. Changes rollbacked.");
									
								//move the outputFile to it's final destination
								$renameResult = rename($this->red5Path .'/'. $this->exerciseFolder .'/'. $outputName, $this->red5Path .'/'. $this->responseFolder .'/'. $outputName);
								if(!$renameResult){
									throw new Exception("Couldn't move transcoded file. Changes rollbacked.");
								}
								
							} else {
							
								$creditUpdate = $this->_addCreditsForUploading($pendingVideo->userId);
								if(!$creditUpdate){
									//$this->conn->_failedTransaction();
									throw new Exception("Database operation error. Changes rollbacked.");
								}
								
								$historyUpdate = $this->_addUploadingToCreditHistory($pendingVideo->userId, $pendingVideo->id);
								if(!$historyUpdate){
									//$this->conn->_failedTransaction();
									throw new Exception("Database operation error. Changes rollbacked.");
								}
							
							}
								
							$this->conn->_endTransaction();
								
							echo "\n";
							echo "          filename: ".$pendingVideo->name."\n";
							echo "          filesize: ".filesize($path)."\n";
							echo "          input path: ".$path."\n";
							echo "          output path: ".$this->red5Path .'/'. $this->exerciseFolder .'/'. $outputName."\n";
							echo "          encoding output: ".$encoding_output."\n";
							echo "          snapshot output: ".$snapshot_output."\n";
								
							//Remove the old file
							@unlink($path);
						} else {
								
							$this->setExerciseRejected($pendingVideo->id);
							echo "\n";
							echo "          filename: ".$pendingVideo->name."\n";
							echo "          filesize: ".filesize($path)."\n";
							echo "          input path: ".$path."\n";
							echo "          error: Duplicated file\n";
							//Remove the old files
							@unlink($outputPath);
							@unlink($path);
						}

							
					} catch (Exception $e) {
						$this->conn->_failedTransaction();
						echo "          error: ". $e->getMessage()."\n";
					}
				} else {
					$this->conn->_failedTransaction();
					echo "\n";
					echo "          filename: ".$pendingVideo->name."\n";
					echo "          input path: ".$path."\n";
					echo "          error: File not valid or not found\n";
				}
			}
		} else {
			echo "  * There aren't videos that need to be processed.\n";
		}
	}
	
	public function processPendingSlices(){
		set_time_limit(0);
		$sql = "SELECT id, name, source, language, title, thumbnail_uri, duration, status, fk_user_id
					FROM exercise WHERE (status='Unsliced') ";
		$transcodePendingVideos = $this->_listQuery($sql);
		if(count($transcodePendingVideos) > 0){
			echo "  * There are video slices that need to be processed.\n";
			foreach($transcodePendingVideos as $pendingVideo){
				$this->setExerciseProcessing($pendingVideo->id);
				//Prepare for video to be downloaded and sliced up
				$sql2 = "SELECT id, name, watchUrl, start_time, duration
					 	 FROM video_slice WHERE (name = '%s')";
				$vSlice = new stdClass();
				$vSlice = $this->_listSliceQuery($sql2, $pendingVideo->name);
				//Call the download and slice function
				$creation = $this->createSlice($vSlice);
				if ($creation) {
					//The video was downloaded and sliced up
					$sliceFileName = 'SLC'.$pendingVideo->name.'.flv';
					$path = $this->filePath.'/'.$sliceFileName;
					if(is_file($path) && filesize($path)>0){
						$outputHash = $this->mediaHelper->str_makerand(11,true,true);
						$outputName = $outputHash.".flv";
						$outputPath = $this->filePath .'/'. $outputName;
						try{
							//Check if the video already exists
							if(!$this->checkIfFileExists($path)){
								//Asuming everything went ok, take a snapshot of the video
								$snapshot_output = $this->mediaHelper->takeFolderedRandomSnapshots($outputPath, $this->imagePath, $this->posterPath);
								
								//move the outputFile to it's final destination
								rename($path, $this->red5Path .'/'. $this->exerciseFolder .'/'. $outputName);
								$duration = $vSlice->duration;
	
								//Set the exercise as available and update it's data
								$this->conn->_startTransaction();
	
								$updateResult = $this->setExerciseAvailable($pendingVideo->id, $outputHash, $outputHash.'.jpg', $duration, md5_file($this->red5Path .'/'. $this->exerciseFolder .'/'. $outputName));
								if(!$updateResult){
									$this->conn->_failedTransaction();
									throw new Exception("Database operation error. Changes rollbacked. SetExerciseAvailableFail");
								}
	
								$updateSlice = $this->updateSliceName($outputHash,$vSlice->id);
								if(!$updateSlice){
									$this->conn->_failedTransaction();
									throw new Exception("Database operation error. Changes rollbacked. updateSliceNameFail");
								}
	
								$creditUpdate = $this->_addCreditsForUploading($pendingVideo->userId);
								if(!$creditUpdate){
									$this->conn->_failedTransaction();
									throw new Exception("Database operation error. Changes rollbacked. AddCreditsForUploadingFail");
								}
	
								$historyUpdate = $this->_addUploadingToCreditHistory($pendingVideo->userId, $pendingVideo->id);
								if(!$historyUpdate){
									$this->conn->_failedTransaction();
									throw new Exception("Database operation error. Changes rollbacked. addUploadingToCreditHistory");
								}
	
								$this->conn->_endTransaction();
	
								echo "\n";
								echo "          filename: ".$pendingVideo->name."\n";
								echo "          filesize: ".filesize($this->red5Path .'/'. $this->exerciseFolder .'/'. $outputName)."\n";
								echo "          input path: ".$path."\n";
								echo "          output path: ".$this->red5Path .'/'. $this->exerciseFolder .'/'. $outputName."\n";
								echo "          snapshot output: ".$snapshot_output."\n";
							} else {
								//Remove the non-valid files
								//@unlink($outputPath);
								$this->setExerciseRejected($pendingVideo->id);
								echo "\n";
								echo "          filename: ".$pendingVideo->name."\n";
								echo "          filesize: ".filesize($path)."\n";
								echo "          input path: ".$path."\n";
								echo "          error: Duplicated file\n";
							}
							//Remove the old files (original and slice)
							@unlink($path);
							$originalPath = $this->filePath.'/'.$pendingVideo->name.'.flv';
							@unlink($originalPath);
								
						} catch (Exception $e) {
							echo $e->getMessage()."\n";
						}
					}//end if(is_file)
				}else{
					//The video was not downloaded due to duration limit restrictions
					$this->setExerciseRejected($pendingVideo->id);
					echo "\n";
					echo "          filename: ".$pendingVideo->name."\n";
					echo "          filesize: ".filesize($path)."\n";
					echo "          input path: ".$path."\n";
					echo "          error: Duplicated file\n";
	
				}
			}//end for_each
	
		} else {
			echo "  * There aren't video slices that need to be processed.\n";
		}
	
	}
	
	private function createSlice ($data) {
	
		set_time_limit(0); // Bypass the execution time limit
				
			$name = $data->name;
			$watchUrl = $data->watchUrl;
			$start_time = $data->start_time;
			$duration = $data->duration;
	
			$outputFolder = $this->filePath;
			$outputVideo = $outputFolder."/".$name.'.flv';
	
			/*$sql = "SELECT prefValue FROM preferences WHERE (prefName = 'sliceDownCommandPath')";
			 $pathComando = $this->_singleQuery($sql);*/
	
			$maxDurationCheck = $this->checkVideoDuration($name);
	
			if($maxDurationCheck) {
	
				//$comandoDescarga = $pathComando." -w -o ".$outputVideo." ".$watchUrl; // Para Windows, en otro caso poner directamente la llamada al comando youtube-dl
				$comandoDescarga = "youtube-dl -w -o ".$outputVideo." ".$watchUrl;
				$downloadVideo = exec($comandoDescarga); //Download temporarily Video
				$vidDescarga = $outputVideo;
				$sliceFileName = 'SLC'.$name.'.flv';
				$sliceVideo = $outputFolder."/".$sliceFileName;
	
				$comandoRecorte = "ffmpeg -y -i ".$vidDescarga." -ss ".$start_time." -t ".$duration." -s 320x240 -acodec libmp3lame -ar 22050 -ac 2 -f flv ".$sliceVideo; 	//Execute Slice
	
				$ffmpeg_output = exec($comandoRecorte);
			}
	
			if (is_file($sliceVideo)) {
				return true;
			}else{
				return false;
			}
	}
	
	private function checkVideoDuration($videoId) {
		//Check that the video to be downloaded for the slicing process does not exceed maximum duration
		set_time_limit(0);
	
		$httpClient = $this->authenticate ();
		$yt = new Zend_Gdata_YouTube ( $httpClient );
	
		$myVideoEntry = $yt->getVideoEntry($videoId);
		$duration = $myVideoEntry->getVideoDuration();
		$limit = $this->maxDuration;
	
		if ($duration<=$limit) {
			return true;
		}else{
			return false;
		}
	
	}
	
	private function updateSliceName($newName,$id){
	
		$sql = "UPDATE video_slice SET name='%s' WHERE (id=%d) ";
		return $this->conn->_execute($sql, $newName, $id);
	
	}

	private function setExerciseAvailable($exerciseId, $newName, $newThumbnail, $newDuration, $fileHash){

		$sql = "UPDATE exercise SET name='%s', thumbnail_uri='%s', duration='%s', filehash='%s', status='Available'
            	WHERE (id=%d) ";
		$this->conn->_execute ( $sql, $newName, $newThumbnail, $newDuration, $fileHash, $exerciseId );
		return $this->conn->_affectedRows();
	}

	private function setExerciseProcessing($exerciseId){
		$sql = "UPDATE exercise SET status='Processing' WHERE (id=%d) ";
		$this->conn->_execute($sql, $exerciseId);
		return $this->conn->_affectedRows();
	}

	private function setExerciseRejected($exerciseId){
		$sql = "UPDATE exercise SET status='Rejected' WHERE (id=%d) ";
		$this->conn->_execute($sql, $exerciseId);
		return $this->conn->_affectedRows();
	}

	private function _addCreditsForUploading($userId) {
		$sql = "UPDATE (users u JOIN preferences p)
				SET u.creditCount=u.creditCount+p.prefValue 
				WHERE (u.ID=%d AND p.prefName='uploadExerciseCredits') ";
		$this->conn->_execute ( $sql, $userId );
		return $this->conn->_affectedRows();
	}

	private function _addUploadingToCreditHistory($userId, $exerciseId){
		$sql = "SELECT prefValue FROM preferences WHERE ( prefName='uploadExerciseCredits' )";
		$result = $this->conn->_execute ( $sql );
		$row = $this->conn->_nextRow($result);
		if($row){
			$sql = "INSERT INTO credithistory (fk_user_id, fk_exercise_id, changeDate, changeType, changeAmount) ";
			$sql = $sql . "VALUES ('%d', '%d', NOW(), '%s', '%d') ";
			return $this->conn->_insert ($sql, $userId, $exerciseId, 'upload', $row[0]);
		} else {
			return false;
		}
	}


	private function _listQuery() {
		$searchResults = array ();
		$result = $this->conn->_execute ( func_get_args() );

		while ( $row = $this->conn->_nextRow ( $result ) ) {
			$temp = new stdClass();
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
	
	private function _listSliceQuery() {
		$searchResults = array ();
		$result = $this->conn->_execute ( func_get_args() );
	
		while ( $row = $this->conn->_nextRow ( $result ) ) {
			$temp = new stdClass();
			$temp->id= $row [0];
			$temp->name = $row [1];
			$temp->watchUrl = $row [2];
			$temp->start_time = $row [3];
			$temp->duration = $row [4];
				
			array_push ( $searchResults, $temp );
		}
		if (count ( $searchResults ) > 0)
		return $temp;
		else
		return false;
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
	
	public function takeMissingSnapshots(){
		$mediaPaths = array();
		$sql = "SELECT name FROM exercise WHERE true";
		$result = $this->conn->_execute($sql);
		while ( $row = $this->conn->_nextRow ( $result ) ) {
			$tmp = $this->red5Path . '/' . $this->exerciseFolder . '/'. $row[0] . '.flv';
			array_push($mediaPaths,$tmp);
		}
		
		$sql = "SELECT file_identifier FROM response WHERE true";
		$result = $this->conn->_execute($sql);
		while ( $row = $this->conn->_nextRow ( $result ) ) {
			$tmp = $this->red5Path . '/' . $this->responseFolder . '/'. $row[0] . '.flv';
			array_push($mediaPaths,$tmp);
		}
		
		$sql = "SELECT video_identifier FROM evaluation_video WHERE true";
		$result = $this->conn->_execute($sql);
		while ( $row = $this->conn->_nextRow ( $result ) ) {
			$tmp = $this->red5Path . '/' . $this->evaluationFolder . '/'. $row[0] . '.flv';
			array_push($mediaPaths,$tmp);
		}
		
		foreach($mediaPaths as $path){
			try{
				$result = $this->mediaHelper->takeFolderedRandomSnapshots($path, $this->imagePath, $this->posterPath);
			} catch(Exception $e){
				echo $e->getMessage()."\n";
			}
		}
		
		$sql = "UPDATE exercise SET thumbnail_uri = 'default.jpg' WHERE (thumbnail_uri <> 'nothumb.png')";
		$this->conn->_execute($sql);
		$sql = "UPDATE response SET thumbnail_uri = 'default.jpg' WHERE (thumbnail_uri <> 'nothumb.png')";
		$this->conn->_execute($sql);
		$sql = "UPDATE evaluation_video SET thumbnail_uri = 'default.jpg' WHERE (thumbnail_uri <> 'nothumb.png')";
		$this->conn->_execute($sql);
		
	}

}

?>
