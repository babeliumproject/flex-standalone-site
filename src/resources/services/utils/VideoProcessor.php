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

if(!defined('SERVICE_PATH'))
define('SERVICE_PATH', '/services/');

if(!defined('WEBROOT_PATH'))
define('WEBROOT_PATH', '/var/www/babelium');

require_once WEBROOT_PATH . SERVICE_PATH . 'utils/Config.php';

/**
 * Helper class to perform media transcoding tasks.
 * Uses ffmpeg as an underlying technology.
 *
 * @author Inko Perurena
 */
class VideoProcessor{

	private $uploadsPath;
	private $imagePath;
	private $red5Path;

	private $frameWidth4_3;
	private $frameWidth16_9;
	private $frameHeight;
	
	private $ffmpegCmdPath;
	private $fileCmdPath;
	private $soxCmdPath;

	private $mediaContainer;
	private $encodingPresets = array();

	private $conn;

	public function __construct(){
		$settings = new Config();

		$this->uploadsPath = $settings->filePath;
		$this->imagePath = $settings->imagePath;
		$this->red5Path = $settings->red5Path;

		$this->frameWidth4_3 = $settings->frameWidth4_3;
		$this->frameWidth16_9 = $settings->frameWidth16_9;
		$this->frameHeight = $settings->frameHeight;
		
		$this->ffmpegCmdPath = $settings->ffmpegCmdPath ? $settings->ffmpegCmdPath : 'ffmpeg';
		$this->fileCmdPath = $settings->fileCmdPath ? $settings->fileCmdPath : 'file';
		$this->soxCmdPath = $settings->soxCmdPath ? $settings->soxCmdPath : 'sox';

		$this->encodingPresets[] = $this->ffmpegCmdPath . " -y -i '%s' -s %dx%d -g 25 -qmin 3 -b 512k -acodec libmp3lame -ar 22050 -ac 2 -f flv '%s' 2>&1";
		$this->encodingPresets[] = $this->ffmpegCmdPath . " -y -i '%s' -s %dx%d -g 25 -qmin 3 -acodec libmp3lame -ar 22050 -ac 2 -f flv '%s' 2>&1";

	}

