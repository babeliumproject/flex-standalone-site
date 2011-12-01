<?php

define('CLI_SERVICE_PATH', '/var/www/babelium/services');

require_once CLI_SERVICE_PATH . '/utils/Datasource.php';
require_once CLI_SERVICE_PATH . '/utils/Config.php';


/**
 *
 * This class should be only launched by CRON tasks, therefore it should be placed outside the scope of public access
 *
 * @author inko
 *
 */
class PeriodicTaskDAO{

	private $conn;
	private $filePath;
	private $red5Path;

	private $exerciseFolder = '';
	private $responseFolder = '';
	private $evaluationFolder = '';
	private $configFolder = 'config';

	public function PeriodicTaskDAO(){
		$settings = new Config ( );
		$this->filePath = $settings->filePath;
		$this->red5Path = $settings->red5Path;
		$this->conn = new Datasource ( $settings->host, $settings->db_name, $settings->db_username, $settings->db_password );
		$this->_getResourceDirectories();
	}

	public function deleteAllUnreferenced(){
		$this->_deleteUnreferencedExercises();
		$this->_deleteUnreferencedResponses();
		$this->_deleteUnreferencedEvaluations();
		$this->_deleteConfigs();
	}

	public function deleteInactiveUsers($days){
		if($days<7)
		return;
		else{
			$sql = "DELETE FROM users
					WHERE (DATE_SUB(CURDATE(),INTERVAL '%d' DAY) > joiningDate AND active = 0 AND activation_hash <> '')";
			$result = $this->conn->_execute($sql,$days);
		}
	}

	public function deactivateReportedVideos(){

		$sql = "SELECT prefValue FROM preferences WHERE (prefName='reports_to_delete')";
		$result = $this->conn->_execute($sql);
		$row = $this->conn->_nextRow ($result);
		if ($row){

			$reportsToDeletion = $row[0];

			$sql = "UPDATE exercise AS E SET status='Unavailable'
		       	    WHERE '%d' <= (SELECT count(*) 
		        		          FROM exercise_report WHERE fk_exercise_id=E.id ) ";
			return $this->conn->_execute($sql, $reportsToDeletion);
		}
	}

	public function monitorizeSessionKeepAlive(){
		$sql = "UPDATE user_session SET duration = TIMESTAMPDIFF(SECOND,session_date,CURRENT_TIMESTAMP), closed=1
				WHERE (keep_alive = 0 AND closed=0 AND duration=0)";

		$result = $this->conn->_execute($sql);

		$sql = "UPDATE user_session SET keep_alive = 0
				WHERE (keep_alive = 1 AND closed = 0)";

		$result = $this->conn->_execute($sql);
	}

	private function _getResourceDirectories(){
		$sql = "SELECT prefValue FROM preferences
				WHERE (prefName='exerciseFolder' OR prefName='responseFolder' OR prefName='evaluationFolder') 
				ORDER BY prefName";
		$result = $this->conn->_execute($sql);

		$row = $this->conn->_nextRow($result);
		$this->evaluationFolder = $row ? $row[0] : 'evaluations';
		$row = $this->conn->_nextRow($result);
		$this->exerciseFolder = $row ? $row[0] : 'exercises';
		$row = $this->conn->_nextRow($result);
		$this->responseFolder = $row ? $row[0] : 'responses';
	}

	private function _deleteUnreferencedExercises(){
		$sql = "SELECT name FROM exercise";
			
		$exercises = $this->_listFiles($sql);

		if($this->exerciseFolder && !empty($this->exerciseFolder)){
			$exercisesPath = $this->red5Path .'/'.$this->exerciseFolder;
			$this->_deleteFiles($exercisesPath, $exercises);
		}

	}

	private function _deleteUnreferencedResponses(){
		$sql = "SELECT file_identifier FROM response";

		$responses = $this->_listFiles($sql);

		if($this->responseFolder && !empty($this->responseFolder)){
			$responsesPath = $this->red5Path .'/'.$this->responseFolder;
			$this->_deleteFiles($responsesPath, $responses);
		}

	}

	private function _deleteUnreferencedEvaluations(){
		$sql = "SELECT video_identifier FROM evaluation_video";

		$evaluations = $this->_listFiles($sql);

		if($this->evaluationFolder && !empty($this->evaluationFolder)){
			$evaluationsPath = $this->red5Path .'/'.$this->evaluationFolder;
			$this->_deleteFiles($evaluationsPath, $evaluations);
		}
	}
	
	private function _deleteConfigs(){
		if($this->configFolder && !empty($this->configFolder)){
			$configs = array();
			$configs[0] = 'default.flv';
			$configPath = $this->red5Path .'/'.$this->configFolder;
			$this->_deleteFiles($configPath, $configs);
		}
	}

	private function _listFiles($sql){
		$searchResults = array ();
		$result = $this->conn->_execute ( func_get_args() );
		while($row = $this->conn->_nextRow($result)){
			$file = $row[0] .'.flv';
			array_push($searchResults, $file);
		}
		return $searchResults;
	}

	private function _deleteFiles($pathToInspect, $referencedResources){
		if($referencedResources){
			$folder = dir($pathToInspect);

			while (false !== ($entry = $folder->read())) {
				$entryFullPath = $pathToInspect.'/'.$entry;
				if(!is_dir($entryFullPath)){
					$entryInfo = pathinfo($entryFullPath);
					if($entryInfo['extension'] == 'flv' && !in_array($entry, $referencedResources)){

						//Check modified time of the entry.
						//If it was modified 2 hours ago and is not referenced in the database it is very likely the user isn't watching it and won't watch it anymore
						if( ($mtime = filemtime ($entryFullPath)) && ((time()-$mtime)/3600 > 2) ){
							
							//Append the .unreferenced extension to the videos that aren't in the database
							//if(rename($entryFullPath, $entryFullPath.'.unreferenced')){
							//	echo "Successfully RENAMED from: ".$entryFullPath." to: ".$entryFullPath.".unreferenced\n";
							//} else {
							//	echo "Error while RENAMING from: ".$entryFullPath." to: ".$entryFullPath.".unreferenced\n";
							//}
							
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