<?php

require_once 'utils/Config.php';
require_once 'utils/Datasource.php';
require_once 'utils/SessionHandler.php';

require_once 'Zend/Search/Lucene.php';

class SearchDAO {
	private $conn;
	private $indexPath;
	private $index;
	
	private $exerciseMinRatingCount;
	private $exerciseGlobalAvgRating;
	
	private $unindexedFields = array('source', 'name','thumbnailUri', 'addingDate', 'duration');

	public function SearchDAO() {
		try {
			$verifySession = new SessionHandler();
			$settings = new Config ( );
			$this->indexPath = $settings->indexPath;
			$this->conn = new Datasource ($settings->host, $settings->db_name, $settings->db_username, $settings->db_password );
		} catch (Exception $e) {
			throw new Exception($e->getMessage());
		}
	}

	private function initialize(){
		try{
			$this->index = Zend_Search_Lucene::open($this->indexPath);
		}catch (Zend_Search_Lucene_Exception $ex){
			throw new Exception($e->getMessage());
		}
	}

	public function launchSearch($search) {
		//Return empty array if empty query
		if($search == '')
			return;

		//Opens the index
		$this->initialize();

		//To recognize numerics
		//Zend_Search_Lucene_Analysis_Analyzer::setDefault(new Zend_Search_Lucene_Analysis_Analyzer_Common_TextNum_CaseInsensitive());

		//Remove the limitations of fuzzy and wildcard searches
		Zend_Search_Lucene_Search_Query_Wildcard::setMinPrefixLength(0);
		Zend_Search_Lucene_Search_Query_Fuzzy::setDefaultPrefixLength(0);

			
		$finalSearch=$this->fuzzySearch($search);
		$query = Zend_Search_Lucene_Search_QueryParser::parse($finalSearch);
			
		//We do the search and send it
		try {
			//$hits can't be returned directly as is, because it's an array of Zend_Search_Lucene_Search_QueryHit 
			//which has far more properties than those the client needs to know
			$hits = $this->index->find($query);
			//Ensure the fields are stored with the exact names you want them to be returned otherways this won't work
			$fields = $this->index->getFieldNames();
			$searchResults = array();
			foreach($hits as $hit){
				$searchResult = new ExerciseVO();
				foreach($fields as $field){
					if($field == "exerciseId"){
						$searchResult->id = $hit->$field;
					} else {
						$searchResult->$field = $hit->$field;
					}
				}
				array_push($searchResults,$searchResult);
			}
			return $searchResults;
		}
		catch (Zend_Search_Lucene_Exception $ex) {
			throw new Exception($ex->getMessage());
		}
	}

	public function fuzzySearch($search){
		//Decide whether to make the fuzzy search
		$auxSearch=$search;
		$finalSearch=$search;
		$count =0;
		//$array_substitution=array("+","-","_","&","|","!", "(",")", "{","}", "[","]", "^","~", "*","?",":","\\","/","\"", "or","and","not");
		$array_substitution=array("+","-","_","&","|","!", "(",")", "{","}", "[","]", "^","~",":","\\","/","\"", "or","and","not");
		
		$auxSearch=trim(str_replace($array_substitution, ' ', $auxSearch, $count));
		$auxSearch = preg_replace("/\s{2,}/"," ",$auxSearch);
		$auxSearch = preg_replace("/(\w+) (\W)/","$1$2",$auxSearch);
		if ($count==0){
			$finalSearch=str_replace(' ', '~ ', $search);
			$finalSearch=$finalSearch . "~";
		} else {
			$finalSearch = $auxSearch;
		}
		//error_log("replace: " . $auxSearch."\nreplaceCount:".$count."\nfinalSearch: ".$finalSearch."\n",3,"/tmp/search.log");
		return $finalSearch;
	}

	public function setTagToDB($search){
		if ($search!=''){
			$sql = "SELECT amount FROM tagcloud WHERE tag='%s'";
			$result = $this->conn->_execute ($sql, $search);
			if ($row = $this->conn->_nextRow ($result)){
				//The tag already exists, so updating the quantity
				$newAmount= 1 + $row[0];
				$sql = "UPDATE tagcloud SET amount = ". $newAmount . " WHERE tag='%s'";
				$result = $this->conn->_execute ($sql, $search);
			}else{
				//Insert the tag
				$sql = "INSERT INTO tagcloud (tag, amount) VALUES ('%s', 0)";
				$result = $this->conn->_execute ($sql, $search);
			}
		}
		return $result;
	}

	public function reCreateIndex(){
		$this->deleteIndexRecursive($this->indexPath);
		$this->createIndex();
	}

	private function deleteIndexRecursive($dirname){
		// Sanity check
		if (!file_exists($dirname)) {
			return false;
		}

		// Simple delete for a file
		if (is_file($dirname) || is_link($dirname)) {
			return unlink($dirname);
		}

		// Loop through the folder
		$dir = dir($dirname);
		while (false !== $entry = $dir->read()) {
			// Skip pointers
			if ($entry == '.' || $entry == '..') {
				continue;
			}

			// Recursive
			$this->deleteIndexRecursive($dirname . DIRECTORY_SEPARATOR . $entry);
		}

		// Clean up
		return $dir->close();
		//return rmdir($dirname);
	}

