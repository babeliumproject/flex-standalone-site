<?php

require_once ('Datasource.php');
require_once ('Config.php');

class CleanUpDAO{

	private $conn;
	private $filePath;
	private $red5Path;

	private $exerciseFolder = '';
	private $responseFolder = 'audio';
	private $evaluationFolder = 'evaluations';

	public function CleanUpDAO(){
		$settings = new Config ( );
		$this->filePath = $settings->filePath;
		$this->red5Path = $settings->red5Path;
		$this->conn = new Datasource ( $settings->host, $settings->db_name, $settings->db_username, $settings->db_password );
	}

	public function deleteAllUnreferenced(){
		//$this->_getResourceDirectories();
		$this->_deleteUnreferencedExercises();
		if($this->exerciseFolder != $this->responseFolder)
			$this->_deleteUnreferencedResponses();
		if($this->exerciseFolder != $this->evaluationFolder)
			$this->_deleteUnreferencedEvaluations();
	}

	private function _getResourceDirectories(){
		$sql = "SELECT * FROM preferences
				WHERE (prefName='exerciseFolder' OR prefName='responseFolder' OR prefName='evaluationFolder') 
				ORDER BY prefName";
		$result = $this->conn->_execute($sql);

		$row = $this->conn->_nextRow($result);
		$this->evaluationFolder = $row ? $row[1] : '';
		$row = $this->conn->_nextRow($result);
		$this->exerciseFolder = $row ? $row[1] : 'audio';
		$row = $this->conn->_nextRow($result);
		$this->responseFolder = $row ? $row[1] : 'evaluations';
	}

	private function _deleteUnreferencedExercises(){
		$sql = "SELECT name FROM exercise";
			
		$exercises = $this->_listFiles($sql);

		if($this->exerciseFolder)
		$exercisesPath = $this->red5Path .'/'.$this->exerciseFolder;
		else
		$exercisesPath = $this->red5Path;
		$this->_deleteFiles($exercisesPath, $exercises);

	}

	private function _deleteUnreferencedResponses(){
		$sql = "SELECT file_identifier FROM response";

		$responses = $this->_listFiles($sql);

		if($this->responseFolder)
		$responsesPath = $this->red5Path .'/'.$this->responseFolder;
		else
		$responsesPath = $this->red5Path;
		$this->_deleteFiles($responsesPath, $responses);

	}

	private function _deleteUnreferencedEvaluations(){
		$sql = "SELECT video_identifier FROM evaluation_video";

		$evaluations = $this->_listFiles($sql);

		if($this->evaluationFolder)
		$evaluationsPath = $this->red5Path .'/'.$this->evaluationFolder;
		else
		$evaluationsPath = $this->red5Path;
		$this->_deleteFiles($evaluationsPath, $evaluations);
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
						//array_push($resourcesToDelete, $exercisesPath.'/'.$entry);
						@unlink($entryFullPath);
						@unlink($entryFullPath.'.meta');
					}
				}
			}
			$folder->close();
		}
	}
}