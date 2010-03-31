<?php

require_once ('Config.php');
require_once ('ExerciseVO.php');
require_once ('Datasource.php');
require_once ('Zend/Search/Lucene.php');

class SearchDAO {
	private $conn;
	private $indexPath;
	private $index;
	 
	public function SearchDAO() {
			$settings = new Config ( );
			$this->indexPath = $settings->indexPath;
			$this->conn = new Datasource ( $settings->host, $settings->db_name, $settings->db_username, $settings->db_password );
	}
	public function initialize(){
		try{
			$this->index = Zend_Search_Lucene::open($this->indexPath);	
		}catch (Zend_Search_Lucene_Exception $ex){
			try{
				$this->createIndex();
				$this->index = Zend_Search_Lucene::open($this->indexPath);
			}catch(Zend_Search_Lucene_Exception $exc){
				$this->initialize();
			}	
		}
	}
	
	public function launchSearch($search) {
		$searchResults = array();
		
		//Opens the index
		$this->initialize();	
		
 		$query = Zend_Search_Lucene_Search_QueryParser::parse($search);  
 		
 		//We do the search and send it	
  		try {
        	$hits = $this->index->find($query);
    	}
    	catch (Zend_Search_Lucene_Exception $ex) {
        	$hits = array();
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
			$temp->userId = $hit->userId;
			$temp->userName = $hit->userName;
			$temp->avgRating = $hit->avgRating;
			$temp->avgDifficulty = $hit->avgDifficulty;
			$temp->score = $hit->score;
			$temp->idIndex = $hit->id;
			
			array_push ( $searchResults, $temp );
    	}
		
		return $searchResults;
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
	    $dir->close();
	    return rmdir($dirname);
	}
	
	public function createIndex() {
		//Query for the index
		$sql = "SELECT e.id, e.title, e.description, e.language, e.tags, e.source, e.name, e.thumbnail_uri,
       					e.adding_date, e.fk_user_id, u.name, avg(suggested_score) as avgScore, 
       					avg (suggested_level) as avgLevel
				 FROM   exercise e INNER JOIN users u ON e.fk_user_id= u.ID
       				    LEFT OUTER JOIN exercise_score s ON e.id=s.fk_exercise_id
       				    LEFT OUTER JOIN exercise_level l ON e.id=l.fk_exercise_id
       			 WHERE (e.status = 'Available')
				 GROUP BY e.id";
 		$result = $this->conn->_execute ( $sql );
				
		//Create the index
		$this->index = Zend_Search_Lucene::create($this->indexPath);	
		
   		//To recognize numerics
		Zend_Search_Lucene_Analysis_Analyzer::setDefault(new Zend_Search_Lucene_Analysis_Analyzer_Common_TextNum_CaseInsensitive());
		
		while ( $row = $this->conn->_nextRow ( $result ) ) {
			$this->addDoc($row[0],$row[1],$row[2],$row[3],$row[4],$row[5],$row[6],$row[7],$row[8],$row[9],$row[10],$row[11],$row[12]);			
		}
		$this->index->commit();
		$this->index->optimize();			
	}
	public function addDocumentIndex($result){
						
		//Opens the index
		$this->initialize();
		
		while ( $row = $this->conn->_nextRow ( $result ) ) {
			$this->addDoc($row[0],$row[1],$row[2],$row[3],$row[4],$row[5],$row[6],$row[7],$row[8],$row[9],$row[10],$row[11],$row[12]);	
		}
		$this->index->commit();
		$this->index->optimize();	
	}
	
	public function deleteDocumentIndex($idDB){
		//Opens the index
		$this->initialize();
		//Retrieving and deleting document
		$term = new Zend_Search_Lucene_Index_Term($idDB, 'idEx');
		$docIds  = $this->index->termDocs($term);
		foreach ($docIds as $id) {
  			$doc = $this->index->getDocument($id);
			$this->index->delete($doc->id);
	    }
    	$this->index->commit();
		$this->index->optimize();	
	}
	
	private function addDoc($idEx,$title,$description,$language,$tags,$source,$name,$thumbnailUri,$addingDate,$userId,$userName,$avgRating,$avgDifficulty){
		$doc = new Zend_Search_Lucene_Document();
			
		$doc->addField(Zend_Search_Lucene_Field::Text('idEx', $idEx));
		$doc->addField(Zend_Search_Lucene_Field::Text('title', $title));
		$doc->addField(Zend_Search_Lucene_Field::Text('description', $description));
		$doc->addField(Zend_Search_Lucene_Field::Text('language', $language));
		$doc->addField(Zend_Search_Lucene_Field::Text('tags', $tags));
		$doc->addField(Zend_Search_Lucene_Field::UnIndexed('source', $source));
		$doc->addField(Zend_Search_Lucene_Field::UnIndexed('name', $name));
		$doc->addField(Zend_Search_Lucene_Field::UnIndexed('thumbnailUri', $thumbnailUri));
		$doc->addField(Zend_Search_Lucene_Field::UnIndexed('addingDate', $addingDate));
		$doc->addField(Zend_Search_Lucene_Field::UnIndexed('userId', $userId));
		$doc->addField(Zend_Search_Lucene_Field::Text('userName', $userName));
		$doc->addField(Zend_Search_Lucene_Field::UnIndexed('avgRating', $avgRating));
		$doc->addField(Zend_Search_Lucene_Field::UnIndexed('avgDifficulty', $avgDifficulty));
		$this->index->addDocument($doc);
	}
}

?>