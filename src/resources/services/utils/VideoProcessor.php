<?php

/**
 * This file is part of Babelium.
 *
 * Babelium is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Babelium is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
 */

require_once 'Config.php';

/**
 * Helper class to perform media transcoding tasks.
 * Uses ffmpeg as an underlying technology.
 *
 * @author GHyM
 */
class VideoProcessor{

	private $uploadsPath;
	private $imagePath;
	private $red5Path;

	private $frameWidth4_3;
	private $frameWidth16_9;
	private $frameHeight;

	private $mediaContainer;

	private $conn;

	public function VideoProcessor(){
		$settings = new Config();

		$this->uploadsPath = $settings->filePath;
		$this->imagePath = $settings->imagePath;
		$this->red5Path = $settings->red5Path;

		$this->frameWidth4_3 = $settings->frameWidth4_3;
		$this->frameWidth16_9 = $settings->frameWidth16_9;
		$this->frameHeight = $settings->frameHeight;

	}

	/**
	 * Determines if the given parameter is a media container and if so retrieves information about it's
	 * different streams and duration.
	 * 
	 * @param string $filePath
	 * @throws Exception
	 */
	public function retrieveMediaInfo($filePath){
		$cleanPath = escapeshellcmd($filePath);
		if(is_file($cleanPath) && filesize($cleanPath)>0){
			$output = (exec("ffmpeg -i $cleanPath 2>&1",$cmd));
			$strCmd = implode($cmd);
			$this->mediaContainer = new stdclass();
			if($this->isMediaFile($strCmd)){
				$this->retrieveAudioInfo($strCmd);
				$this->retrieveVideoInfo($strCmd);
				$this->retrieveDuration($strCmd);
				if($this->mediaContainer->hasVideo)
					$this->retrieveVideoAspectRatio();
				return $this->mediaContainer;
			} else {
				throw new Exception("Unknown media format");
			}
		} else {
			throw new Exception("Not a file");
		}
	}
	
	/**
	 * Checks if the provided file has an acceptable mimeType.
	 * 
	 * @param string $filePath
	 */
	private function checkMimeType($filePath){
		$cleanPath = escapeshellcmd($filePath);
		if(is_file($cleanPath) && filesize($cleanPath)>0){
			$output = (exec("file -bi $cleanPath 2>&1",$cmd));
		
			$implodedOutput = implode($cmd);
			$fileMimeInfo = explode($implodedOutput, ";");
			$fileMimeType = $fileMimeInfo[0];
		
			$validMime = false;
		
			foreach($this->mimeTypes as $mimeType ){
				if($mimeType == $fileMimeType){
					//The mime of this file is among the accepted mimes list
					$validMime = true;
					break;
				}
			}
			return $validMime ? $fileMimeType : "Not valid mime type";
		} else {
			throw new Exception("Not a file");
		}
	}
	
	/**
	 * Deletes the provided file from the filesystem. This operation cannot be undone. Use with caution.
	 *
	 * @param string $filePath
	 */
	private function deleteVideoFile($filePath) {
		$cleanPath = escapeshellcmd($filePath);
		if(is_file($cleanPath) && filesize($cleanPath)>0){
			$success = @unlink ( $cleanPath );
			return $success;
		} else {
			return false;
		}
	}

	/**
	 * Checks if the file provided to ffmpeg is a recognizable media file.
	 *
	 * $ffmpegOutput should be an string that contains all the output of "ffmpeg -i fileName"
	 *
	 * @param unknown_type $ffmpegOutput
	 */
	private function isMediaFile($ffmpegOutput){
		$error1 = strpos($ffmpegOutput, 'Unknown format');
		$error2 = strpos($ffmpegOutput, 'Error while parsing header');
		if ($error1 === false && $error2 === false) {
			return true;
		} else {
			return false;
		}
	}

	/**
	 * Checks if the provided media file contains any audio streams and if so, stores all the info of that audio.
	 * Not all audio codecs provide info about the bitrate so the last group of the regExp is optional.
	 *
	 * $ffmpegOutput should be an string that contains all the output of "ffmpeg -i fileName"
	 *
	 * @param string $ffmpegOutput
	 */
	private function retrieveAudioInfo($ffmpegOutput){
		if(preg_match('/Audio: (([\w\s\/\[\]:]+), ([\w\s\/\[\]:]+), ([\w\s\/\[\]:]+), ([\w\s\/\[\]:]+)(, \w+\s\w+\/s)?)/s', $ffmpegOutput, $audioinfo)){
			$this->mediaContainer->hasAudio = true;
			$this->mediaContainer->audioCodec = trim($audioinfo[2]);
			$this->mediaContainer->audioRate = trim($audioinfo[3]);
			$this->mediaContainer->audioChannels = trim($audioinfo[4]);
			$this->mediaContainer->audioBits = trim($audioinfo[5]);
			$this->mediaContainer->audioBitrate = trim($audioinfo[6]);
		} else {
			$this->mediaContainer->hasAudio = false;
		}
	}

