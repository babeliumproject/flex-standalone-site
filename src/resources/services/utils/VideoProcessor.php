<?php

require_once 'Config.php';

class VideoProcessor{

	private $uploadsPath;
	private $imagePath;
	private $red5Path;

	private $frameWidth4_3;
	private $frameWidth16_9;
	private $frameHeight;

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
	
	public function isVideoFile($filePath){
		if(is_file($filePath) && filesize($filePath)>0){
			$output = (exec("ffmpeg -i $filePath 2>&1",$cmd));
			return strpos($output, 'Unknown format') ? true : false;
		}
	}
	
	public function checkMimeType($filePath){
		//$mimetype = system("file -bi " . $path);
		//$mimecode = split($mime, ";");
		return true;
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
	
	public function checkAudio(){
		if(preg_match('/Audio: ((\s+),(\s+),(\s+),(\s+),(\s+))', implode($cmd), $audioinfo)){
			$codec = $audioinfo[0];
			$rate = $audioinfo[1];
			$channels = $audioinfo[2];
			$bits = $audioinfo[3];
			$bitrate = $audioinfo[4];
			if($codec == 'aac' && $channels == '5.1')
				//Not valid audio
		}
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