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

/**
 * 
 * @author Babelium Team
 *
 */
class Admin {

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

	public function impersonate($login){
		$_SESSION['uid']=$login;

		$this->conn->_startTransaction();
		$sql = "SELECT name FROM users where ID=$login";
		$result = $this->conn->_singleSelect($sql);
		$_SESSION['user-data']->name = $result->name;
		return $result->name;
	}
	public function addUser($login, $dni, $email, $realName, $realSurname){
		$pass = sha1($dni);

		$this->conn->_startTransaction();
		$sql = "INSERT INTO users (ID, name, password, email, realName, realSurname, creditCount, joiningDate, active, activation_hash, isAdmin) VALUES('', '%s', '%s', '%s', '%s', '%s', '1000', NOW(), '1', '', '0')";

		$id = $this->conn->_insert($sql, $login,$pass,$email,$realName,$realSurname);

		$sql = "INSERT INTO user_languages (id, fk_user_id, language, level, positives_to_next_level, purpose) VALUES('', %d, 'en_GB', '5', '15', 'practice')";
		$this->conn->_insert($sql, $id);

		$sql = "INSERT INTO user_languages (id, fk_user_id, language, level, positives_to_next_level, purpose) VALUES('', %d, 'es_ES', '7', '15', 'evaluate')";
		$this->conn->_insert($sql, $id);

		$sql="INSERT INTO user_languages (id, fk_user_id, language, level, positives_to_next_level, purpose) VALUES('', %d, 'en_GB', '5', '15', 'evaluate')";
		$this->conn->_insert($sql, $id);

		$sql= "INSERT INTO user_languages (id, fk_user_id, language, level, positives_to_next_level, purpose) VALUES('', %d, 'eu_ES', '7', '15', 'evaluate')";
		$this->conn->_insert($sql, $id);

		$this->conn->_endTransaction();

	}
	public function assignUserToGroup($userid, $groupid, $role){
		$this->conn->_startTransaction();
		$sql = "INSERT INTO enrolment(fk_user_id, fk_group_id, role)
			VALUES (%d, %d, '%s')";
		$this->conn->_insert($sql, $userid,  $groupid, $role);
		$this->conn->_endTransaction();
	}

	public function showOptions(){
		echo "<h1> Administration Panel </h1>";
		echo "<br><a href='?action=assign'>Assign User to Group</a>";
		echo "<br><a href='?action=add'>Add new User </a>";
		echo "<br><a href='?action=impersonate'>Log in as another user</a>";
		echo "<br><a href='?action=statistics'>Show statistics</a>";
		echo "<br><a href='?action=reloadResponsesCache'>Reload Responses Cache</a>";
		echo "<br><a href='informe.php?action=attempts'>Show specific user attempts</a>";
		echo "<br><a href='informe.php'>Show all users' attempts</a>";
		}

	public function showAddUser(){

		echo "<form name='assign' action='admin.php' method='post'>";
		echo "Login: <input type='text' name='login'><br>";
		echo "Dni: <input type='text' name='dni'><br>";
		echo "Email: <input type='text' name='email'><br>";
		echo "Real Name: <input type='text' name='realName'><br>";
		echo "Real Surname: <input type='text' name='realSurname'><br>";
		echo "<input type='hidden' name='action' value='add'>";
		echo "<input type='Submit' value='Save'>";
		echo "</form>";
		echo "<p><a href='admin.php'>Main menu</a>";
	}

	public function showImpersonate(){
		$users = array();

		$this->conn->_startTransaction();
		// $sql = "SELECT u.name as uname, u.ID as uid, g.ID as gid, g.name as gname, g.description FROM users AS u, enrolment as e, groups as g WHERE u.ID = e.fk_user_id and e.fk_group_id = g.ID";
		$sql = "SELECT u.name as uname, u.ID as uid FROM users AS u";
		$result = $this->conn->_multipleSelect($sql);
		foreach($result as $key=>$user){
			array_push($users, $user);
		}
		echo "<form name='impersonate' action='admin.php' method='post'>";
		echo "Seleccionar usuario:";
		echo "<select name='user'>";
		foreach($users as $user){
			echo "<option value='$user->uid'>$user->uname ($user->uid)</option>";
		}
		echo "</select><p>";

		echo "<input type='hidden' name='action' value='impersonate'>";
		echo "<input type='Submit' value='Save'>";
		echo "</form>";
		echo "<p><a href='admin.php'>Main menu</a>";
	
	}
	
