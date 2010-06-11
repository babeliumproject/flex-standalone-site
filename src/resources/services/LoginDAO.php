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
			$sql = "SELECT id, name, email, creditCount, realName, realSurname, active, joiningDate, isAdmin FROM users WHERE (name='%s' AND password='%s') ";
			$result = $this->_singleQuery($sql, $user->name, $user->pass);
			if($result){
				$this->_startUserSession($result->id);
				return $result;
			} else {
				return "wrong_password";
			}
		}
	}
	
	private function _startUserSession($userId){
		
		//Initialize session
		session_start();
		$sessionId = session_id();
		
		//Check that there's not another active session for this user
		$sql = "SELECT * FROM user_session WHERE ( session_id = '%s' AND fk_user_id = '%d' AND closed = 0 )";
		$result = $this->conn->_execute ( $sql, $sessionId, $userId );
		$row = $this->conn->_nextRow($result);
		if(!$row){
			//Generate a new session id and remove previous data (if any)
			session_regenerate_id(true);
			$sessionId = session_id();
		
			$sql = "INSERT INTO user_session (fk_user_id, session_id, session_date, duration, keep_alive) 
					VALUES ('%d', '%s', now(), 0, 1)";
			$result = $this->_create($sql, $userId, $sessionId);
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
			$valueObject->isAdmin = $row[8] == 1;
		}
		else
		{
			return false;
		}
		return $valueObject;
	}
	
	private function _create() {

		$this->conn->_execute ( func_get_args() );

		$sql = "SELECT last_insert_id()";
		$result = $this->conn->_execute ( $sql );

		$row = $this->conn->_nextRow ( $result );
		if ($row) {
			return $row [0];
		} else {
			return false;
		}
	}
	
}
?>