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

require_once 'utils/Config.php';
require_once 'utils/Datasource.php';
require_once 'utils/SessionHandler.php';

require_once 'Zend/Search/Lucene.php';

/**
 * This class is used to perform several kinds of searches over the available exercises of the system
 * 
 * @author Babelium Team
 *
 */
class Search {
	private $conn;
	private $indexPath;
	private $index;
	
	private $exerciseMinRatingCount;
	private $exerciseGlobalAvgRating;
	
	/**
	 * These fields won't be included in the search queries
	 */
	private $unindexedFields = array('source', 'name','thumbnailUri', 'addingDate', 'duration');

	/**
	 * Constructor function
	 *
	 * @throws Exception
	 * 		Thrown if there is a problem establishing a connection with the database
	 */
	public function __construct() {
		try {
			$verifySession = new SessionHandler();
			$settings = new Config();
			$this->indexPath = $settings->indexPath;
			$this->conn = new Datasource ($settings->host, $settings->db_name, $settings->db_username, $settings->db_password );
		} catch (Exception $e) {
			throw new Exception($e->getMessage());
		}
	}

	/**
	 * Opens the Lucene search index file. The index file is periodically refreshed grabbing database data.
	 * See the cron scripts to know how often this index is refreshed
	 * 
	 * @throws Exception
	 * 		The index file could not be found or there was a problem opening the index file
	 */
	private function initialize(){
		try{
			$this->index = Zend_Search_Lucene::open($this->indexPath);
		}catch (Zend_Search_Lucene_Exception $ex){
			throw new Exception($ex->getMessage());
		}
	}

