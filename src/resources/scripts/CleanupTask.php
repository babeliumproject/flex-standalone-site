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

define('CLI_SERVICE_PATH', '/var/www/babeliumlms/services');

require_once CLI_SERVICE_PATH . '/utils/Datasource.php';
require_once CLI_SERVICE_PATH . '/utils/Config.php';


/**
 * This class should be only launched by CRON tasks, therefore it should be placed outside the web scope
 *
 * @author Babelium Team
 */
class CleanupTask{

	private $db;
	private $filePath;
	private $red5Path;

	private $exerciseFolder = '';
	private $responseFolder = '';
	private $evaluationFolder = '';
	private $configFolder = 'config';

    const STATUS_DRAFT=0;
    const STATUS_READY=1;

	/**
	 * Constructor function
	 * 
	 * @throws Exception
	 * 		Throws an error if there was any problem establishing a connection with the database.
	 */
	public function CleanupTask(){
		$cfg = new Config ( );
		$this->filePath = $cfg->filePath;
		$this->red5Path = $cfg->red5Path;
		$this->db = new Datasource ( $cfg->host, $cfg->db_name, $cfg->db_username, $cfg->db_password );
		
		$this->_getResourceDirectories();
	}

	/**
	 * Moves all the media files that are not referenced in some way in the database to an alternative location so that
	 * we can keep track of them easier and delete them if we run out space in the server.
	 */
	public function deleteAllUnreferenced(){
		$this->_deleteUnreferencedExercises();
		$this->_deleteUnreferencedResponses();
		$this->_deleteUnreferencedEvaluations();
		$this->_deleteConfigs();
	}

	/**
	 * Searches the database for users who haven't activated their account in the specified day interval
	 * and deletes them to free usernames/emails that are not used
	 * 
	 * @param int $days
	 * 		Elapsed day interval from current date
	 */
	public function deleteInactiveUsers($days){
		if($days<7)
			return;
		else{
			$sql = "DELETE FROM user
					WHERE (DATE_SUB(CURDATE(),INTERVAL '%d' DAY) > joiningDate AND active = 0 AND activation_hash <> '')";
			$result = $this->db->_delete($sql,$days);
		}
	}

	/**
	 * Searches the database for videos that received user complaints (copyrighted material, violence...) and if they
	 * meet the requied amount of complaints deletes them
	 */
	public function deactivateReportedVideos(){

		$sql = "SELECT prefValue FROM preferences WHERE (prefName='reports_to_delete')";
		$result = $this->db->_singleSelect($sql);
		if ($result){
			$reportsToDeletion = $result->prefValue;

			$sql = "UPDATE exercise AS E SET status=%d
		       	    WHERE '%d' <= (SELECT count(*) 
		        		           FROM exercise_report WHERE fk_exercise_id=E.id ) ";
			return $this->db->_update($sql, self::STATUS_DRAFT, $reportsToDeletion);
		}
	}
	
	/**
	 * Checks if an user is still browsing the website monitoring the activity periodically
	 */
	public function monitorizeSessionKeepAlive(){
		$sql = "UPDATE user_session SET duration = TIMESTAMPDIFF(SECOND,session_date,CURRENT_TIMESTAMP), closed=1
				WHERE (keep_alive = 0 AND closed=0 AND duration=0)";

		$result = $this->db->_update($sql);

		$sql = "UPDATE user_session SET keep_alive = 0
				WHERE (keep_alive = 1 AND closed = 0)";

		$result = $this->db->_update($sql);
	}
	
	/**
	 * Retrieves the directory names of several media resources
	 */	
	private function _getResourceDirectories(){
		$sql = "SELECT prefValue 
				FROM preferences
				WHERE (prefName='exerciseFolder' OR prefName='responseFolder' OR prefName='evaluationFolder') 
				ORDER BY prefName";
		$result = $this->db->_multipleSelect($sql);
		if($result){
			$this->evaluationFolder = $result[0] ? $result[0]->prefValue : '';
			$this->exerciseFolder = $result[1] ? $result[1]->prefValue : '';
			$this->responseFolder = $result[2] ? $result[2]->prefValue : '';
		}
	}

    private function _deleteUnreferencedMedia(){
        $this->_deleteUnreferencedExercises();
    }

