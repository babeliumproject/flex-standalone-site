<?php

require_once ('Datasource.php');
require_once ('Config.php');
require_once ('UserVO.php');
require_once ('LoginVO.php');

class LoginDAO{
	
	private $conn;
	
	public function LoginDAO(){
		$settings = new Config();
		$this->conn = new DataSource($settings->host, $settings->db_name, $settings->db_username, $settings->db_password);
	}
	
	public function getUserInfo($username){
		if (!$username)
		{
			return false;
		}

		$sql = "SELECT id, name, email, creditCount FROM users WHERE (name = '%s') ";

		return $this->_singleQuery($sql, $username);
	}
	
	public function processLogin(LoginVO $user){
		if($this->getUserInfo($user->name)==false){
			return "wrong_user";
		} else {
			$sql = "SELECT id FROM users WHERE (name = '%s' AND active = 0)";
			$result = $this->_singleQuery($sql, $user->name);
			if ( $result )
				return "User inactive";
			$sql = "SELECT id, name, email, creditCount, realName, realSurname, active, joiningDate FROM users WHERE (name='%s' AND password='%s') ";
			$result = $this->_singleQuery($sql, $user->name, $user->pass);
			if($result){
				return $result;
			} else {
				return "wrong_password";
			}
		}
	}
	
	//Returns a single User object
	private function _singleQuery(){
		$valueObject = new UserVO();
		$result = $this->conn->_execute(func_get_args());

		$row = $this->conn->_nextRow($result);
		if ($row)
		{
			$valueObject->id = $row[0];
			$valueObject->name = $row[1];
			$valueObject->email = $row[2];
			$valueObject->creditCount = $row[3];
			$valueObject->realName = $row[4];
			$valueObject->realSurname = $row[5];
			$valueObject->active = $row[6];
			$valueObject->joiningDate = $row[7];
		}
		else
		{
			return false;
		}
		return $valueObject;
	}
}
?>