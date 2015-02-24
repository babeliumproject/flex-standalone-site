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
require_once 'utils/SessionValidation.php';

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
	private $unindexedFields = array('difficulty','fk_user_id','status','visible','fk_scope_id','timecreated','timemodified','likes','dislikes','type','situation','competence','lingaspects');

	/**
	 * Constructor function
	 *
	 * @throws Exception
	 * 		Thrown if there is a problem establishing a connection with the database
	 */
	public function __construct() {
		try {
			$verifySession = new SessionValidation();
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

		//The same token analyzer should be used both when searching and/or creating the document index
		Zend_Search_Lucene_Analysis_Analyzer::setDefault(new Zend_Search_Lucene_Analysis_Analyzer_Common_TextNum_CaseInsensitive());

		//Remove the limitations of fuzzy and wildcard searches
		Zend_Search_Lucene_Search_Query_Wildcard::setMinPrefixLength(0);
		Zend_Search_Lucene_Search_Query_Fuzzy::setDefaultPrefixLength(0);

		$finalSearch=$this->fuzzySearch($search);
		$query = Zend_Search_Lucene_Search_QueryParser::parse($finalSearch);

		try {
			//$hits can't be returned directly as is, because it's an array of Zend_Search_Lucene_Search_QueryHit
			//which has far more properties than those the client needs to know
			$hits = $this->index->find($query);
			//Ensure the fields are stored with the exact names you want them to be returned otherwise this won't work
			$fields = $this->index->getFieldNames();
			$searchResults = array();
			foreach($hits as $hit){
				foreach($fields as $field){
					if($field == "exerciseid"){
						array_push($searchResults, $hit->$field);
						break;
					}
				}
			}
			return $searchResults;
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
		return $search;
		/* We won't be using the fuzzy search for the time being
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
		*/
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
		$sql = "SELECT id as exerciseid, exercisecode, title, description, language
				FROM exercise WHERE status=1 AND visible=1";
		$result = $this->conn->_multipleSelect ( $sql );
		if($result){
			//Create the index
			$this->index = Zend_Search_Lucene::create($this->indexPath);

			//To recognize numerics
			Zend_Search_Lucene_Analysis_Analyzer::setDefault(new Zend_Search_Lucene_Analysis_Analyzer_Common_TextNum_CaseInsensitive());

			foreach ( $result as $line ) {
				$tags = $this->getExerciseTags($line->exerciseid);
				$descriptors = $this->getExerciseDescriptors($line->exerciseid);//,$line->language);
				
				$line->tags = $tags ? implode("\n",$tags): '';
				$line->descriptors = $descriptors ? implode("\n",$descriptors) : '';
				
				$this->addDoc($line,$this->unindexedFields);
			}
			$this->index->commit();
			$this->index->optimize();
		}
	}
	
	/**
	 *	Add (or update existing) search document entry for an exercise
	 *	@param int $exercise
	 *		An exercise identifier of an exercise that is available
	 */
	public function addDocumentIndex($exerciseid){
		try {
			$verifySession = new SessionValidation(true);
			
			$userid=$_SESSION['uid'];
			
			$sql = "SELECT e.id as exerciseId, e.exercisecode, e.title, e.description, e.language, e.status, e.visible
					FROM exercise e WHERE e.id=%d AND e.fk_user_id=%d";
			$exercisedata = $this->conn->_singleSelect ($sql, $exerciseid,$userid);
			
			if($exercisedata){
				//Lucene doesn't support Document update, it must be deleted and added afterwards
				$this->delDoc($exerciseid);
				
				if($exercisedata->status==1 && $exercisedata->visible==1){
					$this->initialize();
							
					$tags = $this->getExerciseTags($result->exerciseId);
					$descriptors = $this->getExerciseDescriptors($result->exerciseId,$line->language);
						
					$result->tags = $tags ? implode("\n",$tags): '';
					$result->descriptors = $descriptors ? implode("\n",$descriptors) : '';
				
					$this->addDoc($result,$this->unindexedFields);
					$this->index->commit();
					$this->index->optimize();
				}
			}
		} catch (Exception $e) {
			throw new Exception($e->getMessage(), $e->getCode());
		}
	}
	
	public function deleteDocumentIndex($exerciseid){
		try {
			$verifySession = new SessionValidation(true);	
			$userid=$_SESSION['uid'];
			
			$sql = "SELECT e.id as exerciseId FROM exercise e WHERE e.id=%d AND e.fk_user_id=%d";
			$exercisedata = $this->conn->_singleSelect ($sql,$exerciseid,$userid);
			if($exercisedata){
				//Lucene doesn't support Document update, it must be deleted and added afterwards
				$this->delDoc($exerciseid);
			}
			$this->index->commit();
			$this->index->optimize();
		} catch (Exception $e) {
			throw new Exception($e->getMessage(), $e->getCode());
		}
	}

	/**
	 * Delete a document entry (exercise data set) from an already existing search index file
	 * 
	 * @param int $exerciseid
	 * 		The search index identifier (and also exercise identifier) that's going to be removed from the index file
	 */
	private function delDoc($exerciseid){
		//Load the lucene index file
		$this->initialize();
		$term = new Zend_Search_Lucene_Index_Term($exerciseid, 'exerciseid');
		$documentids = $this->index->termDocs($term);
		if($documentids){
			foreach ($documentids as $id) {
				$this->index->delete($id);
			}
		}
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
	 * Returns the descriptors of the provided exercise (if any)
	 * @param int $exerciseId
	 * 		The exercise id to check for descriptors
	 * @return mixed $dcodes
	 * 		An array of descriptor data. False when the exercise has no descriptors at all.
	 */
	private function getExerciseDescriptors($exerciseId,$exerciseLanguage=null){
		if(!$exerciseId)
			return false;
		$dcodes = false;
		$sql = "SELECT ed.*, ed18n.name
				FROM rel_exercise_descriptor red 
				INNER JOIN exercise_descriptor ed ON red.fk_exercise_descriptor_id=ed.id
				INNER JOIN exercise_descriptor_i18n ed18n ON ed.id=ed18n.fk_exercise_descriptor_id
				WHERE red.fk_exercise_id=%d";
		
		if($exerciseLanguage){
			$sql .= " AND ed18n.locale='%s'";
			$results = $this->conn->_multipleSelect($sql,$exerciseId,$exerciseLanguage);
		} else {
			$results = $this->conn->_multipleSelect($sql,$exerciseId);
		}
		
		if($results){
			$dcodes = array();
			foreach($results as $result){
				
				$dcode = sprintf("D%d_%d_%02d_%d %s", $result->situation, $result->level, $result->competence, $result->number, $result->name);
				$dcodes[] = $dcode;
			}
			unset($result);
		}
		return $dcodes;
	}
	
	private function getExerciseTags($exerciseid){
		require_once 'Exercise.php';
		$e = new Exercise();
		$results = $e->getExerciseTags($exerciseid);
		return $results;
	}
}

?>
