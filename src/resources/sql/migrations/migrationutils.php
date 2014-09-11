<?php

if(!defined('CLI_SERVICE_PATH'))
	define('CLI_SERVICE_PATH', '/var/www/babelium/services');

require_once CLI_SERVICE_PATH . '/utils/Config.php';
require_once CLI_SERVICE_PATH . '/utils/Datasource.php';
require_once 'Zend/Json.php';

$CFG = new Config();
$DB = new Datasource($CFG->host, $CFG->db_name, $CFG->db_username, $CFG->db_password);

global $DB, $CFG;

/**
 * Retrieve current database structure
 *
 * @param String $dbname
 *
 * @return String $models
 */
function get_database_models($dbname){
	global $DB;
	$sql = "SHOW TABLES FROM %s";
	$tables = array();
	$table_data = $DB->_multipleSelect($sql,$dbname);
	foreach($table_data as $table){
		$tablename = $table->{'Tables_in_'.$dbname};
		$tables[$tablename] = get_table_model($tablename,$dbname);
	}
	$models = custom_json_encode($tables,0);
	return $models;
}

/**
 * Gets the current structure of a database table and returns it in an associative array
 *
 * @param String $tablename
 * @param String $dbname
 *
 * @return mixed $table_columns
 */
function get_table_model($tablename, $dbname){
	global $DB;
	$sql = "SHOW COLUMNS FROM %s FROM  %s";
	$column_data = $DB->_multipleSelect($sql,$tablename,$dbname);

	$sql = "SELECT k.constraint_name, k.column_name, k.ordinal_position, k.position_in_unique_constraint, k.referenced_table_name, k.referenced_column_name, r.update_rule, r.delete_rule
	FROM information_schema.KEY_COLUMN_USAGE k INNER JOIN information_schema.referential_constraints r on k.constraint_name = r.constraint_name
	WHERE k.table_name='%s' AND k.constraint_schema='%s' AND r.constraint_schema='%s'";
	$constraint_data = $DB->_multipleSelect($sql, $tablename, $dbname, $dbname);

	$sql = "SHOW INDEX FROM %s FROM %s";
	$index_data = $DB->_multipleSelect($sql, $tablename, $dbname);

	//Generate model object
	$table_columns = array();
	if($column_data){
		foreach ($column_data as $col){
			if(!array_key_exists($col->Field, $table_columns)){
				$table_columns[$col->Field] = array();
				//TODO add match for zerofill
				preg_match("/([\w]+)(\([\d]+\))?( unsigned)?/",$col->Type, $matches);
				$table_columns[$col->Field]['type'] = array();
				$table_columns[$col->Field]['type']['name'] = $matches[1];
				if(isset($matches[2]))
					$table_columns[$col->Field]['type']['size'] = trim(str_replace(')','',str_replace('(','',$matches[2])));
				if(isset($matches[3]))
					$table_columns[$col->Field]['type']['unsigned'] = true;
				$table_columns[$col->Field]['empty'] = $col->Null;
				$table_columns[$col->Field]['key'] = $col->Key;
				$table_columns[$col->Field]['default'] = $col->Default;
				$table_columns[$col->Field]['extra'] = $col->Extra;
			}
		}
	}else{
		//echo "No column info. found for ".$dbname.".".$tablename."\n";
	}

	if($constraint_data){
		foreach($constraint_data as $cd){
			if(array_key_exists($cd->column_name,$table_columns)){
				$constraint = array();
				$constraint['referenced_table'] = $cd->referenced_table_name;
				$constraint['referenced_column'] = $cd->referenced_column_name;
				$constraint['update_rule'] = $cd->update_rule;
				$constraint['delete_rule'] = $cd->delete_rule;
				$table_columns[$cd->column_name]['constraint'] = $constraint;
			}
		}
	}else{
		//echo "No constraint info. found for ".$dbname.".".$tablename."\n";
	}

	$table_indexes = array();
	if($index_data){
		foreach($index_data as $idata){
			if(!array_key_exists($idata->Key_name,$table_indexes)){
				$table_indexes[$idata->Key_name] = array();
				if($idata->Key_name == 'PRIMARY')
					$table_indexes[$idata->Key_name]['type'] = 'primary';
				else {
					$table_indexes[$idata->Key_name]['type'] = 'index';
				}
				$table_indexes[$idata->Key_name]['columns'] = $idata->Column_name;
			} else {
				$table_indexes[$idata->Key_name]['columns'] .= ",".$idata->Column_name;
			}
		}
		$table_indexes = array_values($table_indexes);
	} else {
		//echo "No index info. found for ".$dbname.".".$tablename."\n";
	}

	$table_columns['Meta'] = $table_indexes;

	return $table_columns;
}

/**
 * Encode the given array using Json
 *
 * @param Array $data
 * @param bool $prettyprint
 * @return mixed $data
 */
function custom_json_encode($data, $prettyprint=0){
	$data = Zend_Json::encode($data,false);
	$data = preg_replace_callback('/\\\\u([0-9a-f]{4})/i', create_function('$match', 'return mb_convert_encoding(pack("H*", $match[1]), "UTF-8", "UCS-2BE");'), $data);
	if($prettyprint)
		$data = Zend_Json::prettyPrint($data);
	return $data;
}