	/**
	 * Deletes the files under <RED5_APP_PATH>/streams/exercises that are not referenced in the database
	 */
	private function _deleteUnreferencedExercises(){
		$component = 'exercise';
        $sql = "SELECT mr.filename
                FROM media m INNER JOIN media_rendition mr ON m.id=mr.fk_media_id
                WHERE m.component='%s'";
		
        $exercises = null;
        $data = $this->db->_multipleSelect($sql,$component);
        if($data){
            $exercises = array();
            foreach($data as $d){
                $exercises[] = $d->filename;
            }
        }

		if($this->exerciseFolder && !empty($this->exerciseFolder)){
			$exercisesPath = $this->red5Path .'/'.$this->exerciseFolder;
			$this->_deleteFiles($exercisesPath, $exercises);
		}

	}

	/**
	 * Deletes the files under <RED5_APP_PATH>/streams/responses that are not referenced in the database
	 */
	private function _deleteUnreferencedResponses(){
		$sql = "SELECT file_identifier FROM response";

		$responses = $this->_listFiles($this->db->_multipleSelect($sql), 'file_identifier');

		if($this->responseFolder && !empty($this->responseFolder)){
			$responsesPath = $this->red5Path .'/'.$this->responseFolder;
			$this->_deleteFiles($responsesPath, $responses);
		}

	}

	/**
	 * Deletes the files under <RED5_APP_PATH>/streams/evaluations that are not referenced in the database
	 */
	private function _deleteUnreferencedEvaluations(){
		$sql = "SELECT video_identifier FROM evaluation_video";

		$evaluations = $this->_listFiles($this->db->_multipleSelect($sql), 'video_identifier');

		if($this->evaluationFolder && !empty($this->evaluationFolder)){
			$evaluationsPath = $this->red5Path .'/'.$this->evaluationFolder;
			$this->_deleteFiles($evaluationsPath, $evaluations);
		}
	}
	
	/**
	 * Deletes the files under <RED5_APP_PATH>/streams/config to avoid wasting space
	 */
	private function _deleteConfigs(){
		if($this->configFolder && !empty($this->configFolder)){
			$configs = array();
			$configs[0] = 'default.flv';
			$configPath = $this->red5Path .'/'.$this->configFolder;
			$this->_deleteFiles($configPath, $configs);
		}
	}
	
	/**
	 * Takes an object resultSet and appends the flv extension to the selected object's property
	 * @param array $data
	 * 		An array of stdClass objects which contain a single property
	 * @param String $property
	 * 		The property of the object we want to append something to
	 * @return array $files
	 * 		Returns an array of String with filenames or false no data was found
	 */
	private function _listFiles($data, $property){
		$files = array();
		if($data && is_array($data)){
			foreach($data as $d){
				$files[] = $d->$property . '.flv';
			}
		}
		return count($files)>0 ? $files : false;
	}

	/**
	 * Searches the given folder for files that are no amongst the provided referenced resource list and moves those files to
	 * another folder usually called 'unreferenced'.
	 * 
	 * @param String $pathToInspect
	 * 		The folder in which file occurrences should be searched for
	 * @param array $referencedResources
	 * 		An array of filenames that are referenced in our database
	 */
	private function _deleteFiles($pathToInspect, $referencedResources){
		if($referencedResources){
			$folder = dir($pathToInspect);

			while (false !== ($entry = $folder->read())) {
				$entryFullPath = $pathToInspect.'/'.$entry;
				if(!is_dir($entryFullPath)){
					$entryInfo = pathinfo($entryFullPath);
					if( $entryInfo['extension'] == 'flv' && !in_array($entry, $referencedResources) && !strstr($entry,'merge') ){

						//Check modified time of the entry.
						//If it was modified 2 hours ago and is not referenced in the database it is very likely the user isn't watching it and won't watch it anymore
						if( ($mtime = filemtime ($entryFullPath)) && ((time()-$mtime)/3600 > 2) ){
							
							//Unlink video metadata that's no longer needed
							if(is_file($entryFullPath.'.meta')){
								if(unlink($entryFullPath.'.meta')){
									echo "Successfully DELETED meta file: ".$entryFullPath.".meta\n";
								} else {
									echo "Error while DELETING meta file: ".$entryFullPath.".meta\n";
								}
							}

							//If possible, move the file to the unrefenced folder
							$unrefPath = $this->red5Path.'/unreferenced';
							if(is_dir($unrefPath) && is_readable($unrefPath) && is_writable($unrefPath)){
								//if(rename($entryFullPath.'.unreferenced',$unrefPath.'/'.$entry.'.unreferenced')){
								if(rename($entryFullPath,$unrefPath.'/'.$entry)){
									echo "Successfully MOVED from: ".$entryFullPath." to: ". $unrefPath."/".$entry."\n";
								} else {
									echo "Error while MOVING from: ".$entryFullPath." to: ". $unrefPath."/".$entry."\n";
								}
							}
						}
							
							
					}
				}
			}
			$folder->close();
		}
	}
}