	public function createIndex() {
		//Query for the index
		$sql = "SELECT e.id as exerciseId, e.title, e.description, e.language, e.tags, e.source, e.name, e.thumbnail_uri as thumbnailUri, e.adding_date as addingDate,
		               e.duration, u.name as userName, avg (suggested_level) as avgDifficulty, e.status, license, reference, a.complete as isSubtitled
				FROM exercise e 
					 INNER JOIN users u ON e.fk_user_id= u.ID
	 				 LEFT OUTER JOIN exercise_score s ON e.id=s.fk_exercise_id
       				 LEFT OUTER JOIN exercise_level l ON e.id=l.fk_exercise_id
       				 LEFT OUTER JOIN subtitle a ON e.id=a.fk_exercise_id
       			WHERE e.status = 'Available'
				GROUP BY e.id";
		$result = $this->conn->_select ( $sql );
		if($result){
			//Create the index
			$this->index = Zend_Search_Lucene::create($this->indexPath);

			//To recognize numerics
			Zend_Search_Lucene_Analysis_Analyzer::setDefault(new Zend_Search_Lucene_Analysis_Analyzer_Common_TextNum_CaseInsensitive());

			foreach ( $result as $line ) {
				
				$lineAvgScore = $this->getExerciseAvgBayesianScore($line->exerciseId);
				$line->avgRating = $lineAvgScore ? $lineAvgScore->avgScore : 0;
				
				$this->addDoc($line,$this->unindexedFields);
			}
			$this->index->commit();
			$this->index->optimize();
		}
	}

	
	/**
	 *	Adds a new document entry (exercise data set) to the search index file
	 *
	 */
	public function addDocumentIndex($idDB){

		//Query for the index
		$sql = "SELECT e.id as exerciseId, e.title, e.description, e.language, e.tags, e.source, e.name, e.thumbnail_uri as thumbnailUri, e.adding_date as addingDate,
		               e.duration, u.name as userName, avg (suggested_level) as avgDifficulty, e.status, license, reference, a.complete as isSubtitled
				FROM exercise e 
					 INNER JOIN users u ON e.fk_user_id= u.ID
	 				 LEFT OUTER JOIN exercise_score s ON e.id=s.fk_exercise_id
       				 LEFT OUTER JOIN exercise_level l ON e.id=l.fk_exercise_id
       				 LEFT OUTER JOIN subtitle a ON e.id=a.fk_exercise_id
       			WHERE e.status = 'Available' AND e.id='%d');
				GROUP BY e.id";
		$result = $this->conn->_select ( $sql, $idDB );

		//We expect only one record to match this query
		if($result && count($result) == 1){
			//Loads the lucene indexation file
			$this->initialize();
			
			$lineAvgScore = $this->getExerciseAvgBayesianScore($result->id);
			$result->avgRating = $lineAvgScore ? $lineAvgScore->avgScore : 0;
			
			$this->addDoc($result,$this->unindexedFields);
			$this->index->commit();
			$this->index->optimize();
		}

	}

	public function deleteDocumentIndex($idDB){
		//Opens the index
		$this->initialize();
		//Retrieving and deleting document
		$term = new Zend_Search_Lucene_Index_Term($idDB, 'idEx');
		$docIds  = $this->index->termDocs($term);
		foreach ($docIds as $id) {
			//$doc = $this->index->getDocument($id);
			//$this->index->delete($doc->id);
			$this->index->delete($id);
		}
		$this->index->commit();
		$this->index->optimize();
	}

	private function addDoc($documentData, $unindexedFields){
		
		$doc = new Zend_Search_Lucene_Document();
		foreach($documentData as $key => $value){
			if(in_array($key,$unindexedFields)){
				$doc->addField(Zend_Search_Lucene_Field::UnIndexed($key, $value, 'utf-8'));
			} else {
				$doc->addField(Zend_Search_Lucene_Field::Text($key, $value, 'utf-8'));
			}
		}
		$this->index->addDocument($doc);
	}
	
	
	/**
	 * The average score is not accurate information in statistical terms, so we use a weighted value
	 * @param int $exerciseId
	 */
	public function getExerciseAvgBayesianScore($exerciseId){
		if(!isset($this->exerciseMinRatingCount)){
			$sql = "SELECT prefValue FROM preferences WHERE (prefName = 'minVideoRatingCount')";
			$result = $this->conn->_select($sql);
			$this->exerciseMinRatingCount = $result ? $result->prefValue : 0;
		}
		
		if(!isset($this->exerciseGlobalAvgRating)){
			$sql = "SELECT avg(suggested_score) as globalAvgScore FROM exercise_score ";
			$result = $this->conn->_select($sql);
			$this->exerciseGlobalAvgRating = $result ? $result->globalAvgScore : 0;
		}
		
		$sql = "SELECT e.id, avg (suggested_score) as avgScore, count(suggested_score) as scoreCount
				FROM exercise e LEFT OUTER JOIN exercise_score s ON e.id=s.fk_exercise_id    
				WHERE (e.id = '%d' ) GROUP BY e.id";
		if($result = $this->conn->_select($sql,$exerciseId)){
			$exerciseAvgRating = $result->avgScore ? $result->avgScore : 0;
			$exerciseRatingCount = $result->scoreCount ? $result->scoreCount : 1;
			$exerciseBayesianAvg = ($exerciseAvgRating*($exerciseRatingCount/($exerciseRatingCount + $this->exerciseMinRatingCount))) +
								   ($this->exerciseGlobalAvgRating*($this->exerciseMinRatingCount/($exerciseRatingCount + $this->exerciseMinRatingCount)));
			$result->avgScore = $exerciseBayesianAvg;
		}
		return $result;
	}	
	
	
}

?>