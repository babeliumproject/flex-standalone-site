<?php

/**
 * Babelium Project open source collaborative second language oral practice - http://www.babeliumproject.com
 *
 * Copyright (c) 2011 GHyM and by respective authors (see below).
 *
 * This file is part of Babelium Project.
 *
 * Babelium Project is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Babelium Project is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

if(!defined('CLI_SERVICE_PATH'))
define('CLI_SERVICE_PATH', '/var/www/babelium/services');

require_once CLI_SERVICE_PATH . '/utils/Datasource.php';
require_once CLI_SERVICE_PATH . '/utils/Config.php';
require_once CLI_SERVICE_PATH . '/utils/VideoProcessor.php';

//Zend Framework should be on php.ini's include_path
require_once 'Zend/Loader.php';


/**
 * This class performs media processing duties. It should not be called from web scope, but periodically using a cron script
 * 
 * @author Babelium Team
 */
class MediaTask{

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

	
	/**
	 * Constructor function
	 * 
	 * @throws Exception
	 * 		Throws an error if there was any problem establishing a connection with the database.
	 */
	public function MediaTask(){
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

	
	/**
	 * Loads several Zend classes to be able to fetch info of a certain YouTube video
	 */
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

	/**
	 * Retrieves the directory names of several media resources
	 */
	private function _getResourceDirectories(){
		$sql = "SELECT prefValue
				FROM preferences
				WHERE (prefName='exerciseFolder' OR prefName='responseFolder' OR prefName='evaluationFolder') 
				ORDER BY prefName";
		$result = $this->conn->_multipleSelect($sql);
		if($result){
			$this->evaluationFolder = $result[0] ? $result[0]->prefValue : '';
			$this->exerciseFolder = $result[1] ? $result[1]->prefValue : '';
			$this->responseFolder = $result[2] ? $result[2]->prefValue : '';
		}
	}

	/**
	 * Authenticates the application using a YouTube developer key to be able to retrieve info from their API
	 */
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
	
	public function processRawMedia(){
		//Let the script take as much time as it needs
		set_time_limit(0);
		
		//Select fk_media_id's that have a 0 (raw) status but not any 2 (ready) status
		$sql = "SELECT mr.id, mr.fk_media_id, mr.status, mr.filename, mr.timecreated, m.mediacode 
				FROM media_rendition mr INNER JOIN media m ON mr.fk_media_id=m.id 
				WHERE mr.status=0 AND NOT EXISTS(SELECT id FROM media_rendition WHERE status=2 AND fk_media_id=mr.fk_media_id)";
		$rawfiles = $this->conn->_multipleSelect($sql);
		
		if($rawfiles){
			foreach($rawfiles as $file){
				$this->processMediaFile($file);
			}
		}
	}
	
	public function processMediaFile($fileinfo){
		$fullpath = $this->filePath.'/'.$fileinfo->filename;
		if(is_file($fullpath) && filesize($fullpath)){
			$optime = time();
			$newfilename = $fileinfo->mediacode.'_'.$optime.'.flv';
			$transitionalfullpath = $this->filePath .'/'.$newfilename;
			$finalfullpath = $this->red5Path.'/exercises/'.$newfilename;
			$encoding_preset = 2;
			try{
				$this->mediaHelper->transcodeToFlv($fullpath,$transitionalfullpath,$encoding_preset, Config::LEVEL_360P);
		
				$mediainfo = $this->mediaHelper->retrieveMediaInfo($transitionalfullpath);
		
				if($mediainfo->hasVideo){
					$thumbdir = $this->imagePath.'/'.$fileinfo->mediacode;
					$posterdir = $this->posterPath.'/'.$fileinfo->mediacode;
		
					//Take snapshots at 3 random times of the video file
					$this->mediaHelper->takeFolderedRandomSnapshots($transitionalfullpath,$thumbdir,$posterdir);
				}
		
				//Move file from transitional location to final location
				//$moved = rename($transitionalfullpath,$finalfullpath);
				//  looks like rename is not save to use on *nix across filesystems and/or chown/chmod restrictions
				//  PHP Warning:  rename(src,dst): Invalid argument in ... on line ...
				//  return value is false and src still exists but dst also exist
				//  see https://stackoverflow.com/questions/19894649/why-does-rename-return-false-despite-moving-a-file-successully-to-an-nfs-mount
				$moved = copy($transitionalfullpath,$finalfullpath);
				if(!$moved){
					unlink($transitionalfullpath);
					unlink($finalfullpath);
					throw new Exception("Unable to move from transitional path: $transitionalfullpath to final path: $finalfullpath");
				}
				unlink($transitionalfullpath);
		
				$insert = "INSERT INTO media_rendition (fk_media_id,filename,contenthash,status,timecreated,filesize,metadata,dimension)
						   VALUES (%d,'%s','%s',%d,%d,%d,'%s',%d)";
				$mediaid = $fileinfo->fk_media_id;
				$contenthash = $mediainfo->hash;
				$status = 2;
				$filesize = filesize($finalfullpath);
				$dimension = $mediainfo->hasVideo ? $mediainfo->videoHeight : 0;
				$metadata = $this->mediaHelper->custom_json_encode($mediainfo);
				$this->conn->_insert($insert,$mediaid,$newfilename,$contenthash,$status,$optime,$filesize,$metadata,$dimension);
		
			} catch (Exception $e){
				print $e."\n";
			}
		}
	}

	/**
	 * Searches the database for exercises with status field set to 'Unprocessed' or 'UnprocessedNoPractice' and reencodes them using a ffmpeg preset.
	 * Afterwards the resulting file is moved to a public red5 folder.
	 */
	public function processPendingVideos(){
		set_time_limit(0);
		$sql = "SELECT id,
					   name, 
					   source, 
					   language, 
					   title, 
					   thumbnail_uri as thumbnailUri, 
					   duration, 
					   status, 
					   fk_user_id as userId
				FROM exercise WHERE (status='Unprocessed' OR status='UnprocessedNoPractice') ";
		$transcodePendingVideos = $this->conn->_multipleSelect($sql);
		if($transcodePendingVideos){
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
								$result = $this->conn->_update($sql,$pendingVideo->id);
								if(!$result)
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
							//The system tells us that there's another file, that after being transcoded, has the same md5_file() hash this file has
							//@unlink($path);
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

	/**
	 * Searches the database for exercises with status field set to 'Unsliced' and reencodes them using a ffmpeg preset.
	 * Afterwards the resulting file is moved to a public red5 folder.
	 */
	public function processPendingSlices(){
		set_time_limit(0);
		$sql = "SELECT id, name, source, language, title, thumbnail_uri as thumbnailUri, duration, status, fk_user_id as userId
				FROM exercise WHERE (status='Unsliced') ";
		$transcodePendingVideos = $this->conn->_multipleSelect($sql);
		if($transcodePendingVideos){
			echo "  * There are video slices that need to be processed.\n";
			foreach($transcodePendingVideos as $pendingVideo){
				$this->setExerciseProcessing($pendingVideo->id);
				//Prepare for video to be downloaded and sliced up
				$sql2 = "SELECT id, name, watchUrl, start_time, duration
					 	 FROM video_slice WHERE (name = '%s')";
				$vSlice = $this->conn->_multipleSelect($sql2, $pendingVideo->name);
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

	/**
	 * Downloads a YouTube video and reencodes a slice/portion of it
	 */
	private function createSlice ($data) {

		set_time_limit(0);

		$name = $data->name;
		$watchUrl = $data->watchUrl;
		$start_time = $data->start_time;
		$duration = $data->duration;

		$outputFolder = $this->filePath;
		$outputVideo = $outputFolder."/".$name.'.flv';

		/*
		$sql = "SELECT prefValue FROM preferences WHERE (prefName = 'sliceDownCommandPath')";
		$result = $this->_singleSelect($sql);
		$commandPath = $result ? $result->prefValue : false;
		*/

		$maxDurationCheck = $this->checkVideoDuration($name);

		if($maxDurationCheck) {

			//$downloadCommand = $commandPath." -w -o ".$outputVideo." ".$watchUrl; // this is for windows, otherways call youtube-dl directly
			$downloadCommand = "youtube-dl -w -o ".$outputVideo." ".$watchUrl;
			$downloadVideo = exec($downloadCommand); // download temporary Video
			$sliceFileName = 'SLC'.$name.'.flv';
			$sliceVideo = $outputFolder."/".$sliceFileName;

			$sliceCommand = "ffmpeg -y -i ".$outputVideo." -ss ".$start_time." -t ".$duration." -s 320x240 -acodec libmp3lame -ar 22050 -ac 2 -f flv ".$sliceVideo; 	//Execute Slice

			$ffmpeg_output = exec($sliceCommand);
		}

		return is_file($sliceVideo);
	}

	/**
	 * Query the YouTube API to fetch the length of a video and see if it exceeds the maximum duration allowed in our configuration
	 */
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
		return $this->conn->_update($sql, $newName, $id);
	}

	/**
	 * If the reencoding procedure is successful the status field changes to 'Available' and the video is available in the application
	 */
	private function setExerciseAvailable($exerciseId, $newName, $newThumbnail, $newDuration, $fileHash){

		$sql = "UPDATE exercise SET name='%s', thumbnail_uri='%s', duration='%s', filehash='%s', status='Available'
            	WHERE (id=%d) ";
		return $this->conn->_update ( $sql, $newName, $newThumbnail, $newDuration, $fileHash, $exerciseId );
	}

	/**
	 * Reencoding the video can take a while so we put a temporary flag in the status field so that subsequent script executions knows we are currently reencoding that file
	 */
	private function setExerciseProcessing($exerciseId){
		$sql = "UPDATE exercise SET status='Processing' WHERE (id=%d) ";
		return $this->conn->_update($sql, $exerciseId);
	}

	
	/**
	 * If the video file is duplicated or doesn't meet the duration/size constraints of our current configuration the status field is set to rejected.
	 * This way the user can know the video is being rejected because of the aforementioned problems.
	 */
	private function setExerciseRejected($exerciseId){
		$sql = "UPDATE exercise SET status='Rejected' WHERE (id=%d) ";
		return $this->conn->_update($sql, $exerciseId);
	}

	/**
	 * Reward the user with a certain amount of credits for uploading a new exercise and thus collaborating with the application
	 */
	private function _addCreditsForUploading($userId) {
		$sql = "UPDATE (user u JOIN preferences p)
				SET u.creditCount=u.creditCount+p.prefValue 
				WHERE (u.id=%d AND p.prefName='uploadExerciseCredits') ";
		return $this->conn->_update ( $sql, $userId );
	}

	/**
	 * Add an entry to the user's credit history for this exercise upload
	 */
	private function _addUploadingToCreditHistory($userId, $exerciseId){
		$sql = "SELECT prefValue FROM preferences WHERE ( prefName='uploadExerciseCredits' )";
		$result = $this->conn->_singleSelect ( $sql );
		if($result){
			$sql = "INSERT INTO credithistory (fk_user_id, fk_exercise_id, changeDate, changeType, changeAmount) ";
			$sql = $sql . "VALUES ('%d', '%d', NOW(), '%s', '%d') ";
			return $this->conn->_insert ($sql, $userId, $exerciseId, 'upload', $result->prefValue);
		} else {
			return false;
		}
	}

	/**
	 * Retrieve all the md5_file hashes of the videos currently available in the app and compare them to the video that
	 * is being reencoded. If any hash is the same means we have a duplicated video and that video should be rejected.
	 */
	private function checkIfFileExists($path){
		$fileExists = false;
		$currentHash = md5_file($path);
		$sql = "SELECT filehash FROM exercise";
		$videoHashes = $this->conn->_multipleSelect($sql);
		foreach($videoHashes as $vh){
			if($currentHash == $vh->filehash){
				$fileExists = true;
				break;
			}
		}
		return $fileExists;
	}

	/**
	 * Takes 3x thumbnails and 3x posters for all exercise, response and evaluation videos and makes a link named defaut.jpg pointing to one 
	 * of those images.
	 */
	public function takeMissingSnapshots(){
		$mediaPaths = array();

		$sql = "SELECT name FROM exercise WHERE name IS NOT NULL AND name<>''";
		$result = $this->conn->_multipleSelect($sql);
		foreach($result as $r){
			$tmp = $this->red5Path . '/' . $this->exerciseFolder . '/'. $r->name . '.flv';
			$mediaPaths[] = $tmp;
		}
		unset($r);


		$sql = "SELECT file_identifier FROM response WHERE true";
		$result = $this->conn->_multipleSelect($sql);
		foreach($result as $r){
			$tmp = $this->red5Path . '/' . $this->responseFolder . '/'. $r->file_identifier . '.flv';
			$mediaPaths[] = $tmp;
		}
		unset($r);

		$sql = "SELECT video_identifier FROM evaluation_video WHERE true";
		$result = $this->conn->_multipleSelect($sql);
		foreach($result as $r){
			$tmp = $this->red5Path . '/' . $this->evaluationFolder . '/'. $r->video_identifier . '.flv';
			$mediaPaths[] = $tmp;
		}
		unset($r);

		foreach($mediaPaths as $path){
			try{
				$result = $this->mediaHelper->takeFolderedRandomSnapshots($path, $this->imagePath, $this->posterPath);
			} catch(Exception $e){
				echo $e->getMessage()."\n";
			}
		}

		$sql = "UPDATE exercise SET thumbnail_uri = 'default.jpg' WHERE (thumbnail_uri <> 'nothumb.png')";
		$this->conn->_update($sql);
		$sql = "UPDATE response SET thumbnail_uri = 'default.jpg' WHERE (thumbnail_uri <> 'nothumb.png')";
		$this->conn->_update($sql);
		$sql = "UPDATE evaluation_video SET thumbnail_uri = 'default.jpg' WHERE (thumbnail_uri <> 'nothumb.png')";
		$this->conn->_update($sql);

	}

}

?>
