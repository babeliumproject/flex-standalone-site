<?php

require_once 'utils/Config.php';
require_once 'utils/Datasource.php';
require_once 'utils/Mailer.php';
require_once 'utils/SessionHandler.php';

require_once 'vo/UserVO.php';
require_once 'vo/UserLanguageVO.php';
require_once 'vo/LoginVO.php';

class LoginDAO{

	private $conn;

	public function LoginDAO(){
		try {
			$verifySession = new SessionHandler();
			$settings = new Config();
			$this->conn = new DataSource($settings->host, $settings->db_name, $settings->db_username, $settings->db_password);
		} catch (Exception $e) {
			throw new Exception($e->getMessage());
		}
	}

	public function processLogin($user){
		//Check if the given username exists
		if($this->getUserInfo($user->name)==false){
			return "wrong_user";
		} else {
			//Check whether the user is active or not
			$sql = "SELECT id FROM users WHERE (name = '%s' AND active = 0)";
			$result = $this->_singleQuery($sql, $user->name);
			if ( $result )
			return "inactive_user";
			//Check if the user provided correct authentication data
			$sql = "SELECT id, name, creditCount, joiningDate, isAdmin FROM users WHERE (name='%s' AND password='%s') ";
			$result = $this->_singleQuery($sql, $user->name, $user->pass);
			if($result){
				$userId = $result->id;
				$userLanguages = $this->_getUserLanguages($userId);
				$this->_startUserSession($userId);

				$filteredResult = new UserVO();
				$filteredResult->name = $result->name;
				$filteredResult->creditCount = $result->creditCount;
				$filteredResult->joiningDate = $result->joiningDate;
				$filteredResult->isAdmin = $result->isAdmin;
				$filteredResult->userLanguages = $userLanguages;

				return $filteredResult;
			} else {
				return "wrong_password";
			}
		}
	}

	private function getUserInfo($username){
		if (!$username)
		{
			return false;
		}

		$sql = "SELECT id, name, creditCount FROM users WHERE (name = '%s') ";

		return $this->_singleQuery($sql, $username);
	}

	private function _singleQuery(){
		$valueObject = new UserVO();
		$result = $this->conn->_execute(func_get_args());

		$row = $this->conn->_nextRow($result);
		if ($row)
		{
			$valueObject->id = $row[0];
			$valueObject->name = $row[1];
			$valueObject->creditCount = $row[2];
			$valueObject->joiningDate = $row[3];
			$valueObject->isAdmin = $row[4] == 1;
		}
		else
		{
			return false;
		}
		return $valueObject;
	}

	public function doLogout(){
		try {
			$verifySession = new SessionHandler(true);
			$this->_resetSessionData();
			return true;
		} catch (Exception $e) {
			throw new Exception($e->getMessage());
		}
	}

	public function resendActivationEmail($user){
		if($this->getUserInfo($user->name)==false){
			return "wrong_user";
		} else {
			$sql = "SELECT id, activation_hash FROM users WHERE (name= '%s' AND email= '%s' AND active = 0 AND activation_hash <> '')";
			$inactiveUserExists = $this->_singleQueryInactiveUser($sql, $user->name, $user->email);
			if ($inactiveUserExists){
				$userId = $inactiveUserExists->id;
				$activationHash = $inactiveUserExists->hash;
				$userLanguages = $this->_getUserLanguages($userId);
				foreach($userLanguages as $lang){
					if($lang->level == 7){
						$usersFirstMotherTongue = $lang->language;
						break;
					}
				}
				// Submit activation email
				$mail = new Mailer($user->name);

				$subject = 'Babelium Project: Account Activation';

				$args = array(
						'PROJECT_NAME' => 'Babelium Project',
						'USERNAME' => $user->name,
						'PROJECT_SITE' => 'http://'.$_SERVER['HTTP_HOST'].'/Main.html#',
						'ACTIVATION_LINK' => 'http://'.$_SERVER['HTTP_HOST'].'/Main.html#/activation/activate/hash='.$activationHash.'&user='.$user->name,
						'SIGNATURE' => 'The Babelium Project Team');

				if ( !$mail->makeTemplate("mail_activation", $args, $usersFirstMotherTongue) ) return null;

				return $mail->send($mail->txtContent, $subject, $mail->htmlContent);
			} else {
				return "user_active_wrong_email";
			}
		}

	}

	private function _singleQueryInactiveUser(){
		$valueObject = new UserVO();
		$result = $this->conn->_execute(func_get_args());

		$row = $this->conn->_nextRow($result);
		if ($row)
		{
			$valueObject->id = $row[0];
			$valueObject->hash = $row[1];
		} else {
			return false;
		}
		return $valueObject;
	}

	private function _startUserSession($userId){

		$this->_setSessionData($userId);

		$sql = "INSERT INTO user_session (fk_user_id, session_id, session_date, duration, keep_alive)
				VALUES ('%d', '%s', now(), 0, 1)";
		return $this->_create($sql, $_SESSION['uid'], session_id());
	}

	private function _setSessionData($userId){
		//We are changing the privilege level, so we generate a new session id
		session_regenerate_id();
		$_SESSION['logged'] = true;
		$_SESSION['uid'] = $userId;
		$_SESSION['user-agent-hash'] = sha1($_SERVER['HTTP_USER_AGENT']);
		$_SESSION['user-addr'] = $_SERVER['REMOTE_ADDR'];
	}

	private function _resetSessionData(){
		//We are changing the privilege level, so first we generate a new session id
		session_regenerate_id();
		$_SESSION['logged'] = false;
		$_SESSION['uid'] = 0;
		$_SESSION['user-agent-hash'] = '';
		$_SESSION['user-addr'] = 0;
	}

	private function _getUserLanguages($userId){
		$sql = "SELECT language, level, positives_to_next_level, purpose
				FROM user_languages WHERE (fk_user_id='%d')";
		return $this->_listUserLanguagesQuery($sql, $userId);
	}



	private function _listUserLanguagesQuery(){
		$searchResults = array();

		$result = $this->conn->_execute(func_get_args());
		while($row = $this->conn->_nextRow($result)){
			$temp = new UserLanguageVO();
			$temp->language = $row[0];
			$temp->level = $row[1];
			$temp->positivesToNextLevel = $row[2];
			$temp->purpose = $row[3];

			array_push($searchResults, $temp);
		}
		return $searchResults;
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