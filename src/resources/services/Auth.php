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
require_once 'utils/Mailer.php';
require_once 'utils/SessionValidation.php';

require_once 'vo/UserVO.php';
require_once 'vo/UserLanguageVO.php';
require_once 'vo/LoginVO.php';

/**
 * Allows the user to authenticate on the Babelium system
 *
 * @author Babelium Team
 *
 */
class Auth{

	private $conn;
	
	/**
	 * Constructor method
	 * @throws Exception
	 * 		Throws an error if the session couldn't be set or the database connection couldn't be established
	 */
	public function __construct(){
		try {
			$verifySession = new SessionValidation();
			$settings = new Config();
			$this->conn = new DataSource($settings->host, $settings->db_name, $settings->db_username, $settings->db_password);
		} catch (Exception $e) {
			throw new Exception($e->getMessage());
		}
	}
	
	/**
	 * Generates a random communication token that will be used in the following API calls.
	 * This is loosely-based on the JS authentication protocol used by Grooveshark
	 * 
	 * @param String $secretKey
	 * 		The client sends a MD5 hash of the PHPSESSID, which should be 13 characters long
	 * @return boolean|string
	 * 		The random communication token. False when there's no active session or the $secretKey
	 * 		has the wrong length, it's not of this session
	 */
	public function getCommunicationToken($secretKey = 0){
		if(!$secretKey)
			return FALSE;
			
		//Check if the request if made via HTTPS or not
		//TODO

		$length = 13;

		if(session_id() != "" && md5(session_id()) == $secretKey){
			$commToken = $this->_generateRandomCommunicationToken($length);
			$_SESSION['commToken'] = $commToken;
			return $commToken;
		} else {
			return FALSE;
		}
	}

	/**
	 * Returns an hexadecimal random token of the specified length
	 * 
	 * @param int $length
	 * 		The length of the token to generate
	 * @return String $token
	 * 		A random token of the specified length
	 */
	private function _generateRandomCommunicationToken($length){
		$token = '';
		$i = 0;
		while ($i < $length){
			$token = $token . dechex(floor((rand(0,1000000) * 16)/1000000));
			$i++;
		}
		return $token;
	}


	/**
	 * Checks the provided authentication data and logs the user in the system if everything is ok
	 *
	 * @param stdClass $user
	 * 		An object with the following properties: (username, password)
	 * @return mixed $result
	 * 		Returns the current user data. Or an error message when wrong login data is provided
	 */
	public function processLogin($user = null){
		if($user && is_object($user)){
			//Check if the given username exists
			if($this->getUserInfo($user->username)==false){
				return "wrong_user";
			} else {
				//Check whether the user is active or not
				$sql = "SELECT id FROM user WHERE (username = '%s' AND active = 0)";
				$result = $this->conn->_singleSelect($sql, $user->username);
				if ( $result )
				return "inactive_user";
				//Check if the user provided correct authentication data
				$sql = "SELECT id, username, firstname, lastname, email, creditCount, joiningDate, isAdmin FROM users WHERE (name='%s' AND password='%s') ";
				$result = $this->conn->_singleSelect($sql, $user->username, $user->password);
				if($result){
					$userLanguages = $this->_getUserLanguages($result->id);
					$result->userLanguages = $userLanguages;
					
					$userData = $this->conn->recast('UserVO', $result);
					
					$this->_startUserSession($userData);

					//Don't send back the user's id
					$userData->id = null;

					return $userData;
				} else {
					return "wrong_password";
				}
			}
		} else {
			if( $this->checkSessionLogin() && isset($_SESSION['user-data']) && !empty($_SESSION['user-data']) && is_object($_SESSION['user-data']) ){
				$loggedUser = $_SESSION['user-data'];
				$loggedUser->id = 0;
				return $loggedUser;
			} else {
				return "unauthorized";
			}
		}
	}

	/**
	 * Checks if the session data is set for this user
	 *
	 * @return boolean $isuserLogged
	 * 		Returns whether the user is logged or not based on the session data
	 */
	private function checkSessionLogin(){

		$isUserLogged = false;

		//The user authenticated on this session and still hasn't asked for logout
		if(isset($_COOKIE['PHPSESSID']) &&  $_COOKIE['PHPSESSID'] == session_id() && isset($_SESSION['logged']) && $_SESSION['logged'] == true){
			$isUserLogged = true;
		}
		//The user has a cookie with a valid expiry date and there's a record on the database that remembers this user token
		//if($_COOKIE['usrtkn'] != '' $_COOKIE['usrtkn'][])
		return $isUserLogged;
	}

	/**
	 * Retrieves the data for the given user name
	 *
	 * @param string $username
	 * @return mixed $result
	 * 		Returns an object with the user data or false when no user with that username is found in the database.
	 */
	private function getUserInfo($username){
		if (!$username)
		{
			return false;
		}

		$sql = "SELECT id, username, firstname, lastname, email, creditCount FROM users WHERE (username = '%s') ";

		return $this->conn->_singleSelect($sql, $username);
	}

