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


/**
 * Course related requests are handled using this service class
 * 
 * @author Inko Perurena
 *
 */
class Course{
	
	private $db;
	
	/**
	 * Constructor method
	 * @throws Exception
	 * 		Throws an error if the session couldn't be set or the database connection couldn't be established
	 */
	public function __construct(){
		try {
			$verifySession = new SessionValidation(true);
			$settings = new Config();
			$this->db = new DataSource($settings->host, $settings->db_name, $settings->db_username, $settings->db_password);
		} catch (Exception $e) {
			throw new Exception($e->getMessage());
		}
	}
	
	
	/**
	 * Returns the list of courses in which the user is enrolled either as an instructor or as a learner
	 * 
	 * @param string $scope
	 * 		The scope of the requested course list. It can be either 'learn' or 'teach'. Users can be both
	 * 		instructors and learners in different contexts.
	 * @return mixed $list
	 * 		The list of courses the user is enrolled into
	 */
	public function getCourses($scope='learn'){
		return $this->getMyCourses($scope);
	}
	
	private function getMyCourses($scope='learn'){
		$rolearchetype = 3;
		
		$query = "SELECT * FROM course c INNER JOIN rel_course_role_user cr ON c.id=cr.fk_course_id
				  WHERE cr.fk_user_id=%d AND cr.fk_role_id=%d";
		
		$results = $this->db->_multipleSelect($query,$_SESSION['uid'], $rolearchetype);
		
		return $results;
	}
	
	/**
	 * Returns the list of exercises the user has recorded. 
	 * This should be placed in a special 'course' that belongs to the user but for the time being we are going to pull the contents of
	 * the response table.
	 */
	private function getMyExercises(){
		$myexercises = false;
		$query = "SELECT e.id
				  FROM response r INNER JOIN user u ON r.fk_user_id = u.id INNER JOIN exercise e ON r.fk_exercise_id = e.id
				  WHERE u.id = %d ORDER BY r.adding_date LIMIT 5";
		$results = $this->db->_multipleSelect($query, $_SESSION['uid']);
		if($results){
			$myexercises = array();
			require_once 'Exercise.php';
			$e = new Exercise();
			foreach($results as $result){
				array_push($myexercises, $e->getExerciseById($result->id));
			}
		}
		return $myexercises;
	}
	
	public function viewCourse($courseid){
		if(!$courseid) return false;
		
		$assignments = false;
		if($roleid = $this->checkPermissions($courseid)){
			$query = "SELECT * FROM assignment WHERE fk_course_id=%d ORDER BY duedate";
			$assignments = $this->db->_multipleSelect($query, $courseid);
		}
		return $assignments;
	}
	
	public function checkPermissions($courseid){
		$query = "SELECT cr.fk_role_id FROM course c INNER JOIN rel_course_role_user cr ON c.id=cr.fk_course_id WHERE c.id=%d and cr.fk_user_id=%d";
		return $this->db->_singleSelect($query, $courseid, $_SESSION['uid']);
	}
}