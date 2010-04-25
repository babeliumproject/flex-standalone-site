<?php

require_once ('Datasource.php');
require_once ('Config.php');
require_once ('NewUserVO.php');
require_once ('UserVO.php');

class RegisterUser{

	private $conn;
	private $settings;

	public function RegisterUser(){
		try{
			$this->settings = new Config();
			$this->conn = new Datasource($this->settings->host, $this->settings->db_name, $this->settings->db_username, $this->settings->db_password);
		} catch (Exception $e){
			throw new Exception($e->getMessage());
		}
	}

	public function register($user)
	{

		$sql = "SELECT prefValue FROM preferences WHERE ( prefName='initialCredits' )";

		$initialCredits = $this->_getInitialCreditsQuery($sql);

		$hash = $this->_createRegistrationHash();
		$insert = "INSERT INTO users (name, password, email, realName, realSurname, creditCount, activation_hash)";
		$insert .= " VALUES ('%s', '%s', '%s' , '%s', '%s', '%d', '%s' ) ";

		$realName = $user->realName? $user->realName : "unknown";
		$realSurname = $user->realSurname? $user->realSurname : "unknown";

		$result = $this->_create ( $user, $insert, $user->name, $user->pass, $user->email,
		$realName, $realSurname, $initialCredits, $hash );


		if ( $result != false )
		{
			//Add the languages selected by the user
			//$languages = $user->languages;
			//if (count($languages) > 0)
			//	$this->addUserLanguages($languages);


			// Submit activatión email
			include_once ('Mailer.php');

			$mail = new Mailer($user->name);
			$mail->send("http://".$_SERVER['HTTP_HOST']."/Main.html#/activation/activate/hash=".$hash."&user=".$user->name, "Activate account",
				"<a href='http://".$_SERVER['HTTP_HOST']."/Main.html#/activation/activate/hash=".$hash."&user=".$user->name."'>http://".$_SERVER['HTTP_HOST']."/Main.html#/activation/activate/hash=".$hash."&user=".$user->name."</a>");

			return $result;
		}

		return "User or email already exists";
	}

	//The parameter should be an array of UserLanguageVO
	public function addUserLanguages($languages) {

		$params = array();


		$sql = "INSERT INTO user_languages (fk_user_id, language, level) VALUES ";
		foreach($languages as $language) {
			$sql .= " ('%d', '%s', '%d'),";
			array_push($params, $language->userId, $language->language, $language->level);
		}
		unset($language);
		$sql = substr($sql,'',-1);
		// put sql query and all params in one array
		$merge = array_merge((array)$sql, $params);

		$result = $this->_vcreate($merge);
		return $result;

	}

	public function activate($user){


		$sql = "SELECT id FROM users WHERE (name = '%s' AND activation_hash = '%s') ";
		$result = $this->_getUserSingleQuery($sql, $user->name, $user->activationHash);

		if ( $result )
		{
			$sql = "UPDATE users SET active = 1, activation_hash = '' 
			        WHERE (name = '%s' AND activation_hash = '%s')";
			$update = $this->_databaseUpdate($sql, $user->name, $user->activationHash);
		}
		
		return ($result && $update);
	}

	private function _getUserSingleQuery(){
		$result = $this->conn->_execute(func_get_args());
		$row = $this->conn->_nextRow ($result);
		if ($row)
			return true;
		else
			return false;
	}


	public function _create() {
		$data = func_get_args();
		$user = array_shift($data); // remove User VO

		// Check user with same name or same email
		$sql = "SELECT ID FROM users WHERE (name='%s' OR email = '%s' ) ";
		$result = $this->conn->_execute($sql, $user->name, $user->email);
		$row = $this->conn->_nextRow($result);
		if ($row)
			return false;

		$this->conn->_execute( $data );

		$sql = "SELECT last_insert_id()";
		$result = $this->conn->_execute ( $sql );

		$row = $this->conn->_nextRow ( $result );
		if ($row) {
			$sql = "SELECT ID, name, email, creditCount FROM users WHERE (ID= '%d' ) ";

			$valueObject = new UserVO();
			$result = $this->conn->_execute($sql, $row[0]);

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

	private function _vcreate($params) {

		$this->conn->_execute ( $params );

		$sql = "SELECT last_insert_id()";
		$result = $this->conn->_execute ( $sql );

		$row = $this->conn->_nextRow ( $result );
		if ($row) {
			return $row [0];
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

	private function _getHashLength()
	{
		$sql = "SELECT prefValue FROM preferences WHERE ( prefName = 'hashLength' ) ";
		$result = $this->conn->_execute($sql);
		$row = $this->conn->_nextRow($result);
		if ($row)
			return $row[0];
		else
			return 20; // Default: avoiding crashes
	}

	private function _getHashChars()
	{
		$sql = "SELECT prefValue FROM preferences WHERE ( prefName = 'hashChars' ) ";
		$result = $this->conn->_execute($sql);
		$row = $this->conn->_nextRow($result);
		if ($row)
			return $row[0];
		else
			return "abcdefghijklmnopqrstuvwxyz0123456789-_"; // Default: avoiding crashes
	}

	private function _getInitialCreditsQuery($sql){
		$result = $this->conn->_execute($sql);

		$row = $this->conn->_nextRow($result);
		if ($row)
			return $row[0];
		else
			throw new Exception("An unexpected error occurred while trying to save your registration data.");
	}

	public function _databaseUpdate() {
		$result = $this->conn->_execute ( func_get_args() );

		return $result;
	}
}
?>
