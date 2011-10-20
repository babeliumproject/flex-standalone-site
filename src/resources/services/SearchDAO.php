<?php

require_once 'utils/Config.php';
require_once 'utils/Datasource.php';
require_once 'utils/SessionHandler.php';

require_once 'vo/ExerciseVO.php';

require_once 'Zend/Search/Lucene.php';

class SearchDAO {
	private $conn;
	private $indexPath;
	private $index;
	
	private $exerciseMinRatingCount;
	private $exerciseGlobalAvgRating;

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
		$searchResults = array();

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
			$hits = $this->index->find($query);
		}
		catch (Zend_Search_Lucene_Exception $ex) {
			throw new Exception($ex->getMessage());
		}
			
		foreach ($hits as $hit) {
			$temp = new ExerciseVO( );

			$temp->id = $hit->idEx;
			$temp->title = $hit->title;
			$temp->description = $hit->description;
			$temp->language = $hit->language;
			$temp->tags = $hit->tags;
			$temp->source = $hit->source;
			$temp->name = $hit->name;
			$temp->thumbnailUri = $hit->thumbnailUri;
			$temp->addingDate = $hit->addingDate;
			$temp->duration = $hit->duration;
			$temp->userName = $hit->userName;
			$temp->avgRating = $hit->avgRating;
			$temp->avgDifficulty = $hit->avgDifficulty;
			$temp->score = $hit->score;
			$temp->idIndex = $hit->id;

			array_push ( $searchResults, $temp );
		}
		return $searchResults;
	}

	public function fuzzySearch($search){
		//Decide whether to make the fuzzy search
		$auxSearch=$search;
		$finalSearch=$search;
		$count =0;
		$array_substitution=array("+","-", "&","|","!", "(",")", "{","}", "[","]", "^","~", "*","?",":","\\","/","\"", "or","and","not");

		$auxSearch=str_replace($array_substitution, ',', $auxSearch, $count);
		if ($count==0){
			$finalSearch=str_replace(' ', '~ ', $search);
			$finalSearch=$finalSearch . "~";
		}
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
		//rmdir($this->indexPath);
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
		$sql = "SELECT e.id, e.title, e.description, e.language, e.tags, e.source, e.name, e.thumbnail_uri, e.adding_date,
		               e.duration, u.name as userName, avg (suggested_level) as avgLevel, e.status, license, reference, a.complete as isSubtitled
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
				
				$lineAvgScore = $this->getExerciseAvgBayesianScore($line->id);
				$line->avgRating = $lineAvgRating;
				
				$this->addDoc($line);
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
		$sql = "SELECT e.id, e.title, e.description, e.language, e.tags, e.source, e.name, e.thumbnail_uri, e.adding_date,
		               e.duration, u.name as userName, avg (suggested_level) as avgLevel, e.status, license, reference, a.complete as isSubtitled
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
			$result->avgRating = $lineAvgRating;
			
			$this->addDoc($result);
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

	private function addDoc($documentData){
		
		$doc = new Zend_Search_Lucene_Document();
		foreach($documentData as $key => $value){
			//TODO add a filter to ignore the properties to ignore and type casting to add with the appropriate type setting
			$doc->addField(Zend_Search_Lucene_Field::Text($key, $value, 'utf-8'));
		}
		/*		
		$doc->addField(Zend_Search_Lucene_Field::Text('idEx', $idEx, 'utf-8'));
		$doc->addField(Zend_Search_Lucene_Field::Text('title', $title, 'utf-8'));
		$doc->addField(Zend_Search_Lucene_Field::Text('description', $description, 'utf-8'));
		$doc->addField(Zend_Search_Lucene_Field::Text('language', $language, 'utf-8'));
		$doc->addField(Zend_Search_Lucene_Field::Text('tags', $tags, 'utf-8'));
		$doc->addField(Zend_Search_Lucene_Field::UnIndexed('source', $source, 'utf-8'));
		$doc->addField(Zend_Search_Lucene_Field::UnIndexed('name', $name, 'utf-8'));
		$doc->addField(Zend_Search_Lucene_Field::UnIndexed('thumbnailUri', $thumbnailUri, 'utf-8'));
		$doc->addField(Zend_Search_Lucene_Field::UnIndexed('addingDate', $addingDate, 'utf-8'));
		$doc->addField(Zend_Search_Lucene_Field::UnIndexed('duration', $duration, 'utf-8'));
		$doc->addField(Zend_Search_Lucene_Field::Text('userName', $userName, 'utf-8'));
		$doc->addField(Zend_Search_Lucene_Field::Text('avgRating', $avgRating, 'utf-8'));
		$doc->addField(Zend_Search_Lucene_Field::Text('avgDifficulty', $avgDifficulty, 'utf-8'));
		*/
		$this->index->addDocument($doc);
	}
	
	
	/**
	 * The average score is not accurate information in statistical terms, so we use a weighted value
	 * @param int $exerciseId
	 */
	private function getExerciseAvgBayesianScore($exerciseId){

		if(!isset($this->exerciseMinRatingCount)){
			$sql = "SELECT prefValue FROM preferences WHERE (prefName = 'minVideoRatingCount')";
			$result = $this->conn->_select($sql);
		}
		$this->exerciseMinRatingCount = $result ? $result->prefValue : 0;

		if(!isset($this->exerciseGlobalAvgRating)){
			$sql = "SELECT avg(suggested_score) as globalAvgScore FROM exercise_score ";
			$result = $this->conn->_select($sql);
		}
		$this->exerciseGlobalAvgRating = $result ? $result->globalAvgScore : 0;
		
		$sql = "SELECT e.id, avg (suggested_score) as avgScore, count(suggested_score) as scoreCount
				FROM exercise e LEFT OUTER JOIN exercise_score s ON e.id=s.fk_exercise_id    
				WHERE (e.id = '%d' ) GROUP BY e.id";
		if($result = $this->conn->_select($sql,$exerciseId)){
			$exerciseAvgRating = $result->avgRating;
			$exerciseRatingCount = $result->ratingCount ? $result->ratingCount : 1;
			$exerciseBayesianAvg = ($exerciseAvgRating*($exerciseRatingCount/($exerciseRatingCount + $this->exerciseMinRatingCount))) +
								   ($this->exerciseGlobalAvgRating*($this->exerciseMinRatingCount/($exerciseRatingCount + $this->exerciseMinRatingCount)));
			$result->avgRating = $exerciseBayesianAvg;
		}
		return $result;
	}	
	
	
}

?>