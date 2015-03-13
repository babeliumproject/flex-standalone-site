<?php


if(!defined('CLI_SERVICE_PATH'))
	define('CLI_SERVICE_PATH', '/var/www/babeliumlms/services');

require_once CLI_SERVICE_PATH . '/utils/Datasource.php';
require_once CLI_SERVICE_PATH . '/utils/Config.php';
require_once CLI_SERVICE_PATH . '/utils/VideoProcessor.php';

//Zend Framework should be on php.ini's include_path
require_once 'Zend/Loader.php';

class VideoCollage{

	private $filePath;
	private $red5Path;

	private $evaluationFolder;
	private $exerciseFolder;
	private $responseFolder;

	private $conn;
	private $mediaHelper;

	public function VideoCollage(){
		$settings = new Config();
		$this->filePath = $settings->filePath;
		$this->imagePath = $settings->imagePath;
		$this->posterPath = $settings->posterPath;
		$this->red5Path = $settings->red5Path;

		$this->conn = new Datasource($settings->host, $settings->db_name, $settings->db_username, $settings->db_password);
		$this->mediaHelper = new VideoProcessor();

		$this->_getResourceDirectories();
	}

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
	
	public function makeResponseCollages(){
		$responsesToMerge = false;
		//Only retrieve the responses made by the users that use the Moodle Babelium plugin
		$sql = "SELECT DISTINCT(r.file_identifier) as responseName 
				FROM response r INNER JOIN user u ON r.fk_user_id=u.ID 
                INNER JOIN moodle_api um ON u.id=um.fk_user_id";
		
		$result = $this->conn->_multipleSelect($sql);
		if($result){
			foreach($result as $r){
					$result = $this->mergeResponseWithExercise($r->responseName);
					if($result)
						$responsesToMerge = true;
			}
			if(!$responsesToMerge)
				echo "\tThere were no responses to merge\n";
		} else {
			echo "\tThere were no responses to merge\n";	
		}
	}

	public function mergeResponseWithExercise($responseName=null){

		if(!$responseName)
			return false;

		$sql = "SELECT r.id, r.fk_exercise_id, r.fk_subtitle_id, r.character_name as chosen_role
                FROM response r INNER JOIN exercise e ON r.fk_exercise_id=e.id INNER JOIN subtitle s ON r.fk_subtitle_id=s.id 
                WHERE file_identifier='%s' AND e.status=1 AND e.visible=1 AND s.complete=1";
        $data = $this->conn->_singleSelect($sql,$responseName);
        if(!$data)
            return false;
        
        require_once CLI_SERVICE_PATH . '/Exercise.php';
        $exerciseSrv = new Exercise();
        $exerciseData = $exerciseSrv->getExerciseMedia($data->fk_exercise_id,2,1);
        
        if(!$exerciseData)
            return false;

        require_once CLI_SERVICE_PATH . '/Subtitle.php';
        $subtitleSrv = new Subtitle();
        $params = new stdClass();
        $params->id = $data->fk_subtitle_id;
        $exerciseSubtitles = $subtitleSrv->getSubtitleLines($params);
        
        if(!$exerciseSubtitles)
            return false;

        $exerciseFilename = $exerciseData[0]->filename;
        $responseFilename = $responseName.'.flv';
        $eventPoints = $this->sort_list_by_field($exerciseSubtitles,'showTime',SORT_NUMERIC);
        $chosenRole = $data->chosen_role; 

        $exercisePath = $this->red5Path.'/'.$this->exerciseFolder.'/'.$exerciseFilename;
        $responsePath = $this->red5Path.'/'.$this->responseFolder.'/'.$responseFilename;
        $tmpFolder = $this->filePath.'/'.$responseName;	

        try {
            if(file_exists($this->red5Path.'/'.$this->responseFolder.'/'.$responseName.'_merge.flv')){
                //echo "Response ".$responseName.".flv is already merged\n";
                return false;
            }

            echo "\nMerging ".$responseName.".flv with it's exercise\n";

            //Make a folder to store the temporary files
            $this->makeTempFolder($tmpFolder);

            $collagePath = $this->createAudioCollage($exercisePath,$responsePath,$tmpFolder,$eventPoints,$chosenRole);	

            //Check if the response has a video stream or not
            $responseInfo = $this->mediaHelper->retrieveMediaInfo($responsePath);
            if(isset($responseInfo->hasVideo) && $responseInfo->hasVideo){
                //Pad the exercise video and add the response video as an overlay.
                //Also replace the original audio with the audio collage
                $this->mediaHelper->mergeVideo(
                        $exercisePath, 
                        $responsePath, 
                        $this->red5Path.'/'.$this->responseFolder.'/'.$responseName.'_merge.flv', 
                        $collagePath,
                        360);
            } else {
                $this->mediaHelper->muxEncodeAudio(
                        $exercisePath, 
                        $this->red5Path.'/'.$this->responseFolder.'/'.$responseName.'_merge.flv', 
                        $collagePath
                        );
            }
            //print_r($r."\n");

            //Delete the temporary resources
            $this->removeTempFolder($tmpFolder);
            return true;
        } catch (Exception $e){
            //The workflow failed at some point. Remove the files created up until that point.
            $this->removeTempFolder($tmpFolder);
            echo $e->getMessage();
            return false;
        }
    }