	/**
	 * Logs the user out and clears the session data
	 * @return boolean
	 * 		Returns true if the logout when alright
	 * @throws Exception
	 * 		Throws an exception when the logout couldn't be properly done
	 */
	public function doLogout(){
		try {
			$verifySession = new SessionValidation(true);
			$this->_resetSessionData();
			return true;
		} catch (Exception $e) {
			throw new Exception($e->getMessage());
		}
	}

	/**
	 * Sends again the account activation email if the provided user is valid and not active.
	 *
	 * @param stdClass $user
	 * 		An object with the following properties: (username, email)
	 * @return string $mailSent
	 * 		Returns a string telling whether the mail sending operation went well or not
	 */
	public function resendActivationEmail($user = null){
		if(!$user)
			return null;
		
		if($this->getUserInfo($user->username)==false){
			return "wrong_user";
		} else {
			$sql = "SELECT id, activation_hash FROM user WHERE (username= '%s' AND email= '%s' AND active = 0 AND activation_hash <> '')";
			$inactiveUserExists = $this->conn->_singleSelect($sql, $user->username, $user->email);
			if ($inactiveUserExists){
				$usersFirstMotherTongue = 'en_US';
				$userId = $inactiveUserExists->id;
				$activationHash = $inactiveUserExists->activation_hash;
				$userLanguages = $this->_getUserLanguages($userId);
				if($userLanguages){
					foreach($userLanguages as $lang){
						if($lang->level == 7){
							$usersFirstMotherTongue = $lang->language;
							break;
						}
					}
				}
				// Submit activation email
				$mail = new Mailer($user->username);

				$subject = 'Babelium Project: Account Activation';

				$args = array(
						'PROJECT_NAME' => 'Babelium Project',
						'USERNAME' => $user->username,
						'PROJECT_SITE' => 'http://'.$_SERVER['HTTP_HOST'].'/Main.html#',
						'ACTIVATION_LINK' => 'http://'.$_SERVER['HTTP_HOST'].'/Main.html#/activation/activate/hash='.$activationHash.'&user='.$user->username,
						'SIGNATURE' => 'The Babelium Project Team');

				if ( !$mail->makeTemplate("mail_activation", $args, $usersFirstMotherTongue) )
					return null;

				return $mail->send($mail->txtContent, $subject, $mail->htmlContent);
			} else {
				return "user_active_wrong_email";
			}
		}
	}

	/**
	 * Initializes a session for this user.
	 *
	 * @param stdClass $userData
	 * 		An object with the following properties: (id, username, firstname, lastname, email, creditCount, joiningDate, isAdmin, userLanguages[])
	 * @return int $result
	 * 		Returns the last insert id if the session storing went well or false when something went wrong
	 */
	private function _startUserSession($userData){

		$this->_setSessionData($userData);

		$sql = "INSERT INTO user_session (fk_user_id, session_id, session_date, duration, keep_alive)
				VALUES ('%d', '%s', now(), 0, 1)";
		return $this->conn->_insert($sql, $_SESSION['uid'], session_id());
	}

	/**
	 * Stores current user's data in the session variable
	 *
	 * @param stdClass $userData
	 * 		An object with the following properties: (id, name, realName, realSurname, email, creditCount, joiningDate, isAdmin, userLanguages[])
	 */
	private function _setSessionData($userData){
		//We are changing the privilege level, so we generate a new session id
		if(!headers_sent())
			session_regenerate_id();
		$_SESSION['logged'] = true;
		$_SESSION['uid'] = $userData->id;
		$_SESSION['user-agent-hash'] = sha1($_SERVER['HTTP_USER_AGENT']);
		$_SESSION['user-addr'] = $_SERVER['REMOTE_ADDR'];
		$_SESSION['user-data'] = $userData;
		$_SESSION['user-languages'] = $userData->userLanguages;
	}

	/**
	 * Clears the user data from the session variable
	 */
	private function _resetSessionData(){
		//We are changing the privilege level, so first we generate a new session id
		if(!headers_sent())
			session_regenerate_id();
		$_SESSION['logged'] = false;
		$_SESSION['uid'] = 0;
		$_SESSION['user-agent-hash'] = '';
		$_SESSION['user-addr'] = 0;
		$_SESSION['user-data'] = null;
		$_SESSION['user-languages'] = null;
	}

	/**
	 * Retrieves the languages the user choose to use in Babelium
	 * @param int $userId
	 * 		The user identification number
	 * @return array $result
	 * 		Returns an array of languages or null when nothing found
	 */
	private function _getUserLanguages($userId){
		$sql = "SELECT language,
					   level, 
					   positives_to_next_level as positivesToNextLevel, 
					   purpose
				FROM user_languages WHERE (fk_user_id='%d')";
		return $this->conn->multipleRecast('UserLanguageVO',$this->conn->_multipleSelect($sql, $userId));
	}

}
?>
