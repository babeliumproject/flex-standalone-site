<?php

/**
 * NOTE 1: Apply rev4fc981aa146b.sql incremental to your database first
 * NOTE 2: It is not a cron script
 * 
 * This file refactors current database data. It takes the exercise.tag field from each exercise
 * and splits its contents when ',' is found. This way the individual tags of the exercise are retrieved.
 * Then the script inserts those individual tags in the tag table (if they're not already there) and makes
 * a relationship between exercise/tag.
 * 
 */

if(!defined('CLI_SERVICE_PATH'))
	define('CLI_SERVICE_PATH', '/var/www/babelium/services');

require_once CLI_SERVICE_PATH . '/utils/Datasource.php';
require_once CLI_SERVICE_PATH . '/utils/Config.php';



$settings = new Config();
$conn = new Datasource($settings->host, $settings->db_name, $settings->db_username, $settings->db_password);

try{
$sql = "SELECT id, tags FROM exercise WHERE TRUE";

$resultSet = $conn->_multipleSelect($sql);

foreach($resultSet as $result){
	$tags = explode(',', $result->tags);
	foreach($tags as $tag){
		$cleanTag = strtolower(trim($tag));
		if(!empty($cleanTag)){
			//Check if this tag exists in the `tag` table
			$sql = "SELECT id FROM tag WHERE name='%s'";
			printf($sql."\n",$cleanTag);
			$exists = $conn->_singleSelect($sql, $cleanTag);
			if(!$exists){
				$insert = "INSERT INTO tag SET name='%s'";
				printf($insert."\n",$cleanTag);
				$tagId = $conn->_insert($insert, $cleanTag);
			} else {
				$tagId = $exists->id;
			}
			$sql = "SELECT fk_tag_id FROM rel_exercise_tag WHERE (fk_exercise_id=%d AND fk_tag_id=%d)";
			$exist = $conn->_singleSelect($sql, $result->id, $tagId);
			if(!$exists){
				$relInsert = "INSERT INTO rel_exercise_tag SET fk_exercise_id=%d, fk_tag_id=%d";
				printf($relInsert."\n", $result->id, $tagId);
				$conn->_insert($relInsert, $result->id, $tagId);
			} 
		}
	}
	unset($tag);
}
} catch(Exception $e){
	echo $e->getMessage()."\n";
}	


?>