	public function reloadResponsesCache(){

		$responsesDir = "/opt/red5/webapps/vod/streams/responses"; 
		$this->conn->_startTransaction();
		$handle = opendir($responsesDir);
		$filename = readdir($handle);

		if ($handle){
			while (false !== ($filename = readdir($handle))){
				if (!pathinfo($filename, PATHINFO_EXTENSION)=="flv" || preg_match("/merge/", $filename) || preg_match("/meta/",$filename))
					continue;
				$stat = stat($responsesDir . "/" .$filename);	
				$sql= "REPLACE INTO files (ID, name, mtime, size)
					VALUES('', '%s', %d, %f)";
				echo $filename . " " . $stat['mtime'] . " Size:" . round(($stat['size']/1024/1024),2) . "<br>";
				$this->conn->_insert($sql, $filename, $stat['mtime'], round(($stat['size']/1024/1024),2) /* size in MB*/ );
			}	
		}
		closedir($handle);
		$this->conn->_endTransaction();


		echo "<p><a href='admin.php'>Main menu</a>";
	}

	public function showStatistics(){
		$this->conn->_startTransaction();
		$sql = "SELECT * FROM berbetan.user_videohistory
			WHERE incidence_date > '2013-11-22 00:00:00'
			";
		$result = $this->conn->_multipleSelect($sql);
		foreach($result as $action){
			print_r($action);
			// search $action->incidence_date in /opt/red5/webapps/vod/streams/responses
		}

	}
	public function showUsersAndGroups(){

		$users = array();

		$this->conn->_startTransaction();
		// $sql = "SELECT u.name as uname, u.ID as uid, g.ID as gid, g.name as gname, g.description FROM users AS u, enrolment as e, groups as g WHERE u.ID = e.fk_user_id and e.fk_group_id = g.ID";
		$sql = "SELECT u.name as uname, u.ID as uid FROM users AS u";
		$result = $this->conn->_multipleSelect($sql);
		foreach($result as $key=>$user){
			array_push($users, $user);
		}
		echo "<form name='asignargrupo' action='admin.php' method='post'>";
		echo "Select user:";
		echo "<select name='user'>";
		foreach($users as $user){
			echo "<option value='$user->uid'>$user->uname</option>";
		}
		echo "</select><p>";

		echo "Select the group to assign user to:<br>";
		echo "Grupo A = Aintzane, B = Begoña, C = Begoña, D= Christian";
		echo "<select name='group'>";
		echo "<option value='1'>A</option>";
		echo "<option value='2'>B</option>";
		echo "<option value='3'>C</option>";
		echo "<option value='4'>D</option>";
		echo "</select><p>";

		echo "Rol: "; 
		echo "<select name='role'>";
		echo "<option value='student'>Student</option>";
		echo "<option value='teacher'>Teacher</option>";
		echo "</select><p>";

		echo "<input type='hidden' name='action' value='assign'>";
		echo "<input type='Submit' value='Save'>";
		echo "</form>";
		echo "<p><a href='admin.php'>Volver</a>";
	}

}

if(php_sapi_name() != 'cli' && !empty($_SERVER['REMOTE_ADDR'])) {
	$userData = $_SESSION['user-data'];
	if (!$userData->isAdmin)
		die("Go away!");

	$admin = new Admin();
	if (empty($_POST) && empty($_GET)){
		$admin->showOptions();

	} else if (empty($_POST)){ // there is something in GET

		switch ($_GET['action']){
			case 'add':
				$admin->showAddUser(); 
				break;
			case 'assign':
				$admin->showUsersAndGroups(); 
				break;
			case 'impersonate':
				$admin->showImpersonate(); 
				break;
			case 'statistics':
				$admin->showStatistics();
				break;
			case 'reloadResponsesCache':
				$admin->reloadResponsesCache();
				break;		
			default:
				echo "mmmh... this shouldn't happen";	
		}	

	} else { // there is something in POST

		switch($_POST['action']){
			case 'assign':
				$admin->assignUserToGroup($_POST['user'], $_POST['group'], $_POST['role'] );
				echo "Assignment completed. <a href='admin.php'>Main menu</a>";
				break;
			case 'add':
				$admin->addUser($_POST['login'], $_POST['dni'], $_POST['email'], $_POST['realName'],$_POST['realSurname'] );
				echo "User has been correctly added. <a href='admin.php'>Main menu</a>";
				break; 
			case 'impersonate':
				$name = $admin->impersonate($_POST['user']);
				echo "Now, your are working as $name <a href='admin.php'>Main menu</a>";
				break; 

			case 'reloadResponsesCache':
				$admin->reloadResponsesCache();	
				break;
			default:
				echo "mmmhh... this shouldn't happen";
		}
	}

} // end if (we are running this on the webserver, not on cli)
?>