	/**
	 * Searches the provided term throughout all the indexed fields of the index file
	 * 
	 * @param String $search
	 * 		The user's search term
	 * @return mixed
	 * 		An array of stdClass objects with information of exercises that match the search criteria in 
	 * 		any of the indexed fields or false on error or empty search
	 * @throws Exception
	 * 		There was an error searching the index file
	 */
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
				$searchResult = new stdClass();
				foreach($fields as $field){
					if($field == "exerciseId"){
						$searchResult->id = $hit->$field;
					} else {
						$searchResult->$field = $hit->$field;
					}
				}
				array_push($searchResults,$searchResult);
			}
			return $this->conn->multipleRecast('ExerciseVO',$searchResults);
		}
		catch (Zend_Search_Lucene_Exception $ex) {
			throw new Exception($ex->getMessage());
		}
	}

	/**
	 * Removes all search wildcards provided by the user and replaces them with individual term fuzzy search modifiers. 
	 * Each requested term is appended with the '~' modifier that tells lucene to do a fuzzy search. 
	 * 
	 * The Lucene fuzzy search is performed using similarity measurement provided by Levenshtein's distance algorithm.
	 * http://en.wikipedia.org/wiki/Levenshtein_distance 
	 * 
	 * @param String $search
	 * 			The term (or terms) of the search query
	 * @return String $finalSearch
	 * 			The parsed search query with fuzzy search modifiers applied
	 */
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

	/**
	 * Deletes the previous search indexing file and generates a new one using the most up-to-date data available on the database
	 */
	public function reCreateIndex(){
		$this->deleteIndexRecursive($this->indexPath);
		$this->createIndex();
	}

	/**
	 * Deletes all the contents of the requested folder, if that folder exists. If the provided path is a file or a symbolic link it is deleted as well.
	 * 
	 * @param String $dirname
	 * 		Absolute path of the directory whose files are going to be deleted
	 */
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

	/**
	 * Creates a new search index file with the current contents of the database's exercise table.
	 * The fields that won't be indexed are specified in the unidexedFields array of the class
	 */
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
		$result = $this->conn->_multipleSelect ( $sql );
		if($result){
			//Create the index
			$this->index = Zend_Search_Lucene::create($this->indexPath);

			//To recognize numerics
			Zend_Search_Lucene_Analysis_Analyzer::setDefault(new Zend_Search_Lucene_Analysis_Analyzer_Common_TextNum_CaseInsensitive());

			foreach ( $result as $line ) {
				
				$lineAvgScore = $this->getExerciseAvgBayesianScore($line->exerciseId);
				$line->avgRating = $lineAvgScore ? $lineAvgScore->avgScore : 0;
				$descriptors = $this->getExerciseDescriptors($line->exerciseId,$line->language);
				if($descriptors)
					$line->descriptors = implode(', ',$descriptors);
				else
					$line->descriptors = '';
				
				$this->addDoc($line,$this->unindexedFields);
			}
			$this->index->commit();
			$this->index->optimize();
		}
	}
	
	/**
	 *	Adds a new document entry (exercise data set) to the already existing search index file
	 *
	 *	@param int $idDB
	 *		An exercise identifier to query the database for exercise data.
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
		$result = $this->conn->_singleSelect ( $sql, $idDB );

		//We expect only one record to match this query
		if($result){
			//Loads the lucene indexation file
			$this->initialize();
			
			$lineAvgScore = $this->getExerciseAvgBayesianScore($result->id);
			$result->avgRating = $lineAvgScore ? $lineAvgScore->avgScore : 0;
			$descriptors = $this->getExerciseDescriptors($result->exerciseId,$result->language);
			if($descriptors)
				$result->descriptors = implode(', ',$descriptors);
			else
				$result->descriptors = '';
			
			$this->addDoc($result,$this->unindexedFields);
			$this->index->commit();
			$this->index->optimize();
		}

	}

	/**
	 * Delete a document entry (exercise data set) from an already existing search index file
	 * 
	 * @param int $idDB
	 * 		The search index identifier (and also exercise identifier) that's going to be removed from the index file
	 */
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

	/**
	 * Adds several document entries (exercise data sets) to the already existing (usually empty) search index file
	 * 
	 * @param array $documentData
	 * 		An array of stdClass with data about exercises of the database
	 * @param array $unindexedFields
	 * 		The fields thath won't be used to build the searchable item index
	 */
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
	 * Returns the descriptors of the provided exercise (if any) formated like this example: D000_A1_SI00
	 * @param int $exerciseId
	 * 		The exercise id to check for descriptors
	 * @return mixed $dcodes
	 * 		An array of descriptor codes. False when the exercise has no descriptors at all.
	 */
	private function getExerciseDescriptors($exerciseId,$exerciseLanguage){
		if(!$exerciseId)
			return false;
		$dcodes = false;
		$sql = "SELECT ed.*, ed18n.name
				FROM rel_exercise_descriptor red INNER JOIN exercise_descriptor ed ON red.fk_exercise_descriptor_id=ed.id
     			     INNER JOIN exercise_descriptor_i18n ed18n ON ed.id=ed18n.fk_exercise_descriptor_id
				WHERE (red.fk_exercise_id=%d AND ed18n.locale='%s')";
		$results = $this->conn->_multipleSelect($sql,$exerciseId,$exerciseLanguage);
		if($results){
			$dcodes = array();
			foreach($results as $result){
				$dcode = sprintf("D%03d%s%s%02d %s", $result->id, $result->level, $result->type, $result->number, $result->name);
				$dcodes[] = $dcode;
			}
			unset($result);
		}
		return $dcodes;
	}
	
	
	/**
	 * The average score is not accurate information in statistical terms, so we use a weighted value
	 * @param int $exerciseId
	 */
	public function getExerciseAvgBayesianScore($exerciseId){
		if(!isset($this->exerciseMinRatingCount)){
			$sql = "SELECT prefValue FROM preferences WHERE (prefName = 'minVideoRatingCount')";
			$result = $this->conn->_singleSelect($sql);
			$this->exerciseMinRatingCount = $result ? $result->prefValue : 0;
		}
		
		if(!isset($this->exerciseGlobalAvgRating)){
			$sql = "SELECT avg(suggested_score) as globalAvgScore FROM exercise_score ";
			$result = $this->conn->_singleSelect($sql);
			$this->exerciseGlobalAvgRating = $result ? $result->globalAvgScore : 0;
		}
		
		$sql = "SELECT e.id, avg (suggested_score) as avgScore, count(suggested_score) as scoreCount
				FROM exercise e LEFT OUTER JOIN exercise_score s ON e.id=s.fk_exercise_id    
				WHERE (e.id = '%d' ) GROUP BY e.id";
		if($result = $this->conn->_singleSelect($sql,$exerciseId)){
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
