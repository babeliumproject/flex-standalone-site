<?php
/**
 * Babelium Project open source collaborative second language oral practice - http://www.babeliumproject.com
 * 
 * Copyright (c) 2013 GHyM and by respective authors (see below).
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
require_once 'vo/UserVO.php';
session_start();
echo "<h1> Received exercises </h1>";

/**
 * 
 * @author Babelium Team
 *
 */
class Informe {

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
			$settings = new Config ( );
			$this->conn = new Datasource ( $settings->host, $settings->db_name, $settings->db_username, $settings->db_password );
			

		} catch (Exception $e) {
			throw new Exception($e->getMessage());
		}
	}

	public function showAttempts($userId){
		echo "Showing response attempts for user: " .$_SESSION['user-data']->name . " (id: $userId) <p>";
		echo "You can set one of these as your final answer (this step is optional; if you don't choose one of these, the system will automatically choose your last response as the final one) <p>"; 
		echo "If there isn't any response here but you can see your name in the <a href='/services/informe.php'>previous page</a>, don't worry, it's all OK (your recording is already in the evaluation area). <p>";
		
		$this->conn->_startTransaction();
		$sql = "SELECT file_identifier as video, response_attempt, id FROM user_videohistory where fk_user_id = %d AND incidence_date > '2013-12-08 00:00:00' and (file_identifier REGEXP 'resp' or file_identifier REGEXP 'up')";
		$result = $this->conn->_multipleSelect($sql, $userId);
		foreach($result as $key=>$video){
			echo "<a href='download.php?name=". $video->video . "'>" . $video->video . "</a>";
			if ($video->response_attempt != '2'){ // 2 = final, 1 = response attempt
				echo " &nbsp;<a href='?action=setfinal&id=".$video->id."'>[Set this as final answer]</a>";
			}else{
				echo " &nbsp;<font color='green'>Final answer</font>";
			}
			echo "<p>";
		}

		$this->conn->_endTransaction();
	 }

	public function setFinal($videoid){
	
		$this->conn->_startTransaction();
		$sql = "UPDATE user_videohistory
			set response_attempt=1
			where response_attempt=2 and fk_user_id=%d 
                        and incidence_date > '2013-12-08 00:00:00'";
		$this->conn->_update($sql, $_SESSION['uid']);

		$sql = "UPDATE user_videohistory
			set response_attempt=2
			where id=%d and fk_user_id=%d";
		$this->conn->_update($sql, $videoid,$_SESSION['uid']);
		$this->conn->_endTransaction();
		echo "Ok! <a href='?action=attempts'>Main menu</a>";
	}
	public function check()
	{

		if ($_SESSION['user-data']->name == ""){
			echo "Please, <a href='/'>log in</a> to view your response attempts <p>";
		}else{
		         echo "<a href='?action=attempts'>View my attempts (" . $_SESSION['user-data']->name . ")</a><p>"; 
		}

		$this->conn->_startTransaction();
		$sql = "(
			SELECT u.name AS name, e.title AS title, r.adding_date AS tmp_order
			FROM response AS r , users AS u, exercise AS e
			WHERE r.fk_user_id = u.ID  AND u.ID != 3 
			AND r.fk_exercise_id = e.id AND r.adding_date > '2013-10-01 00:00:00' )
			UNION
			( SELECT u.name AS name, e.title AS title, vh.incidence_date AS tmp_order
                        FROM user_videohistory as vh, users AS u, exercise AS e
                        WHERE vh.fk_user_id = u.ID AND u.ID != 3 
                        AND vh.fk_exercise_id = e.id AND vh.incidence_date > '2013-12-08 00:00:00' 
						AND vh.file_identifier REGEXP 'resp' )
			 ORDER BY tmp_order";

		$result = $this->conn->_multipleSelect($sql);
		echo "Total:" .  count($result) ."  <br>";
		foreach($result  as $key=>$user){
			echo "<b>User</b>: "; 
			echo $user->name;
			echo " <b>Exercise</b>: " . $user->title ; 
			echo " <b>Adding date</b>: " . $user->tmp_order . "\n <br>";
		}
		$this->conn->_endTransaction();
			
	}

}

 $informe = new Informe();

switch ($_GET['action']){

  case 'attempts':
      $informe->showAttempts($_SESSION['uid']);
      break;

  case 'setfinal':
      $informe->setFinal($_GET['id']);
      break;  

  default:
	 $informe->check();
}
?>
