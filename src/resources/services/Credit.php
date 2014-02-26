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

require_once 'vo/CreditHistoryVO.php';

/**
 * This service should be available only to valid and authenticated users.
 * Credit related queries are stored in this service.
 * 
 * @author Babelium Team
 */
class Credit {
	
	private $conn;
	
	/**
	 * Constructor function
	 * 
	 * @throws Exception
	 * 		Throws an error if the one trying to access this class is not successfully logged in on the system 
	 * 		or there was any problem establishing a connection with the database.
	 */
	public function __construct() {

		try {
			$verifySession = new SessionValidation(true);
			$settings = new Config ( );
			$this->conn = new Datasource ( $settings->host, $settings->db_name, $settings->db_username, $settings->db_password );
		} catch (Exception $e) {
			throw new Exception($e->getMessage());
		}

	}
	
	/**
	 * Retrieves current user's credit activity of the current day 
	 * @return array $results
	 * 		An array of objects with the credit data or null if no credit data was found
	 */
	public function getCurrentDayCreditHistory() {
		$sql = "SELECT c.changeDate, c.changeType, c.changeAmount, c.fk_exercise_id as videoExerciseId, e.name as videoExerciseName, c.fk_response_id as videoResponseId, r.file_identifier as videoResponseName 
				FROM (((credithistory c INNER JOIN user u ON c.fk_user_id=u.id) INNER JOIN exercise e ON e.id=c.fk_exercise_id) LEFT OUTER JOIN response r on r.id=c.fk_response_id) 
				WHERE (c.fk_user_id = %d AND CURDATE() <= c.changeDate ) ORDER BY changeDate DESC ";
		
		return $this->conn->multipleRecast('CreditHistoryVO',$this->conn->_multipleSelect ( $sql, $_SESSION['uid'] ));
	}
	
	/**
	 * Retrieves current user's credit activity of the last week
	 * @return array $results
	 * 		An array of objects with the credit data or null if no credit data was found
	 */
	public function getLastWeekCreditHistory() {
		$sql = "SELECT c.changeDate, c.changeType, c.changeAmount, c.fk_exercise_id as videoExerciseId, e.name as videoExerciseName, c.fk_response_id as videoResponseId, r.file_identifier as videoResponseName 
				FROM (((credithistory c INNER JOIN user u ON c.fk_user_id=u.id) INNER JOIN exercise e ON e.id=c.fk_exercise_id) LEFT OUTER JOIN response r on r.id=c.fk_response_id) 
				WHERE (c.fk_user_id = %d AND DATE_SUB(CURDATE(),INTERVAL 7 DAY) <= c.changeDate ) ORDER BY changeDate DESC ";
		
		return $this->conn->multipleRecast('CreditHistoryVO',$this->conn->_multipleSelect ( $sql, $_SESSION['uid'] ));
	}
	
	/**
	 * Retrieves current user's credit activity of the last month
	 * @return array $results
	 * 		An array of objects with the credit data or null if no credit data was found
	 */
	public function getLastMonthCreditHistory() {
		$sql = "SELECT c.changeDate, c.changeType, c.changeAmount, c.fk_exercise_id as videoExerciseId, e.name as videoExerciseName, c.fk_response_id as videoResponseId, r.file_identifier as videoResponseName 
				FROM (((credithistory c INNER JOIN user u ON c.fk_user_id=u.id) INNER JOIN exercise e ON e.id=c.fk_exercise_id) LEFT OUTER JOIN response r on r.id=c.fk_response_id) 
				WHERE (c.fk_user_id = %d AND DATE_SUB(CURDATE(),INTERVAL 30 DAY) <= c.changeDate ) ORDER BY changeDate DESC ";
		
		return $this->conn->multipleRecast('CreditHistoryVO',$this->conn->_multipleSelect ( $sql, $_SESSION['uid'] ));
	}
	
	/**
	 * Retrieves current user's credit activity since he registered in the system
	 * @return array $results
	 * 		An array of objects with the credit data or null if no credit data was found
	 */
	public function getAllTimeCreditHistory() {
		$sql = "SELECT c.changeDate, c.changeType, c.changeAmount, c.fk_exercise_id as videoExerciseId, e.name as videoExerciseName, c.fk_response_id as videoResponseId, r.file_identifier as videoResponseName 
				FROM (((credithistory c INNER JOIN user u ON c.fk_user_id=u.id) INNER JOIN exercise e ON e.id=c.fk_exercise_id) LEFT OUTER JOIN response r on r.id=c.fk_response_id) 
				WHERE (c.fk_user_id = %d ) ORDER BY changeDate DESC ";

		return $this->conn->multipleRecast('CreditHistoryVO',$this->conn->_multipleSelect ( $sql, $_SESSION['uid'] ));
	}
}

?>