	/**
	 * Checks if the provided media file contains any video streams and if so, stores all the info of that video.
	 * Not all video codecs provide info about the bitrate so the fourth group of the regExp is optional.
	 *
	 * $ffmpegOutput should be an string that contains all the output of "ffmpeg -i fileName"
	 *
	 * @param string $ffmpegOutput
	 */
	private function retrieveVideoInfo($ffmpegOutput){
		if(preg_match('/Video: (([\w\s\/\[\]:]+), ([\w\s\/\[\]:]+), ([\w\s\/\[\]:]+), ([\w\s\/\[\]:]+, )?(\w+\stbr), (\w+\stbn), (\w+\stbc))/s', $ffmpegOutput, $result)){
			$this->mediaContainer->hasVideo = true;
			$this->mediaContainer->videoCodec = trim($result[2]);
			$this->mediaContainer->videoColorspace = trim($result[3]);
			$this->mediaContainer->videoResolution = trim($result[4]);
			$this->mediaContainer->videoFpsBitrate = trim($result[5]);
			$this->mediaContainer->videoTbr = trim($result[6]);
			$this->mediaContainer->videoTbn = trim($result[7]);
			$this->mediaContainer->videoTbc = trim($result[8]);

			$resolution = explode("x",$this->mediaContainer->videoResolution);
			$this->mediaContainer->videoWidth = $resolution[0];
			$this->mediaContainer->videoHeight = $resolution[1];
		} else {
			$this->mediaContainer->hasVideo = false;
		}
	}

	/**
	 * Calculates the duration (in seconds) of the provided media file.
	 *
	 * @param string $ffmpegOutput
	 */
	private function retrieveDuration($ffmpegOutput){
		$totalTime = 0;
		if (preg_match('/Duration: ((\d+):(\d+):(\d+))/s', $ffmpegOutput, $time)) {
			$totalTime = ($time[2] * 3600) + ($time[3] * 60) + $time[4];
		}
		$this->mediaContainer->duration = $totalTime;
	}
	
	private function retrieveVideoAspectRatio(){
		if(!$this->mediaContainer->hasVideo || !$this->mediaContainer->videoHeight || !$this->mediaContainer->videoWidth)
			throw new Exception("Operation not allowed on non-video files")
			
		if($this->mediaContainer->videoWidth > $this->mediaContainer->videoHeight){
			$originalRatio = $this->mediaContainer->videoWidth / $this->mediaContainer->videoHeight;
			$this->mediaContainer->originalAspectRatio = $originalRatio;
			
			$deviation16_9 = abs(((16/9)-$originalRatio));
			$deviation4_3 = abs(((4/3)-$originalRatio));
			$this->mediaContainer->suggestedTranscodingAspectRatio = ($deviation4_3 < $deviation16_9) ? 43 : 169;
		} else{
			$this->mediaContainer->suggestedTranscodingAspectRatio = 43;
		}
		return $this->mediaContainer->suggestedTranscodingAspectRatio;
	}
	

	public function takeRandomSnapshot($filePath, $outputImagePath){
		$cleanPath = escapeshellcmd($filePath);
		$cleanImagePath = escapeshellcmd($outputImagePath);
		
		if(!is_readable($cleanPath) || !is_writable($cleanImagePath))
			throw new Exception("You don't have enough permissions to perform this operation");
		
		if($this->mediaContainer->fileName != $cleanPath){
			try {
				//This file hasn't been scanned yet
				$this->retrieveMediaInfo($cleanPath);
			} catch (Exception $e) {
				throw new Exception($e->getMessage());
			}
		}
		
		//Default thumbnail time
		$second = 1;
		//Random time between 0 and videoDuration
		$second = rand(1, ($this->mediaContainer->duration - 1));
		
		$resultsnap = (exec("ffmpeg -y -i $cleanPath -ss $second -vframes 1 -r 1 -s 120x90 $cleanImagePath 2>&1",$cmd));
		return $resultsnap;
	}


	

	//		if($this->mediaContainer->audioCodec == 'aac' && $this->mediaContainer->audioChannels == '5.1'){
	//				//5.1 AAC audios can't be downmixed to stereo MP3 files directly.
	//			}

	public function qualityEncoding($inputFilepath, $outputFilepath){
		$cleanInputPath = escapeshellcmd($inputFilepath);
		$cleanOutputPath = escapeshellcmd($outputFilepath);
		
		if(!is_readable($cleanInputPath) || !is_writable($cleanOutputPath))
			throw new Exception("You don't have enough permissions to perform this operation");
		
		if($this->mediaContainer->fileName != $cleanInputPath){
			try {
				//This file hasn't been scanned yet
				$this->retrieveMediaInfo($cleanInputPath);
			} catch (Exception $e) {
				throw new Exception($e->getMessage());
			}
		}

		$ratio = $this->encodingAspectRatio($videoHeight, $videoWidth);
		if ($ratio == 43){
			$width = $this->frameWidth4_3;
			$height = $this->frameHeight;
		} else {
			$width = $this->frameWidth16_9;
			$height = $this->frameHeight;
		}
		$result = (exec("ffmpeg -y -i ".$inputFileName." -s " . $width . "x" . $height . " -g 25 -qmin 3 -b 512k -acodec libmp3lame -ar 22050 -ac 2  -f flv ".$outputFileName." 2>&1",$output));
	}

	public function balancedEncoding($inputFileName, $outputFileName){
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
		$result = (exec("ffmpeg -y -i ".$inputFileName." -s " . $width . "x" . $height . " -g 25 -qmin 3 -acodec libmp3lame -ar 22050 -ac 2  -f flv ".$outputFileName." 2>&1",$output));
		return $result;
	}

	public function encodingAspectRatio($frameHeight, $frameWidth){
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

	/*
	 Author: Peter Mugane Kionga-Kamau
	 http://www.pmkmedia.com
	 */
	public function str_makerand ($length, $useupper, $usenumbers)
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