    /**
     * Tests if the system command execution was successful or not.
     *
     * @param String $cmd
     *      A String with the command to pass to the system's shell
     * @return Array
     *      The output of the command in a line by line array
     * @throws Exception
     *      The reason why the command call was not successful
     */
    private function execWrapper($cmd){
        if(!$cmd || !is_string($cmd) || empty($cmd))
            throw new Exception("Command is not a string or is empty");
        $lastline = exec($cmd,$output,$ret_val);
        switch($ret_val){
            case 0:
                return $output;
            case 1:
                throw new Exception("Command failed [$lastline]: $cmd");
            case 126:
                throw new Exception("Permission denied: $cmd");
            case 127:
                throw new Exception("Command not found: $cmd");
            default:
                throw new Exception("Command returned a $ret_val: $cmd");
        }
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
            $cmd_template = "%s %s '%s'";
            $cmd_name = 'ffprobe';
            $cmd_options = '-print_format json -show_streams -show_format -v quiet';
            $cmd_input = $cleanPath;
            $cmd = sprintf($cmd_template,$cmd_name,$cmd_options,$cmd_input);
            
           
            $output = $this->execWrapper($cmd);
 
            //Convert output array to a single string
            $str_output = preg_replace('/\s{2,}/', ' ', implode($output));
            $json_output = json_decode($str_output);
            
            //The output object should have 'format' and 'streams' properties
            if($json_output && isset($json_output->format) && isset($json_output->streams)){
                $this->mediaContainer = new stdClass();

                //Get file content hash to look for duplicates
                $this->mediaContainer->hash = md5_file($cleanPath);
                
                //Retrieve media file duration (in seconds)
                $this->mediaContainer->duration = $json_output->format->duration;
                
                foreach ($json_output->streams as $stream){
                    if($stream->codec_type == 'audio'){
                        $this->mediaContainer->hasAudio = true;
                        $this->retrieveAudioInfo($stream);
                    }
                    if($stream->codec_type == 'video'){
                        $this->mediaContainer->hasVideo = true;
                        $this->retrieveVideoInfo($stream);
                    }
                }
                
                return $this->mediaContainer;
            } else {
                throw new Exception("Unknown media format\n");
            }
		} else {
			throw new Exception("Not a file\n");
		}
	}

	/**
	 * Checks if the provided file pertains to a certain mime type category
	 *
	 * @param String $filePath
	 * 		The absolute path of the file you want to check
	 * @param int $type
	 * 		The kind of mime you expect for this file. 0 for video, 1 for audio
	 * @return boolean $validMime
	 * 		Returns true if the file's mime fits the expected category or false if not.
	 * @throws Exception
	 * 		The provided file or path does not exist
	 */
	public function checkMimeType($filePath,$type=0){
		$mimeCategory = $type ? 'audio' : 'video';
		$cleanPath = escapeshellcmd($filePath);
		if(is_readable($cleanPath)){
			$output = (exec($this->fileCmdPath." -bi '$cleanPath' 2>&1",$cmd));
			$implodedOutput = implode($cmd);
			if($errormsg = $this->system_command_unavailable($this->fileCmdPath, $implodedOutput)){
				throw new Exception($errormsg);
			} else {
				$fileMimeInfo = explode($implodedOutput, ";");
				$fileMimeType = $fileMimeInfo[0];
				$validMime = false;
				if(strpos($implodedOutput,$mimeCategory) !== false){
					$validMime = true;
				}
				return $validMime;
			}
		} else {
			throw new Exception("Not a file\n");
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

    private function retrieveAudioInfo($streamdata){
        if($streamdata->codec_type == 'audio'){
            $this->mediaContainer->audioCodec = $streamdata->codec_name;
            $this->mediaContainer->audioRate = $streamdata->sample_rate;
            $this->mediaContainer->audioChannels = $streamdata->channels;
            $this->mediaContainer->audioBits = $streamdata->sample_fmt; // format used to store each audio sample
            $this->mediaContainer->audioBitrate = $streamdata->bit_rate;
        }
	}

	private function retrieveVideoInfo($streamdata){
        if($streamdata->codec_type == 'video'){
            $this->mediaContainer->videoCodec = $streamdata->codec_name;
            $this->mediaContainer->videoColorspace = $streamdata->pix_fmt;
            $this->mediaContainer->videoTbr = $streamdata->r_frame_rate;
            $this->mediaContainer->videoTbn = $streamdata->time_base;
            $this->mediaContainer->videoTbc = $streamdata->codec_time_base;
            $this->mediaContainer->videoBitrate= $streamdata->bit_rate; //expressed in bits per second
            
            //flv1 video streams don't provide duration and frame number information
            if(isset($streamdata->nb_frames) && isset($streamdata->duration))
                $this->mediaContainer->videoFps = round($streamdata->nb_frames/$streamdata->duration,2);
            
            $this->mediaContainer->videoWidth = $streamdata->width;
            $this->mediaContainer->videoHeight = $streamdata->height;
            
            //Calculate nominal display aspect ratio
            if($streamdata->width > $streamdata->height){
                $originalRatio = $streamdata->width / $streamdata->height;
                $this->mediaContainer->originalAspectRatio = $originalRatio;
                $diff_169 = abs(((16/9)-$originalRatio));
                $diff_43 = abs(((4/3)-$originalRatio));
                $this->mediaContainer->suggestedTranscodingAspectRatio = ($diff_43 < $diff_169) ? 43 : 169;
            } else{
                $this->mediaContainer->suggestedTranscodingAspectRatio = 43;
            }

        }
	}

	/**
	 * Takes a thumbnail image of the provided video and leaves it at the defined destination. Checks if the provided paths
	 * are readable/writable and if needed retrieves the info of the provided video file.
	 *
	 * @param string $filePath
	 * @param string $outputImagePath
	 * @throws Exception
	 */
	public function takeRandomSnapshot($filePath, $outputImagePath, $snapshotWidth = 120, $snapshotHeight = 90){
		$cleanPath = escapeshellcmd($filePath);
		$cleanImagePath = escapeshellcmd($outputImagePath);

		if(!is_readable($cleanPath))
			throw new Exception("You don't have enough permissions to read from the input: ".$cleanPath."\n");
		if(!is_writable(dirname($cleanImagePath)))
			throw new Exception("You don't have enough permissions to write to the output: ".$cleanImagePath."\n");
		if(!$this->mediaContainer || !$this->mediaContainer->hash || ($this->mediaContainer->hash != md5_file($cleanPath)) ){
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

		$resultsnap = (exec($this->ffmpegCmdPath." -y -i '$cleanPath' -ss $second -vframes 1 -r 1 -s ". $snapshotWidth . "x" . $snapshotHeight ." '$cleanImagePath' 2>&1",$cmd));
		$strCmd = implode($cmd);
		if($errormsg = $this->system_command_unavailable($this->ffmpegCmdPath, $strCmd)){
			throw new Exception($errormsg);
		}
		return $resultsnap;
	}

	/**
	 * Takes various images from the provided video and creates a folder to store them. Checks if the provided paths
	 * are readable/writable and if needed retrieves the info of the provided video file.
	 *
	 * @param string $filePath
	 * @param string $outputImagePath
	 * @throws Exception
	 */
	public function takeFolderedRandomSnapshots($filePath, $thumbPath, $posterPath, $thumbnailWidth = 120, $thumbnailHeight = 90, $snapshotCount = 3){
		$cleanVideoPath = escapeshellcmd($filePath);
		$cleanThumbPath = realpath(escapeshellcmd($thumbPath));
		$cleanPosterPath = realpath(escapeshellcmd($posterPath));

		if( !is_readable($cleanVideoPath) || !is_file($cleanVideoPath) )
			throw new Exception("You don't have enough permissions to read from the input, or provided path is not a file: ".$cleanVideoPath."\n");
		if( !is_dir($cleanThumbPath) || !is_writable($cleanThumbPath) || !is_dir($cleanPosterPath) || !is_writable($cleanPosterPath) )
			throw new Exception("You don't have enough permissions to write to the provided outputs: ".$cleanThumbPath.", ".$cleanPosterPath."\n");
		if(!$this->mediaContainer || !$this->mediaContainer->hash || ($this->mediaContainer->hash != md5_file($cleanVideoPath)) ){
			try {
				//This file hasn't been scanned yet
				$this->retrieveMediaInfo($cleanVideoPath);
			} catch (Exception $e) {
				throw new Exception($e->getMessage());
			}
		}

		$resultsnap = 'No snapshot was taken';
		if($this->mediaContainer->hasVideo){

			//Create a folder to hold all the thumbnails, only if doesn't exist
			$path_parts = pathinfo($cleanVideoPath);
			$hash = $path_parts['filename'];
			$cleanThumbPath = $cleanThumbPath . '/' . $hash;
			$cleanPosterPath = $cleanPosterPath . '/' . $hash;

			if(!is_dir($cleanThumbPath)){
				if(!mkdir($cleanThumbPath)){
					throw new Exception("You don't have enough permissions to create a thumbnail folder\n");
				}
			}
			if(!is_dir($cleanThumbPath) || !is_writable($cleanThumbPath)){
				throw new Exception("Yon don't have enough permissions to write to the thumbnail folder\n");
			}

			if(!is_dir($cleanPosterPath)){
				if(!mkdir($cleanPosterPath)){
					throw new Exception("You don't have enough permissions to create a poster folder\n");
				}
			}
			if(!is_dir($cleanPosterPath) || !is_writable($cleanPosterPath)){
				throw new Exception("Yon don't have enough permissions to write to the poster folder\n");
			}

			//Default thumbnail time
			$second = 1;
			$lastSecond = 1;
			for($i=0; $i<$snapshotCount; $i++){

				//Random time between 1 and videoDuration-1
				$second = rand(1, ($this->mediaContainer->duration - 1));
				$lastSecond = $second !== $lastSecond ? $second : rand(1, ($this->mediaContainer->duration -1));

				$toPath = $cleanThumbPath . '/' . sprintf('%02d.jpg',$i+1);
				$poPath = $cleanPosterPath . '/' . sprintf('%02d.jpg',$i+1);
				if(!is_file($toPath)){
					$resultsnap = (exec($this->ffmpegCmdPath." -y -i '$cleanVideoPath' -ss $lastSecond -vframes 1 -r 1 -s ". $thumbnailWidth . "x" . $thumbnailHeight ." '$toPath' 2>&1",$cmd));
					$strCmd = implode($cmd);
					if($errormsg = $this->system_command_unavailable($this->ffmpegCmdPath, $strCmd)){
						throw new Exception($errormsg);
					}
				}
				
				if(!is_file($poPath)){
					$resultsnap = (exec($this->ffmpegCmdPath." -y -i '$cleanVideoPath' -ss $lastSecond -vframes 1 -r 1 '$poPath' 2>&1",$cmd));
					$strCmd = implode($cmd);
					if($errormsg = $this->system_command_unavailable($this->ffmpegCmdPath, $strCmd)){
						throw new Exception($errormsg);
					}
				}
			}

			//Create a symbolic link to the first generated thumbnail/poster to set it as the default image
			if( is_link($cleanThumbPath.'/default.jpg') ){
				unlink($cleanThumbPath.'/default.jpg');
			}
			if( is_link($cleanPosterPath.'/default.jpg') ){
				unlink($cleanPosterPath.'/default.jpg');
			}
			if( !symlink($cleanThumbPath.'/01.jpg', $cleanThumbPath.'/default.jpg')  ){
				throw new Exception ("Couldn't create link for the thumbnail\n");
			}
			if( !symlink($cleanPosterPath.'/01.jpg', $cleanPosterPath.'/default.jpg') ){
				throw new Exception ("Couldn't create link for the poster\n");
			}
		}
		return $resultsnap;
	}

	/**
	 * Transcodes the provided video file into an FLV container video with stereo MP3 audio. Checks if the provided paths
	 * are readable/writable and if needed retrieves the info of the provided video file.
	 *
	 * The preset parameter defines the encoding preset index the function will be using. Normally presets are arranged by
	 * produced quality level in top-down way. So preset[0] is the best available quality and preset[n] is the worst available.
	 *
	 * @param string $inputFilepath
	 * @param string $outputFilepath
	 * @param int $preset
	 * @throws Exception
	 */
	public function transcodeToFlv($inputFilepath, $outputFilepath, $preset = 1){
		$cleanInputPath = escapeshellcmd($inputFilepath);
		$cleanOutputPath = escapeshellcmd($outputFilepath);
			
		if(!is_readable($cleanInputPath))
			throw new Exception("You don't have enough permissions to read from the input: ".$cleanInputPath."\n");
		if(!is_writable(dirname($cleanOutputPath)))
			throw new Exception("You don't have enough permissions to write to the output: ".$cleanOutputPath."\n");

		if(!$this->mediaContainer || !$this->mediaContainer->hash || $this->mediaContainer->hash != md5_file($cleanInputPath)){
			try {
				//This file hasn't been scanned yet
				$this->retrieveMediaInfo($cleanInputPath);
			} catch (Exception $e) {
				throw new Exception($e->getMessage());
			}
		}

		if ($this->mediaContainer->suggestedTranscodingAspectRatio == 43){
			$width = $this->frameWidth4_3;
			$height = $this->frameHeight;
		} else {
			$width = $this->frameWidth16_9;
			$height = $this->frameHeight;
		}

		if($this->mediaContainer->hasAudio){
			//5.1 AAC audio can't be downmixed to stereo audio using ffmpeg
			if($this->mediaContainer->audioCodec == 'aac' && $this->mediaContainer->audioChannels == '5.1'){
				/*
				 * A workaround for this issue could be to transcode the audio to an 5.1 AC3 file first using
				 * MKV as a container (because it can contain most formats without complaining) and then
				 * transcoding this MKV using our regular transcoding preset. For now, we will cancel the
				 * transcoding process and raise an exception.
				 */
				throw new Exception("Non-transcodable audio. Transcode aborted.\n");
			}
		}

		if($preset >=0 && $preset < count($this->encodingPresets)){
			$sysCall = sprintf($this->encodingPresets[$preset],$cleanInputPath, $width, $height, $cleanOutputPath);
			$result = (exec($sysCall,$output));
			$strCmd = implode($output);
			if($errormsg = $this->system_command_unavailable($this->ffmpegCmdPath, $strCmd)){
				throw new Exception($errormsg);
			}
			return $result;
		} else {
			throw new Exception("Non-valid preset was chosen. Transcode aborted.\n");
		}
	}
	
	public function demuxEncodeAudio($inputFilePath, $outputFilePath, $audioChannels = 2, $audioSamplerate = 44100){
		
		//TODO check ffmpeg is able to encode in the format denoted in the output file ffmpeg -formats E
		//TODO check the specified audio channel and samplerate are supported by the codec 
		$preset_demux_encode_audio = $this->ffmpegCmdPath." -y -i %s -ac %d -ar %d %s 2>&1";
		
		$cleanInputPath = escapeshellcmd($inputFilePath);
		$cleanOutputPath = escapeshellcmd($outputFilePath);
		
		if(!is_readable($cleanInputPath) || !is_file($cleanInputPath))
			throw new Exception("You don't have enough permissions to read from the input, or the input is not a file: ".$cleanInputPath."\n");
		if(!is_writable(dirname($cleanOutputPath)))
			throw new Exception("You don't have enough permissions to write to the output: ".$cleanOutputPath."\n");
			
		if(!$this->mediaContainer || !$this->mediaContainer->hash || $this->mediaContainer->hash != md5_file($cleanInputPath)){
			try {
				//This file hasn't been scanned yet
				$this->retrieveMediaInfo($cleanInputPath);
			} catch (Exception $e) {
				throw new Exception($e->getMessage());
			}
		}
		
		if($this->mediaContainer->hasAudio){
			$sysCall = sprintf($preset_demux_encode_audio,$cleanInputPath,$audioChannels,$audioSamplerate,$outputFilePath);
			$result = (exec($sysCall,$output));
			$strCmd = implode($output);
			if($errormsg = $this->system_command_unavailable($this->ffmpegCmdPath, $strCmd)){
				throw new Exception($errormsg);
			}
			return $result;
		} else {
			throw new Exception("The provided file does not have any valid audio streams\n");
		}
		
	}
	
	public function muxEncodeAudio($inputVideoPath, $outputVideoPath, $inputAudioPath){
		$preset = $this->ffmpegCmdPath." -i '%s' -i '%s' -acodec libmp3lame -ab 128 -ac 2 -ar 44100 -map 0:0 -map 1:0 -f flv '%s' 2>&1";
		
		$cleanInputVideoPath = escapeshellcmd($inputVideoPath);
		$cleanOutputVideoPath = escapeshellcmd($outputVideoPath);
		$cleanInputAudioPath = escapeshellcmd($inputAudioPath);
	
		//TODO prepare preset to output the original audio of input1 and another to output silence, maybe use a mapping to /dev/zero or /dev/null
		
		if(!is_readable($cleanInputVideoPath) || !is_file($cleanInputVideoPath) || !is_readable($cleanInputAudioPath) || !is_file($cleanInputAudioPath))
			throw new Exception("You don't have enough permissions to read from the input, or the input is not a file: ".$cleanInputVideoPath.", ".$cleanInputAudioPath."\n");
		if(!is_writable(dirname($cleanOutputVideoPath)))
			throw new Exception("You don't have enough permissions to write to the output: ".$cleanOutputVideoPath."\n");
		
		$sysCall = sprintf($preset, $cleanInputVideoPath, $cleanInputAudioPath, $cleanOutputVideoPath);
		$result = (exec($sysCall,$output));
		$strCmd = implode($output);
		if($errormsg = $this->system_command_unavailable($this->ffmpegCmdPath, $strCmd)){
				throw new Exception($errormsg);
		}
		return $result;
	}
	
	public function audioSubsample($inputFilePath, $outputFilePath, $startTime = 0, $endTime = -1, $volume = -1){
		
		$preset = $this->ffmpegCmdPath." -y -i '%s' -ss '%s'";
		if($endTime>0 && $endTime>$startTime){
			$duration = $endTime - $startTime;
			$preset .= " -t ".$duration;
		}
		//Not sure if ffmpeg sets the int size on the basis of your system's architecture (32bit/64bit) but just in case I set it to 32bit
		if($volume>=0 && $volume<=2600){
			$bin_vol = round($volume*2.56);
			$preset .= " -vol ".$bin_vol;
		}
		$preset .= " '%s' 2>&1";
		
		$cleanInputPath = escapeshellcmd($inputFilePath);
		$cleanOutputPath = escapeshellcmd($outputFilePath);
		
		if(!is_readable($cleanInputPath) || !is_file($cleanInputPath))
			throw new Exception("You don't have enough permissions to read from the input, or the input is not a file: ". $cleanInputPath ."\n");
		if(!is_writable(dirname($cleanOutputPath)))
			throw new Exception("You don't have enough permissions to write to the output: ". $cleanOutputPath."\n");
			
		if(!$this->mediaContainer || !$this->mediaContainer->hash || $this->mediaContainer->hash != md5_file($cleanInputPath)){
			try {
				//This file hasn't been scanned yet
				$this->retrieveMediaInfo($cleanInputPath);
			} catch (Exception $e) {
				throw new Exception($e->getMessage());
			}
		}
		
		if($this->mediaContainer->hasAudio){
			$sysCall = sprintf($preset,$cleanInputPath,$startTime,$outputFilePath);
			$result = (exec($sysCall,$output));
			$strCmd = implode($output);
			if($errormsg = $this->system_command_unavailable($this->ffmpegCmdPath, $strCmd)){
				throw new Exception($errormsg);
			}
			return $result;
		} else {
			throw new Exception("The provided file does not have any valid audio streams\n");
		}
		
	}

	/**
	 * Merges two videos in one. The first input is padded to double its width, then the second video is overlayed in the black space left by the padding.
	 * The original audio is substituted with the provided audio 
	 * 
	 * @param String $inputVideoPath1
	 * 		Absolute path of the video that's going to be padded to double its width
	 * @param String $inputVideoPath2
	 * 		Absolute path of the video that's going to be overlayed to the right of the first input video
	 * @param String $outputVideoPath
	 * 		Absolute path of the reencoded video
	 * @param String $inputAudioPath
	 * 		Absolute path of the audio stream that's going to replace the original audio streams
	 * @param int $width
	 * 		The width of the original input video
	 * @param int $height
	 * 		The height of the original input video
	 * @throws Exception
	 * 		One of the provided paths was unreachable for the script (read/write-wise)
	 */
	public function mergeVideo($inputVideoPath1, $inputVideoPath2, $outputVideoPath, $inputAudioPath = null, $width = 320, $height = 240){
		$cleanInputVideoPath1 = escapeshellcmd($inputVideoPath1);
		$cleanInputVideoPath2 = escapeshellcmd($inputVideoPath2);
		$cleanOutputVideoPath = escapeshellcmd($outputVideoPath);
	
		//TODO prepare preset to output the original audio of input1 and another to output silence, maybe use a mapping to /dev/zero or /dev/null
		
		if($width<8 || $height<8)
			throw new Exception("Specified size is too small\n");
		
		if( !is_readable($cleanInputVideoPath1) || !is_readable($cleanInputVideoPath2) )
			throw new Exception("You don't have enough permissions to read from the input, or the input is not a file: ".$cleanInputVideoPath1 .", ".$cleanInputVideoPath2."\n");
		if( !is_writable(dirname($cleanOutputVideoPath)) )
			throw new Exception("You don't have enough permissions to write to the output: ".$cleanOutputVideoPath."\n");
			
		if($inputAudioPath){
			$cleanAudioPath = escapeshellcmd($inputAudioPath);
			if(!is_readable($cleanAudioPath))
				throw new Exception("You don't have enough permissions to read from the input, or the input is not a file: ".$cleanAudioPath."\n");
		}
		
		
		/**
		  * This preset takes two inputs: the original exercise video and the audio collage
		  * The filters separated by commas between [in] and [out] are the main filter chain
		  * [T0] and [T1] are alternate separated chains. In this script the main chain waits for each alternate chain to finish before it applies the overlay.
		  * After resizing and applying the overlays we encode the input audio to mp3 and exchange the original exercise's audio with the reencoded audio collage
		  * using stream index mapping. -map <input_number>:<stream_index>
		  */
		$preset_merge_videos = $this->ffmpegCmdPath." -y -i '%s' -i '%s' -vf \"[in]settb=1/25,setpts=N/(25*TB),pad=%d:%d:0:0:0x000000, [T1]overlay=W/2:0 [out]; movie='%s':f=flv:si=0,scale=%d:%d,setpts=PTS-STARTPTS[T1]\" -acodec libmp3lame -ab 128 -ac 2 -ar 44100 -map 0:0 -map 1:0 -f flv '%s' 2>&1";
		
		$sysCall = sprintf($preset_merge_videos,$cleanInputVideoPath1, $inputAudioPath, 2*$width, $height, $cleanInputVideoPath2, $width, $height, $cleanOutputVideoPath);
		$result = (exec($sysCall,$output));
		$strCmd = implode($output);
		if($errormsg = $this->system_command_unavailable($this->ffmpegCmdPath, $strCmd)){
				throw new Exception($errormsg);
		}
		return $result;
		
	}
	
	/**
	 * Concatenates the wav files of the provided path that begin with the provided prefix and puts the concatenated wav file
	 * in the provided path. Uses 'sox' to concatenate the files. 
	 * 
	 * @param String $inputPath
	 * 		Absolute path of the audio files
	 * @param String $filePrefix
	 * 		Take into account only the audio files that begin with this prefix
	 * @param String $outputPath
	 * 		Absolute path of the concatenated audio file
	 * @throws Exception
	 * 		None of the provided paths is readable by the script or can't find sox
	 */
	public function concatAudio($inputPath, $filePrefix, $outputPath){
		$cleanInputPath = escapeshellcmd($inputPath);
		$cleanOutputPath = escapeshellcmd($outputPath);
		if(!is_readable($cleanInputPath))
			throw new Exception("You don't have enough permissions to read from the input: ".$cleanInputPath."\n");
		if(!is_writable($cleanOutputPath))
			throw new Exception("You don't have enough permissions to write to the output: ".$cleanOutputPath."\n");
		
		$preset = $this->soxCmdPath." '%s/%s_*' '%s/%scollage.wav' 2>&1";
		$sysCall = sprintf($preset,$cleanInputPath,$filePrefix,$cleanOutputPath,$filePrefix);
		$result = (exec($sysCall, $output));
		$strCmd = implode($output);
		if($errormsg=$this->system_command_unavailable($this->soxCmdPath, $strCmd)){
			throw new Exception($errormsg);
		}
		return $result;
	}
	
	/**
	 * Fixes the Flash Player 11.2.x bug that makes audio-only FLV files non-playable by adding a 8x8px black image for the video stream.
	 * Thus the FLV is no longer audio-only and Flash has no problem with it.
	 * 
	 * @param String $dummyImagePath
	 * 		Absolute path of the 8x8px black image file to make the fake video stream
	 * @param String $inputPath
	 * 		Absolute path of the audio-only FLV that needs to be reencoded
	 * @param String $outputPath
	 * 		Absolute path of the reencoded video & audio FLV file
	 * @return String $result
	 * 		The output of the system call to ffmpeg
	 * @throws Exception
	 * 		None of the provided paths is readable by the script or can't find ffmpeg
	 */
	public function addDummyVideo($dummyImagePath, $inputPath, $outputPath){
		$cleanDummyImagePath = escapeshellcmd($dummyImagePath);
		$cleanInputPath = escapeshellcmd($inputPath);
		$cleanOutputPath = escapeshellcmd($outputPath);
		if(!is_readable($cleanDummyImagePath))
			throw new Exception("You don't have enough permissions to read from the input: ".$cleanDummyImagePath."\n");
		if(!is_readable($cleanInputPath))
			throw new Exception("You don't have enough permissions to read from the input: ".$cleanInputPath."\n");
		//For some reason is_writable returns false on Red5 folders for the www-data user, maybe it's because of the openbasedir directive
		//if(!is_writable($cleanOutputPath))
		//	throw new Exception("You don't have enough permissions to write to the output: ".$cleanOutputPath."\n");
			
		$preset_dummy_video = $this->ffmpegCmdPath." -loop 1 -shortest -y -f image2 -i '%s' -i '%s' -acodec copy -map 0:0 -map 1:1 -f flv '%s' 2>&1";
		$sysCall = sprintf($preset_dummy_video,$cleanDummyImagePath, $cleanInputPath, $cleanOutputPath);
		$result = (exec($sysCall,$output));
		$strCmd = implode($output);
		if($errormsg = $this->system_command_unavailable($this->ffmpegCmdPath, $strCmd)){
				throw new Exception($errormsg);
		}
		return $result;
	}

	/**
	 * Returns a message if the provided command is unavailable and
	 * empty if the command is available
	 * 
	 * @param String $command
	 * 		Relative or full path of the command used for the exec()
	 * @param String $cmdoutput
	 * 		Full output of the exec() function for the command above
	 */
	private function system_command_unavailable($command, $cmdoutput){
		if(strpos($cmdoutput, $command.": not found") !== false)
			return "Command not found: $command\n";
		if(strpos($cmdoutput, $command.": Permission denied") !== false)
			return "Permission denied for command: $command\n";
		return;
	}

	/**
	 * Returns a provided character long random alphanumeric string
	 *
	 * @author Peter Mugane Kionga-Kamau
	 * http://www.pmkmedia.com
	 *
	 * @param int $length
	 * @param boolean $useupper
	 * @param boolean $usenumbers
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
