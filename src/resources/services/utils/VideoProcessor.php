<?php

require_once 'Config.php';

class VideoProcessor{

	private $uploadsPath;
	private $imagePath;
	private $red5Path;

	private $frameWidth4_3;
	private $frameWidth16_9;
	private $frameHeight;

	private $mediaObject;

	private $conn;

	public function VideoProcessor(){
		$settings = new Config();
		$this->mediaObject = new stdclass();

		$this->uploadsPath = $settings->filePath;
		$this->imagePath = $settings->imagePath;
		$this->red5Path = $settings->red5Path;

		$this->frameWidth4_3 = $settings->frameWidth4_3;
		$this->frameWidth16_9 = $settings->frameWidth16_9;
		$this->frameHeight = $settings->frameHeight;

	}

	public function retrieveMediaInfo($filePath = '/opt/red5_r4176/webapps/oflaDemo/streams/exercises/mzgVmrokCM7.flv'){
		$cleanPath = escapeshellcmd($filePath);
		if(is_file($cleanPath) && filesize($cleanPath)>0){
			$output = (exec("ffmpeg -i $cleanPath 2>&1",$cmd));
			$strCmd = implode($cmd);
			if($this->isMediaFile($strCmd)){
				$this->checkAudio($strCmd);
				$this->checkVideo($strCmd);
				var_dump($this->mediaObject);
			} else {
				throw new Exception("Unknown media format");
			}
		} else {
			throw new Exception("Not a file");
		}
	}

	public function isMediaFile($ffmpegOutput){
		$pos = strpos($ffmpegOutput, 'Unknown format');
		if ($pos === false) {
    		return true;
		} else {
		 	return false;
		}
	}

	public function checkAudio($ffmpegOutput){
		if(preg_match('/Audio: (([\w\s\/\[\]:]+), ([\w\s\/\[\]:]+), ([\w\s\/\[\]:]+), ([\w\s\/\[\]:]+), ([\w\s\/\[\]:]+))/s', $ffmpegOutput, $audioinfo)){
			$this->mediaObject->hasAudio = true;
			$this->mediaObject->audioCodec = trim($audioinfo[2]);
			$this->mediaObject->audioRate = trim($audioinfo[3]);
			$this->mediaObject->audioChannels = trim($audioinfo[4]);
			$this->mediaObject->audioBits = trim($audioinfo[5]);
			$this->mediaObject->audioBitrate = trim($audioinfo[6]);
			if($this->mediaObject->audioCodec == 'aac' && $this->mediaObject->audioChannels == '5.1'){
				//Non-transcodable audio
			}
		} else {
			$this->$mediaObject->hasAudio = false;
		}
	}

	public function checkVideo($ffmpegOutput){
		if(preg_match('/Video: (([\w\s\/\[\]:]+), ([\w\s\/\[\]:]+), ([\w\s\/\[\]:]+), ([\w\s\/\[\]:]+), ([\w\s\/\[\]:]+), ([\w\s\/\[\]:]+), ([\w\s\/\[\]:]+))/s', $ffmpegOutput, $result)){
			$this->mediaObject->hasVideo = true;
			$this->mediaObject->videoCodec = trim($result[2]);
			$this->mediaObject->videoColorspace = trim($result[3]);
			$this->mediaObject->videoResolution = trim($result[4]);
			$resolution = explode("x",$this->mediaObject->videoResolution);
			$this->mediaObject->videoWidth = $resolution[0];
			$this->mediaObject->videoHeight = $resolution[1];
			$this->mediaObject->videoFpsBitrate = trim($result[5]);
			$this->mediaObject->videoTbr = trim($result[6]);
			$this->mediaObject->videoTbn = trim($result[7]);
			$this->mediaObject->videoTbc = trim($result[8]);
		} else {
			$this->mediaObject->hasVideo = false;
		}
	}


	public function checkMimeType($filePath){
		//$mimetype = system("file -bi " . $path);
		//$mimecode = split($mime, ";");
		return true;
	}

	public function calculateVideoDuration($filePath){

		$total = 0;

		if(is_file($filePath) && filesize($filePath)>0){
			$resultduration = (exec("ffmpeg -i $filePath 2>&1",$cmd));
			if (preg_match('/Duration: ((\d+):(\d+):(\d+))/s', implode($cmd), $time)) {
				$total = ($time[2] * 3600) + ($time[3] * 60) + $time[4];
			}
		}
		return $total;
	}



	public function takeRandomSnapshot($videoFilePath, $videoFileName, $outputImagePath, $outputImageFileName){

		$videoPath  = $videoFilePath .'/'. $videoFileName . '.flv';
		// where you'll save the image
		$imagePath  = $outputImagePath .'/'. $outputImageFileName . '.jpg';
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



	public function deleteVideoFile($filePath) {
		if(is_file($filePath) && filesize($filePath)>0){
			$success = @unlink ( $filePath );
			return $success;
		}
	}

	public function qualityEncoding($inputFileName, $outputFileName){
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