    public function createAudioCollage($exercisepath,$responsepath,$outputdir,$eventpoints,$chosenrole){
        if(!$exercisepath || !$responsepath || !$outputdir || !$eventpoints || !$chosenrole)
            throw new Exception("Invalid or missing parameters",1000);
        if(!is_array($eventpoints) || !count($eventpoints))
            throw new Exception("Eventpoints is not an array or is empty",1001);
        
        try{

            $exercise_path_parts = pathinfo($exercisepath);
            $response_path_parts = pathinfo($responsepath);

            //Extract exercise audio
            $this->mediaHelper->demuxEncodeAudio($exercisepath, $outputdir.'/'.$exercise_path_parts['filename'].'.wav');

            //Extract response audio
            $this->mediaHelper->demuxEncodeAudio($responsepath, $outputdir.'/'.$response_path_parts['filename'].'.wav');

            $split_times = array();

            //First split
            $t = new stdClass();
            $t->start = 0;
            $t->end = $eventpoints[0]->showTime;
            $t->volume = -1;
            if(($t->end - $t->start) > 0)
                $split_times[] = $t;

            for($i=0;$i<count($eventpoints);$i++){
                //Gaps with subtitles
                $t = new stdClass();
                $t->start = $eventpoints[$i]->showTime;
                $t->end = $eventpoints[$i]->hideTime;
                $t->volume = ($chosenrole == $eventpoints[$i]->exerciseRoleName) ? 0 : -1;
                if(($t->end - $t->start) > 0)
                    $split_times[] = $t;

                //Gaps without subtitles
                if($i<(count($eventpoints)-1)){
                    $t = new stdClass();
                    $t->start = $eventpoints[$i]->hideTime;
                    $t->end = $eventpoints[$i+1]->showTime;
                    $t->volume = -1;
                    if(($t->end - $t->start) > 0)
                        $split_times[] = $t;
                }
            }

            //Last split
            $t = new stdClass();
            $t->start = $eventpoints[count($eventpoints)-1]->hideTime;
            $t->end =  -1;
            $t->volume = -1;
            //if(($t->end - $t->start) > 0)
            $split_times[] = $t;

            //Make audio subsamples following the subtitle times
            for($i=0;$i<count($split_times);$i++){
                $outputPath = sprintf("%s/%s_%02d.wav",$outputdir,$exercise_path_parts['filename'],$i);
                if($split_times[$i]->volume == 0) {
                    $this->mediaHelper->audioSubsample(
                            $outputdir.'/'.$response_path_parts['filename'].'.wav',
                            $outputPath, 
                            $split_times[$i]->start, 
                            $split_times[$i]->end, 
                            -1 //Use 800 in this parameter to boost the audio volume
                    );
                } else {
                    $this->mediaHelper->audioSubsample(
                            $outputdir.'/'.$exercise_path_parts['filename'].'.wav',
                            $outputPath,
                            $split_times[$i]->start,
                            $split_times[$i]->end,
                            -1
                    );
                }
            }

            //Concat the modified audio pieces to get the original audio duration
            $this->mediaHelper->concatAudio($outputdir,$exercise_path_parts['filename'],$outputdir);
            return $outputdir.'/'.$exercise_path_parts['filename'].'collage.wav';

        } catch (Exception $e){
            throw new Exception($e->getMessage(),$e->getCode());
        }
    }
	
	private function sort_list_by_field($list, $field, $type=SORT_STRING, $order=SORT_ASC){
		if (!$list || !$field || !is_array($list)) return;
		if (!in_array($order,array(SORT_ASC,SORT_DESC)) || !in_array($type,array(SORT_REGULAR,SORT_NUMERIC,SORT_STRING,SORT_LOCALE_STRING))) return;
		$sortedList = $list;
		$sortingArray = array();
		foreach($sortedList as $listItem){
			foreach($listItem as $key=>$value){
				if(!isset($sortingArray[$key])){
					$sortingArray[$key] = array();
				}
				//Force the lowercase conversion of the values to perform a case insensitive sorting
				$sortingArray[$key][] = mb_strtolower($value,'UTF-8');
			}
		}
		array_multisort($sortingArray[$field], $order, $type, $sortedList);
		return $sortedList;
	}

	private function makeTempFolder($tmpFolder){
		if(!file_exists($tmpFolder)){
			if(!mkdir($tmpFolder))
				echo "Couldn't create the folder: ".$tmpFolder."\n";
		} else {
			echo "Folder already exists: ".$tmpFolder."\n";
		}
	}

	private function removeTempFolder($tmpFolder){
		if(is_dir($tmpFolder)){
			$folder = dir($tmpFolder);
			while (false !== ($entry = $folder->read())) {
				$entryFullPath = $tmpFolder.'/'.$entry;
				if(!is_dir($entryFullPath)){
					if(!unlink($entryFullPath))
					echo "Error while removing temp file: ".$entryFullPath."\n";
				}
			}
			$folder->close();
			if(!rmdir($tmpFolder))
				echo "Error while removing temp folder: ".$tmpFolder."\n";
		}
	}
}
