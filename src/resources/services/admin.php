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
	public function showMyGroups(){
		$groups= array();
        $sql = "select ID, name, description from groups where ID in 
                    (select DISTINCT fk_group_id from enrolment where role='teacher' and 
                        fk_user_id = %d)";
		$result = $this->conn->_multipleSelect($sql, $_SESSION['uid']);
        foreach($result as $key=>$group){
            array_push($groups, $group);
        }
        echo "<form name='groupsForm' action='admin.php' method='post'>";
        echo "Select your group:";
        echo "<select name='group'>";
        foreach($groups as $group){
            echo "<option value='$group->ID'>$group->name </option>";
        }
        echo "</select><p>";

        echo "<input type='hidden' name='action' value='showAddGroupMembers'>";
        echo "<input type='Submit' value='Show/Add members'>";
        echo "</form>";
        echo "<p><a href='admin.php'>Main menu</a>"; 
    }

    public function isTeacher(){
        $sql = "select fk_group_id
                from enrolment where role='teacher'
                and fk_user_id=%d LIMIT 1";
        $result = $this->conn->_singleSelect($sql, $_SESSION['uid']);
        if ($result)
            return true;
        else
            return false;
    }

    public function addNewGroup($name, $description){
        $sql = "insert into groups set ID='', name='%s', description='%s'";
        $lastId = $this->conn->_insert($sql, $name, $description);
        $this->assignUserToGroup($_SESSION['uid'], $lastId, "teacher");
 
        echo "Group correctly created";
        echo "<p><a href='admin.php'>Main menu</a>"; 
    }

    public function showNewGroup(){
        echo "<form name='groupsForm' action='admin.php' method='post'>";
        echo "Set a name for the new group: <input type='text' name='name'><br>"; 
        echo "Insert a description for the new group: <br><textarea name='description' cols=30 rows=5></textarea><br>";
        echo "<input type='hidden' name='action' value='addNewGroup'>";
        echo "<input type='Submit' value='Create Group'>";
        echo "</form>";
    }

    public function assignUsersToGroup($newMembers, $group, $role='student'){
        $text = trim($newMembers);
        $textAr = explode("\n", $text);
        $textAr = array_filter($textAr, 'trim'); // remove any extra \r characters left behind

        foreach ($textAr as $line) {
            $line = trim($line);
            $sql = "select u.id as ID from user u where u.email = '%s'";
            $res = $this->conn->_singleSelect($sql, $line);
            if ($res == null){
                echo "User " . $line . " not found. <br>\n"; 
               continue;
            }
            $this->assignUserToGroup($res->ID, $group, $role);
            echo "User " . $line . " correctly assigned. <br>\n";
        }
        echo "<form name='showAddUserForm' action='admin.php' method='post'>";
		echo "<input type='hidden' name='group' value='$group'>";
		echo "<input type='hidden' name='action' value='showAddGroupMembers'>";
		echo "<input type='Submit' value='Show Users of this group'>";
		echo "</form>";
		echo "<p><a href='admin.php'>Back to Administration Panel</a>"; 
    }

	public function assignUserToGroup($userid, $groupid, $role){
		$sql = "REPLACE INTO enrolment(fk_user_id, fk_group_id, role)
			VALUES (%d, %d, '%s')";
		$this->conn->_insert($sql, $userid,  $groupid, $role);
	}

	public function showOptions(){
		echo "<h1> Administration Panel </h1>";
		echo "<br><a href='?action=showMyGroups'>Show my Groups</a>";
		echo "<br><a href='?action=showNewGroup'>Add New Group</a>";
	}

	
	public function showAddGroupMembers($group){

		$users = array();

          $sql = "select ID, name, description 
                    from groups where ID = %d";

        $result = $this->conn->_singleSelect($sql, $group);
        $groupName = $result->name;
        $groupDescription = $result->description;
        echo "<h1>Group: $groupName - $groupDescription </h1>";

		$sql = "SELECT u.username as uname, u.ID as uid, u.email, e.role 
                FROM user u, enrolment e where e.fk_user_id = u.ID and fk_group_id=%d";
		$result = $this->conn->_multipleSelect($sql,$group);
		foreach($result as $key=>$user){
			array_push($users, $user);
		}
        echo "<table>";
        echo "<tr><td>uid</td><td>name</td><td>email</td><td>role</td></tr>";
		foreach($users as $user){
            echo "<tr>";

            if ($user->role == 'teacher') $newrole = 'student';
            else $newrole = 'teacher';

			echo "<td>$user->uid</td><td> $user->uname</td><td> $user->email</td><td> <a href='admin.php?action=changeRole&group=$group&user=$user->uid&role=$newrole'>$user->role</a></td>";
            echo "</tr>";  
      }
        echo "</table><p><h2>Assign new users to this group</h2>Insert one email per line.</h2><br>";
        echo "<form name='newMembersForm' action='admin.php' method='post'>";
        echo "<textarea name='newMembers' cols='40' rows='10'></textarea><br>";

		echo "<input type='hidden' name='group' value='$group'>";
		echo "<input type='hidden' name='action' value='assignUsersToGroup'>";
		echo "<input type='Submit' value='Assign Users To Group'>";
		echo "</form>";
		echo "<p><a href='admin.php'>Back to Administration Panel</a>";

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
		case 'showMyGroups':
				$admin->showMyGroups();
				break;		
        	case 'showNewGroup':
				$admin->showNewGroup();
				break;		
        	case 'changeRole':
				$admin->assignUserToGroup($_GET['user'],$_GET['group'], $_GET['role']);
                echo "<form name='showAddUserForm' action='admin.php' method='post'>";
                echo "<input type='hidden' name='group' value=".$_GET['group'].">";
                echo "<input type='hidden' name='action' value='showAddGroupMembers'>";
                echo "<input type='Submit' value='Show Users of this group'>";
                echo "</form>";
                echo "<p><a href='admin.php'>Back to Administration Panel</a>";
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
			case 'assignUsersToGroup':
				$admin->assignUsersToGroup($_POST['newMembers'], $_POST['group']);
				break;
			case 'showAddGroupMembers':
				$admin->showAddGroupMembers($_POST['group']);
				break;
			case 'addNewGroup':
				$admin->addNewGroup($_POST['name'], $_POST['description']);
				break;		
			default:
				echo "mmmhh... this shouldn't happen";
		}
	}

} // end if (we are running this on the webserver, not on cli)
?>
