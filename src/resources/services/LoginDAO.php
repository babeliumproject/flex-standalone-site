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

		$sql = "SELECT id, name, email, creditCount FROM users WHERE (name = '". $username ."') ";

		return $this->_singleQuery($sql);
	}
	
	public function processLogin(LoginVO $user){
		if($this->getUserInfo($user->name)==false){
			return "wrong_user";
		} else {
			$sql = "SELECT id FROM users WHERE (name = '". $user->name ."' AND active = 0)";
			$result = $this->_singleQuery($sql);
			if ( $result )
				return "User inactive";
			$sql = "SELECT id, name, email, creditCount FROM users WHERE (name='". $user->name ."' AND password='". $user->pass ."') ";
			$result = $this->_singleQuery($sql);
			if($result){
				return $result;
			} else {
				return "wrong_password";
			}
		}
	}
	
	//Returns a single User object
	private function _singleQuery($sql){
		$valueObject = new UserVO();
		$result = $this->conn->_execute($sql);

		$row = $this->conn->_nextRow($result);
		if ($row)
		{
			$valueObject->id = $row[0];
			$valueObject->name = $row[1];
			$valueObject->email = $row[2];
			$valueObject->creditCount = $row[3];
		}
		else
		{
			return false;
		}
		return $valueObject;
	}
}
?>