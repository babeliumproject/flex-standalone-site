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
define('WEBROOT_PATH', '/var/www/babeliumlms');

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

    private $fileCmdPath;
    private $soxCmdPath;

    private $mediaToolSuite;
    private $mediaToolHome;

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

        $this->mediaToolHome = $this->checkDirectory($settings->mediaToolHome);
        $this->mediaToolSuite = $settings->mediaToolSuite;

        $this->fileCmdPath = $settings->fileCmdPath ? $settings->fileCmdPath : 'file';
        $this->soxCmdPath = $settings->soxCmdPath ? $settings->soxCmdPath : 'sox';

        $this->encodingPresets[] = "-y -v error -i '%s' -s %dx%d -g 25 -qmin 3 -b 512k -acodec libmp3lame -ar 22050 -ac 2 -f flv '%s'";
        $this->encodingPresets[] = "-y -v error -i '%s' -s %dx%d -g 25 -qmin 3 -acodec libmp3lame -ar 22050 -ac 2 -f flv '%s'";
        $this->encodingPresets[] = "-y -v error -i '%s' -strict experimental -codec:v libx264 -profile:v main -preset slow -b:v 250k -maxrate 250k -bufsize 500k -r 24 -g 24 -vf scale=%d:%d -codec:a aac -b:a 96k -ac 2 -ar 22050 '%s'";
    }

    /**
     * Tests if the system command execution was successful or not.
     *
     * @param String $cmd
     *      A String with the command to pass to the system's shell
     * @param bool $captureStderr
     *      Determines whether stderr should be redirected to stdout or not
     * @return Array
     *      The output of the command in a line by line array
     * @throws Exception
     *      The reason why the command call was not successful
     */
    private function execWrapper($cmd, $captureStderr=true){
        if(!$cmd || !is_string($cmd) || empty($cmd))
            throw new Exception("Command is not a string or is empty");
        $ccmd = $cmd;
        if($captureStderr)
            $ccmd = $cmd.' 2>&1';
        $lastline = exec($ccmd,$output,$ret_val);
        switch($ret_val){
            case 0:
                return $output;
            case 126:
                throw new Exception("Permission denied: $cmd");
                break;
            case 127:
                throw new Exception("Command not found: $cmd");
                break;
            case 1:
            default:
                throw new Exception("Command error [$ret_val]: $cmd (".implode($output).")");
                break;
        }
    }

    private function checkDirectory($path){
        if(!$path || empty($path))
            return NULL;
        $cpath = escapeshellcmd($path);
        if(is_readable($cpath) && is_dir($cpath)){
            $rpath = realpath($cpath);
            return $rpath ? rtrim($rpath,'/').'/' : NULL;
        }
        return NULL;
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
            $cmd_name = $this->mediaToolHome;
            $cmd_name .= $this->mediaToolSuite == Config::FFMPEG ? 'ffprobe' : 'avprobe';
            $cmd_options = '-of json -show_streams -show_format -v quiet';
            $cmd_input = $cleanPath;
            $cmd = sprintf($cmd_template,$cmd_name,$cmd_options,$cmd_input);

            $output = $this->execWrapper($cmd, false);

            //Convert output array to a single string
            $str_output = preg_replace('/\s{2,}/', ' ', implode($output));
            $json_output = json_decode($str_output);

            //The output object should have 'format' and 'streams' properties
            if($json_output && isset($json_output->format) && isset($json_output->streams)){
                $this->mediaContainer = new stdClass();

                //Get file content hash to look for duplicates
                $this->mediaContainer->hash = sha1_file($cleanPath);

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
            throw new Exception("File does not exist or is not readable: $cleanPath");
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
            $cmd_template = "%s %s";
            $cmd_name = $this->fileCmdPath;
            $cmd_options_t = "-bi '%s'";
            $cmd_options = sprintf($cmd_options_t, $cleanPath);

            $cmd = sprintf($cmd_template,$cmd_name,$cmd_options);

            $output = $this->execWrapper($cmd);
            $str_output = preg_replace('/\s{2,}/',' ',implode($output));

            $fileMimeInfo = explode($str_output, ";");
            $fileMimeType = $fileMimeInfo[0];
            $validMime = false;
            if(strpos($str_output,$mimeCategory) !== false){
                $validMime = true;
            }
            return $validMime;
        } else {
            throw new Exception("File does not exist or is not readable: $cleanPath");
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
            $this->mediaContainer->audioBits = isset($streamdata->sample_fmt) ? $streamdata->sample_fmt : 0;
            $this->mediaContainer->audioBitrate = isset($streamdata->bit_rate) ? $streamdata->bit_rate : 0;
        }
    }

    private function retrieveVideoInfo($streamdata){
        if($streamdata->codec_type == 'video'){
            $this->mediaContainer->videoCodec = $streamdata->codec_name;
            $this->mediaContainer->videoColorspace = $streamdata->pix_fmt;
            $this->mediaContainer->videoTbr = isset($streamdata->r_frame_rate) ? $streamdata->r_frame_rate : 0;
            $this->mediaContainer->videoTbn = $streamdata->time_base;
            $this->mediaContainer->videoTbc = $streamdata->codec_time_base;
            $this->mediaContainer->videoBitrate= isset($streamdata->bit_rate) ? $streamdata->bit_rate : 0; //expressed in bits per second

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
        if(!$this->mediaContainer || !$this->mediaContainer->hash || ($this->mediaContainer->hash != sha1_file($cleanPath)) ){
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

        $cmd_template = "%s %s";
        $cmd_name = $this->mediaToolHome;
        $cmd_name .= $this->mediaToolSuite == Config::FFMPEG ? 'ffmpeg' : 'avconv';
        $cmd_options_t = "-y -v error -i '%s' -ss %d -vframes 1 -r 1 -s %dx%d '%s'";
        $cmd_options = sprintf($cmd_options_t, $cleanPath, $second, $snapshotWidth, $snapshotHeight, $cleanImagePath);

        $cmd = sprintf($cmd_template,$cmd_name,$cmd_options);

        $output = $this->execWrapper($cmd);
    }

    /**
     * Takes various images from the provided video and creates a folder to store them. Checks if the provided paths
     * are readable/writable and if needed retrieves the info of the provided video file.
     *
     * @param string $filePath
     * @param string $outputImagePath
     * @throws Exception
     */
    public function takeFolderedRandomSnapshots($filePath, $thumbdir, $posterdir, $thumbnailWidth = 120, $thumbnailHeight = 90, $snapshotCount = 3){
        $cleanVideoPath = escapeshellcmd($filePath);
        $sanitizedThumbdir = escapeshellcmd($thumbdir);
        $sanitizedPosterdir = escapeshellcmd($posterdir);

        if( !is_file($cleanVideoPath) )
            throw new Exception("Value is not a file or cannot be read: ".$cleanVideoPath."\n");
        if(!$this->mediaContainer || !$this->mediaContainer->hash || ($this->mediaContainer->hash != sha1_file($cleanVideoPath)) ){
            try {
                $this->retrieveMediaInfo($cleanVideoPath);
            } catch (Exception $e) {
                throw new Exception($e->getMessage());
            }
        }

        if($this->mediaContainer->hasVideo){

            if(!is_dir($sanitizedThumbdir)){
                if(!mkdir($sanitizedThumbdir)){
                    throw new Exception("Cannot create directory: $sanitizedThumbdir\n");
                }
            }
            if(!is_dir($sanitizedThumbdir) || !is_writable($sanitizedThumbdir)){
                throw new Exception("Cannot write in directory: $sanitizedThumbdir\n");
            }

            if(!is_dir($sanitizedPosterdir)){
                if(!mkdir($sanitizedPosterdir)){
                    throw new Exception("Cannot create directory: $sanitizedPosterdir\n");
                }
            }
            if(!is_dir($sanitizedPosterdir) || !is_writable($sanitizedPosterdir)){
                throw new Exception("Cannot write in directory: $sanitizedPosterdir\n");
            }

            //Default thumbnail time
            $second = 1;
            $lastSecond = 1;
            for($i=0; $i<$snapshotCount; $i++){

                //Random time between 1 and videoDuration-1
                $second = rand(1, ($this->mediaContainer->duration - 1));
                $lastSecond = $second !== $lastSecond ? $second : rand(1, ($this->mediaContainer->duration -1));

                $toPath = $sanitizedThumbdir . '/' . sprintf('%02d.jpg',$i+1);
                $poPath = $sanitizedPosterdir . '/' . sprintf('%02d.jpg',$i+1);
                if(!is_file($toPath)){
                    $cmd_template = "%s %s";
                    $cmd_name = $this->mediaToolHome;
                    $cmd_name .= $this->mediaToolSuite == Config::FFMPEG ? 'ffmpeg' : 'avconv';
                    $cmd_options_t = "-y -v error -i '%s' -ss %d -vframes 1 -r 1 -s %dx%d '%s'";
                    $cmd_options = sprintf($cmd_options_t, $cleanVideoPath, $lastSecond, $thumbnailWidth, $thumbnailHeight, $toPath);

                    $cmd = sprintf($cmd_template,$cmd_name,$cmd_options);

                    $output = $this->execWrapper($cmd);
                }
                if(!is_file($poPath)){
                    $cmd_template = "%s %s";
                    $cmd_name = $this->mediaToolHome;
                    $cmd_name .= $this->mediaToolSuite == Config::FFMPEG ? 'ffmpeg' : 'avconv';
                    $cmd_options_t = "-y -v error -i '%s' -ss %d -vframes 1 -r 1 '%s'";
                    $cmd_options = sprintf($cmd_options_t, $cleanVideoPath, $lastSecond, $poPath);

                    $cmd = sprintf($cmd_template,$cmd_name,$cmd_options);

                    $output = $this->execWrapper($cmd);
                }
            }

            $tdef = $sanitizedThumbdir.'/default.jpg';
            $pdef = $sanitizedPosterdir.'/default.jpg';
            $tone = $sanitizedThumbdir.'/01.jpg';
            $pone = $sanitizedPosterdir.'/01.jpg';
            //if (is_link($tdef)) unlink($tdef);
            //if (is_link($pdef)) unlink($pdef);
            
            //if(!symlink($tone, $tdef)){
            //    throw new Exception ("Cannot make a link $tdef for $tone\n");
            //}
            //if(!symlink($pone, $pdef)){
            //    throw new Exception ("Cannot make a link $pdef for $pone\n");
            //}
        }
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
    public function transcodeToFlv($inputFilepath, $outputFilepath, $preset = 1, $dimension = 240){
        $cleanInputPath = escapeshellcmd($inputFilepath);
        $cleanOutputPath = escapeshellcmd($outputFilepath);

        if(!is_readable($cleanInputPath))
            throw new Exception("You don't have enough permissions to read from the input: ".$cleanInputPath."\n");
        if(!is_writable(dirname($cleanOutputPath)))
            throw new Exception("You don't have enough permissions to write to the output: ".$cleanOutputPath."\n");

        if(!$this->mediaContainer || !$this->mediaContainer->hash || $this->mediaContainer->hash != sha1_file($cleanInputPath)){
            try {
                //This file hasn't been scanned yet
                $this->retrieveMediaInfo($cleanInputPath);
            } catch (Exception $e) {
                throw new Exception($e->getMessage());
            }
        }

        if ($this->mediaContainer->suggestedTranscodingAspectRatio == 43){
        	$width = floor($dimension*(4/3));
        } else {
        	$width = floor($dimension*(16/9));
        }
        $height = $dimension;

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
            $cmd_template = "%s %s";
            $cmd_name = $this->mediaToolHome;
            $cmd_name .= $this->mediaToolSuite == Config::FFMPEG ? 'ffmpeg' : 'avconv';
            $cmd_options_t = $this->encodingPresets[$preset];
            $cmd_options = sprintf($cmd_options_t, $cleanInputPath, $width, $height, $cleanOutputPath);

            $cmd = sprintf($cmd_template,$cmd_name,$cmd_options);

            $output = $this->execWrapper($cmd);

        } else {
            throw new Exception("Non-valid preset was chosen. Transcode aborted.\n");
        }
    }

    public function demuxEncodeAudio($inputFilePath, $outputFilePath, $audioChannels = 2, $audioSamplerate = 44100){

        //TODO check ffmpeg is able to encode in the format denoted in the output file ffmpeg -formats E
        //TODO check the specified audio channel and samplerate are supported by the codec 
        $preset_demux_encode_audio = " -y -v error -i '%s' -ac %d -ar %d '%s'";

        $cleanInputPath = escapeshellcmd($inputFilePath);
        $cleanOutputPath = escapeshellcmd($outputFilePath);

        if(!is_readable($cleanInputPath) || !is_file($cleanInputPath))
            throw new Exception("You don't have enough permissions to read from the input, or the input is not a file: ".$cleanInputPath."\n");
        if(!is_writable(dirname($cleanOutputPath)))
            throw new Exception("You don't have enough permissions to write to the output: ".$cleanOutputPath."\n");

        if(!$this->mediaContainer || !$this->mediaContainer->hash || $this->mediaContainer->hash != sha1_file($cleanInputPath)){
            try {
                //This file hasn't been scanned yet
                $this->retrieveMediaInfo($cleanInputPath);
            } catch (Exception $e) {
                throw new Exception($e->getMessage());
            }
        }

        if($this->mediaContainer->hasAudio){
            $cmd_template = "%s %s";
            $cmd_name = $this->mediaToolHome;
            $cmd_name .= $this->mediaToolSuite == Config::FFMPEG ? 'ffmpeg' : 'avconv';
            $cmd_options_t = $preset_demux_encode_audio;
            $cmd_options = sprintf($cmd_options_t, $cleanInputPath, $audioChannels, $audioSamplerate, $outputFilePath);
            $cmd = sprintf($cmd_template,$cmd_name,$cmd_options);
            $output = $this->execWrapper($cmd);

            //Consider returning TRUE to caller
        } else {
            throw new Exception("The provided file does not have any valid audio streams\n");
        }

    }

    public function muxEncodeAudio($inputVideoPath, $outputVideoPath, $inputAudioPath){
        $preset = " -v error -i '%s' -i '%s' -acodec libmp3lame -ab 128 -ac 2 -ar 44100 -map 0:0 -map 1:0 -f flv '%s'";

        $cleanInputVideoPath = escapeshellcmd($inputVideoPath);
        $cleanOutputVideoPath = escapeshellcmd($outputVideoPath);
        $cleanInputAudioPath = escapeshellcmd($inputAudioPath);

        //TODO prepare preset to output the original audio of input1 and another to output silence, maybe use a mapping to /dev/zero or /dev/null

        if(!is_readable($cleanInputVideoPath) || !is_file($cleanInputVideoPath) || !is_readable($cleanInputAudioPath) || !is_file($cleanInputAudioPath))
            throw new Exception("You don't have enough permissions to read from the input, or the input is not a file: ".$cleanInputVideoPath.", ".$cleanInputAudioPath."\n");
        if(!is_writable(dirname($cleanOutputVideoPath)))
            throw new Exception("You don't have enough permissions to write to the output: ".$cleanOutputVideoPath."\n");

        $cmd_template = "%s %s";
        $cmd_name = $this->mediaToolHome;
        $cmd_name .= $this->mediaToolSuite == Config::FFMPEG ? 'ffmpeg' : 'avconv';
        $cmd_options_t = $preset;
        $cmd_options = sprintf($cmd_options_t, $cleanInputVideoPath, $cleanInputAudioPath, $cleanOutputVideoPath);

        $cmd = sprintf($cmd_template,$cmd_name,$cmd_options);

        $output = $this->execWrapper($cmd);

        //Consider returning TRUE to caller
    }

    public function audioSubsample($inputFilePath, $outputFilePath, $startTime = 0, $endTime = -1, $volume = -1){

        $preset = "-y -v error -i '%s' -ss '%s'";
        if($endTime>0 && $endTime>$startTime){
            $duration = $endTime - $startTime;
            $preset .= " -t ".$duration;
        }
        //Not sure if ffmpeg sets the int size on the basis of your system's architecture (32bit/64bit) but just in case I set it to 32bit
        if($volume>=0 && $volume<=2600){
            $bin_vol = round($volume*2.56);
            $preset .= " -vol ".$bin_vol;
        }
        $preset .= " '%s'";

        $cleanInputPath = escapeshellcmd($inputFilePath);
        $cleanOutputPath = escapeshellcmd($outputFilePath);

        if(!is_readable($cleanInputPath) || !is_file($cleanInputPath))
            throw new Exception("You don't have enough permissions to read from the input, or the input is not a file: ". $cleanInputPath ."\n");
        if(!is_writable(dirname($cleanOutputPath)))
            throw new Exception("You don't have enough permissions to write to the output: ". $cleanOutputPath."\n");

        if(!$this->mediaContainer || !$this->mediaContainer->hash || $this->mediaContainer->hash != sha1_file($cleanInputPath)){
            try {
                //This file hasn't been scanned yet
                $this->retrieveMediaInfo($cleanInputPath);
            } catch (Exception $e) {
                throw new Exception($e->getMessage());
            }
        }

        if($this->mediaContainer->hasAudio){
            $cmd_template = "%s %s";
            $cmd_name = $this->mediaToolHome;
            $cmd_name .= $this->mediaToolSuite == Config::FFMPEG ? 'ffmpeg' : 'avconv';
            $cmd_options_t = $preset;
            $cmd_options = sprintf($cmd_options_t, $cleanInputPath, $startTime, $outputFilePath);

            $cmd = sprintf($cmd_template,$cmd_name,$cmd_options);

            $output = $this->execWrapper($cmd);

            //Consider returning TRUE to caller
        } else {
            throw new Exception("The provided file does not have any valid audio streams\n");
        }

    }
    
    /**
     * Extracts an audio sample from the two given inputs and mixes the two samples in one
     * 
     * @param String $input1
     * @param String $input2
     * @param String $output
     * @param int $starttime
     * @param int $endtime
     * @param String $cutoff
     */
    public function audioSubsampleMix($input1, $input2, $output, $starttime = 0, $endtime = 0, $cutoff='first'){
    	
    	$cutoff_values = array('longest','shortest','first');  	 
    	
    	//Make two temp outputs for the subsamples
    	$otmp1 = rtrim($output,'.wav').'_a.wav';
    	$otmp2 = rtrim($output,'.wav').'_b.wav';
    	
    	$internalcutoff = in_array($cutoff, $cutoff_values) ? $cutoff : 'first';
    	
    	$this->audioSubsample($input1, $otmp1,$starttime,$endtime);
    	$this->audioSubsample($input2, $otmp2,$starttime,$endtime);
    	
    	$preset = "-y -v error -i '%s' -i '%s' -filter_complex amix=inputs=2:duration=%s:dropout_transition=0 '%s'";
    	
    	$cmd_template = "%s %s";
    	$cmd_name = $this->mediaToolHome;
        $cmd_name .= $this->mediaToolSuite == Config::FFMPEG ? 'ffmpeg' : 'avconv';
        $cmd_options_t = "-y -v error -i '%s' -i '%s' -filter_complex amix=inputs=2:duration=%s:dropout_transition=3 '%s'";
        $cmd_options = sprintf($cmd_options_t, $otmp1, $otmp2, $internalcutoff, $output);
        
        $cmd = sprintf($cmd_template,$cmd_name,$cmd_options);
        
        $rc = $this->execWrapper($cmd);
        
        //If exec was successful remove the temp files
        @unlink($otmp1);
        @unlink($otmp2);
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
    public function mergeVideo($inputVideoPath1, $inputVideoPath2, $outputVideoPath, $inputAudioPath = null, $dimension=240){
        $cleanInputVideoPath1 = escapeshellcmd($inputVideoPath1);
        $cleanInputVideoPath2 = escapeshellcmd($inputVideoPath2);
        $cleanOutputVideoPath = escapeshellcmd($outputVideoPath);

        //TODO prepare preset to output the original audio of input1 and another to output silence, maybe use a mapping to /dev/zero or /dev/null

        if($dimension<Config::LEVEL_240P)
            throw new Exception("Specified dimension is too small\n");

        if( !is_readable($cleanInputVideoPath1) || !is_readable($cleanInputVideoPath2) )
            throw new Exception("You don't have enough permissions to read from the input, or the input is not a file: ".$cleanInputVideoPath1 .", ".$cleanInputVideoPath2."\n");
        if( !is_writable(dirname($cleanOutputVideoPath)) )
            throw new Exception("You don't have enough permissions to write to the output: ".$cleanOutputVideoPath."\n");

        if($inputAudioPath){
            $cleanAudioPath = escapeshellcmd($inputAudioPath);
            if(!is_readable($cleanAudioPath))
                throw new Exception("You don't have enough permissions to read from the input, or the input is not a file: ".$cleanAudioPath."\n");
        }

        //Total dimensions
        $twidth = floor($dimension*(16/9));
        $theight = $dimension;
        
        //Dimensions of left-side video
        $lmedia = $this->retrieveMediaInfo($cleanInputVideoPath1);
        $lwidth = floor($twidth/2);
        $lheight = $lmedia->suggestedTranscodingAspectRatio==169 ? round(($lwidth/16)*9) : round(($lwidth/4)*3);
        $lpaddingy = floor(($theight/2)-($lheight/2));
        
        //Dimensions of right-side video
        $rmedia = $this->retrieveMediaInfo($cleanInputVideoPath2);
        $rwidth = floor($twidth/2);
        $rheight = $rmedia->suggestedTranscodingAspectRatio==169 ? round(($rwidth/16)*9) : round(($rwidth/4)*3);
        $rpaddingy = floor(($theight/2)-($rheight/2));
        
        $t_cmd_options = "%s %s %s %s %s %s";
        $t_input_files="-i '%s' -i '%s' -i '%s'";
        $t_filters_avconv="-filter_complex \"[0:v] setpts=PTS-STARTPTS, scale=%d:%d [left]; [1:v] setpts=PTS-STARTPTS, scale=%d:%d [right]; [left] pad=%d:%d:0:%d [padded]; [padded][right] overlay=%d:%d\"";
        $t_filters_ffmpeg="-filter_complex \"nullsrc=size=%dx%d [background]; [0:v] setpts=PTS-STARTPTS, scale=%dx%d [left]; [1:v] setpts=PTS-STARTPTS, scale=%dx%d [right]; [background][left] overlay=shortest=1:y=%d [background+left]; [background+left][right] overlay=shortest=1:x=%d:y=%d [left+right]\""; 
        $t_output_files="'%s'";
        
        $cmd_overwrite_verbose="-y -v fatal";
        $cmd_input_files = sprintf($t_input_files, $cleanInputVideoPath1, $cleanInputVideoPath2, $cleanAudioPath);
        
        if($this->mediaToolSuite == Config::FFMPEG){
        	$cmd_filters = sprintf($t_filters_ffmpeg, $twidth, $theight, $lwidth, $lheight, $rwidth, $rheight, $lpaddingy, $lwidth, $rpaddingy);
        } else { //avconv
        	$cmd_filters = sprintf($t_filters_avconv, $lwidth, $lheight, $rwidth, $rheight, $twidth, $theight, $lpaddingy, $lwidth, $rpaddingy);
        }

        $cmd_output_encoding="-strict experimental -codec:v libx264 -profile:v main -level 31 -preset slow -b:v 250k -bufsize 500k -r 24 -g 24 -keyint_min 24 -codec:a aac -b:a 96k -ac 2 -ar 22050";
        $cmd_output_mapping="-map 2:0";
        
        $cmd_output_files = sprintf($t_output_files, $cleanOutputVideoPath);

        
        $cmd_template = "%s %s";
        $cmd_name = $this->mediaToolHome;
        $cmd_name .= $this->mediaToolSuite == Config::FFMPEG ? 'ffmpeg' : 'avconv';
      
        $cmd_options = sprintf($t_cmd_options, $cmd_overwrite_verbose, $cmd_input_files, $cmd_filters, $cmd_output_encoding, $cmd_output_mapping, $cmd_output_files);

        $cmd = sprintf($cmd_template,$cmd_name,$cmd_options);

        $output = $this->execWrapper($cmd);

        //Consider returning TRUE to caller
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

        $cmd_template = "%s %s";
        $cmd_name = $this->soxCmdPath;
        $cmd_options_t = "'%s/%s_*' '%s/%scollage.wav'";
        $cmd_options = sprintf($cmd_options_t, $cleanInputPath, $filePrefix, $cleanOutputPath, $filePrefix);

        $cmd = sprintf($cmd_template,$cmd_name,$cmd_options);

        $output = $this->execWrapper($cmd);

        //Consider returning TRUE to caller
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


        $cmd_template = "%s %s";
        $cmd_name = $this->mediaToolHome;
        $cmd_name .= $this->mediaToolSuite == Config::FFMPEG ? 'ffmpeg' : 'avconv';
        $cmd_options_t = "-loop 1 -shortest -y -f image2 -i '%s' -i '%s' -acodec copy -map 0:0 -map 1:1 -f flv '%s'";
        $cmd_options = sprintf($cmd_options_t, $cleanDummyImagePath, $cleanInputPath, $cleanOutputPath);

        $cmd = sprintf($cmd_template,$cmd_name,$cmd_options);

        $output = $this->execWrapper($cmd);

        //Consider returning TRUE to caller
    }
    
    /**
     * Encode the given array using Json
     *
     * @param Array $data
     * @param bool $prettyprint
     * @return mixed $data
     */
    public function custom_json_encode($data, $prettyprint=0){
    	require_once 'Zend/Json.php';
    	$data = Zend_Json::encode($data,false);
    	$data = preg_replace_callback('/\\\\u([0-9a-f]{4})/i', create_function('$match', 'return mb_convert_encoding(pack("H*", $match[1]), "UTF-8", "UCS-2BE");'), $data);
    	if($prettyprint)
    		$data = Zend_Json::prettyPrint($data);
    	return $data;
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
