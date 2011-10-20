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

/**
 * Helper class to perform common MySQL database operations.
 * 
 * @author Babelium Team
 */
class Datasource
{
	
	private $dbLink;
	
	const FETCH_MODE_ASSOC = 'fetch_assoc';
	const FETCH_MODE_OBJECT = 'fetch_object';

	/**
	 * Constructor function
	 * Attempts to connect to the database using the provided parameters
	 * 
	 * @param string $dbHost
	 * 		Database host name
	 * @param string $dbName
	 * 		Database name
	 * @param string $dbuser
	 * 		User to access database
	 * @param string $dbpasswd
	 * 		Password to access database
	 */
	public function Datasource($dbHost, $dbName, $dbuser, $dbpasswd)
	{
		$this->dbLink = mysqli_connect ($dbHost, $dbuser, $dbpasswd);
		if(!$this->dbLink)
			$this->_checkConnectionErrors();

		$dbSelected = mysqli_select_db ($this->dbLink, $dbName);
		if(!$dbSelected)
			$this->_checkErrors();

		$dbCharsetSet = mysqli_set_charset($this->dbLink, 'utf8');
		if(!$dbCharsetSet)
			$this->_checkErrors();
	}
	
	/**
	 * Turn off the autocommit until several changes are made to the database.
	 * 
	 * WARNING: This can only be done on databases with InnoDB tables.
	 */
	public function _startTransaction(){
		mysqli_autocommit($this->dbLink,FALSE);
	}
	
	/**
	 * The transaction performed as expected. Commit all the changes and set the auto commit back to normal.
	 * 
	 * WARNING: This can only be done on databases with InnoDB tables.
	 */
	public function _endTransaction(){
		mysqli_commit($this->dbLink);
		mysqli_autocommit($this->dbLink,TRUE);
	}
	
	/**
	 * One or more queries in the current transaction didn't give the expected output. Undo all the changes so far.
	 */
	public function _failedTransaction(){
		mysqli_rollback($this->dbLink);
		mysqli_autocommit($this->dbLink,TRUE);
	}

	/**
	 * Analyzes the parameters of the caller and decides which way to handle them in the database query.
	 */
	public function _execute()
	{
		if ( is_array(func_get_arg(0)) )
			return $this->_vexecute(func_get_arg(0)); // Gets an array of parameters
		else
			return $this->_vexecute(func_get_args()); // Gets separate parameters
	}

	/**
	 * Cleans the given parameters from harmful sql injection trickeries and performs a query against the database
	 * 
	 * @param mixed $params
	 * 		Contains the SQL query string and one or more parameters for that query
	 * @return mixed $result
	 * 		The resultset containing the query results
	 */
	public function _vexecute($params)
	{
		$query = array_shift($params);

		for ( $i = 0; $i < count($params); $i++ )
		$params[$i] = mysqli_real_escape_string($this->dbLink, $params[$i]);

		$query = vsprintf($query, $params);

		$result = mysqli_query($this->dbLink, $query);
		if(!$result)
			$this->_checkErrors($query);

		return $result;
	}

	/**
	 * Retrieve the next line of data for the given resultset
	 * 
	 * @param mixed $result
	 * 		The resultset of a SQL query
	 * @return mixed $row
	 * 		Returns an array of strings that corresponds to the fetched row or NULL if there are no more rows in resultset. 
	 */
	public function _nextRow ($result)
	{
		$row = mysqli_fetch_array($result);
		return $row;
	}
	
	/**
	 * Retrieve the next line of data for the given resultSet as an associative array
	 * 
	 * @param mixed $result
	 * 		The resultset of a SQL query
	 * @return mixed $row
	 * 		Returns an associative array with the data of the next row of the resultSet or NULL if there are no more rows in resultset. 
	 */
	public function _nextRowAssoc($result){
		$row = mysqli_fetch_assoc($result);
		return $row;
	}
	
	/**
	 * Retrieve the next line of data for the given resultSet as an object
	 * 
	 * @param mixed $result
	 * 		The resultset of a SQL query
	 * @return mixed $row
	 * 		Returns an object with the data of the next row of the resultSet or NULL if there are no more rows in resultset. 
	 */
	public function _nextRowObject($result){
		$row = mysqli_fetch_object($result);
		return $row;
	}
	
	/**
	 * Perform a SQL Insert operation against the database
	 * 
	 * @return mixed $row
	 * 		Return the last id of the inserted data or false when no data was inserted at all
	 */
	public function _insert (){
		$this->_execute ( func_get_args() );

		$sql = "SELECT last_insert_id()";
		$result = $this->_execute ( $sql );

		$row = $this->_nextRow ( $result );
		if ($row) {
			return $row [0];
		} else {
			return false;
		}
	}
	
	/**
	 * Perform a SQL Select operation against the database
	 * @return mixed $result
	 * 		Returns an array of objects if the query had more than one row, an object if the query had only one row
	 *		and false if the query had no results at all.
	 */
	public function _select(){
		$rowList = array();
		$result = $this->_execute ( func_get_args() );
		while($row = $this->_nextRowObject($result)){
			if($row && is_object($row)){
				array_push($rowList, $row);
			}
		}
		if(!$rowList || count($rowList) == 0){
			$result = false;
		} 
		elseif (count($rowList) == 1){
			$result = $rowList[0];
		} else {
			$result = $rowList;
		}
		return $result;
	}
	
	/**
	 * Returns the number of rows affected by the last query
	 * 
	 * @return int $rows
	 * 		Returns the number of rows affected by the last query
	 */
	public function _affectedRows() {
		return mysqli_affected_rows($this->dbLink);
	}

	/**
	 * Checks if there's been any problem to connect to the database and logs the connection failures.
	 * 
	 * @throws Exception
	 * 		Returns a message telling there's been an error while trying to connect to the database
	 */
	private function _checkConnectionErrors(){
		$errno = mysqli_connect_errno();
		if($errno){
			error_log("Database connection error #".$errno.": ".mysqli_connect_error()."\n",3,"/tmp/db_error.log");
			throw new Exception("Database connection error.\n");
		} else {
			return;
		}

	}

	/**
	 * Checks SQL operation errors, rollbacks any ongoing transactions and logs all the data
	 * @param string $sql
	 * 		The faulty SQL query string
	 * @throws Exception
	 * 		Returns a message telling there's been an error while trying to perform an operation in the database
	 */
	private function _checkErrors($sql = "")
	{
		$errno = mysqli_errno($this->dbLink);
		$error = mysqli_error($this->dbLink);
		$sqlstate=mysqli_sqlstate($this->dbLink);

		if($sqlstate){
			//Rollback the uncommited changes just in case
			$this->_failedTransaction();
			error_log("Database error #" .$errno. " (".$sqlstate."): ".$error."\n",3,"/tmp/db_error.log");
			if($sql != "")
				error_log("Caused by the following SQL command: ".$sql."\n",3,"/tmp/db_error.log");
			throw new Exception("Database operation error.\n");
		}
		else
		{
			return;
		}
	}
}

?>