<?php

require_once ('Datasource.php');
require_once ('Config.php');
require_once ('NewUserVO.php');
require_once ('UserVO.php');

class RegisterUser{
	
	private $conn;
	private $settings;
	
	public function RegisterUser(){
		$this->settings = new Config();
		$this->conn = new DataSource($this->settings->host, $this->settings->db_name, $this->settings->db_username, $this->settings->db_password);
	}

	public function register(NewUserVO $user) 
	{

		$hash = $this->_createRegistrationHash();
		$insert = "INSERT INTO users (ID, name, password, email, realName, realSurname, creditCount, activation_hash)";
		$insert .= " VALUES ('', '".$user->name."', '".$user->pass."', '".$user->email."' , '". $user->realName . "', '". $user->realSurname . "', 10, '";
		$insert .= $hash . "');";

		$result = $this->_create ( $insert, $user );
		
		if ( $result != false )
		{
			// Submit activatión email
			include_once ('Mailer.php');
			
			$mail = new Mailer($user->name);
			$mail->send("http://".$_SERVER['HTTP_HOST']."/activation.php?hash=".$hash."&user=".$user->name, "Activate account",
				"<a href='http://".$_SERVER['HTTP_HOST']."/activation.php?hash=".$hash."&user=".$user->name."'>http://".$_SERVER['HTTP_HOST']."/activation.php?hash=".$hash."&user=".$user->name."</a>");
			
			return $result;
		}

		return "user or email already exists";	
	}

	public function _create($data, $user) {
		// Check user with same name or same email
		$sql = "SELECT id FROM users WHERE name='". $user->name ."' OR email = '" . $user->email . "';";
		$result = $this->conn->_execute($sql);
		$row = $this->conn->_nextRow($result);
		if ($row)
			return false;

		$this->_databaseUpdate ( $data );
		
		$sql = "SELECT last_insert_id()";
		$result = $this->_databaseUpdate ( $sql );
		
		$row = $this->conn->_nextRow ( $result );
		if ($row) {
			$sql = "SELECT id, name, email, creditCount FROM users WHERE id=". $row[0];
			
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

		} else {
			return false;
		}
	}

	private function _createRegistrationHash()
	{
		$hash = "";
		$chars = $this->_getHashChars();
		$length = $this->_getHashLength();

		// Generate Hash
		for ( $i = 0; $i < $length; $i++ )
			$hash .= substr($chars, rand(0, strlen($chars)-1), 1);  // java: chars.charAt( random );

		return $hash;
	}
	
	function _databaseUpdate($sql) {
		$result = $this->conn->_execute ( $sql );
		
		return $result;
	}	
	
	private function _getHashLength()
	{
		$sql = "SELECT prefValue FROM preferences WHERE prefName = 'hashLength';"; 
		$result = $this->conn->_execute($sql);
		$row = $this->conn->_nextRow($result);
		if ($row)
			return $row[0];
		else
			return 20; // Default: avoiding crashes
	}
	
	private function _getHashChars()
	{
		$sql = "SELECT prefValue FROM preferences WHERE prefName = 'hashChars';"; 
		$result = $this->conn->_execute($sql);
		$row = $this->conn->_nextRow($result);
		if ($row)
			return $row[0];
		else
			return "abcdefghijklmnopqrstuvwxyz0123456789-_"; // Default: avoiding crashes
	}
}
?>
