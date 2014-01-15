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
require_once 'utils/EmailAddressValidator.php';
require_once 'utils/Mailer.php';
require_once 'utils/SessionValidation.php';

require_once 'vo/NewUserVO.php';
require_once 'vo/UserVO.php';

/**
 * This class performs signup and user activation operations
 *
 * @author Babelium Team
 *
 */
class Register{

	private $conn;
	private $settings;

	/**
	 * Constructor function
	 *
	 * @throws Exception
	 * 		Thrown if there is a problem establishing a connection with the database
	 */
	public function __construct(){
		try{
			$verifySession = new SessionValidation();
			$this->settings = new Config();
			$this->conn = new Datasource($this->settings->host, $this->settings->db_name, $this->settings->db_username, $this->settings->db_password);
		} catch (Exception $e){
			throw new Exception($e->getMessage());
		}
	}

	/**
	 * Sign-up a new user in the system
	 * 
	 * @param stdClass $user
	 * 		An object with the new user's data
	 * @throws Exception
	 * 		There was a problem inserting the data on the database or while sending the activation email to the user. Changes are rollbacked.
	 */
	public function register($user = null)
	{
		if(!$user)
			return 'empty_parameter';
		$validator = new EmailAddressValidator();
		if(!$validator->check_email_address($user->email)){
			return 'invalid_email';
		} else {
			$initialCredits = $this->_getInitialCreditsQuery();
			$hash = $this->_createRegistrationHash();

			try{
				$this->conn->_startTransaction();
					
				$insert = "INSERT INTO user (username, password, email, firstname, lastname, creditCount, activation_hash)";
				$insert .= " VALUES ('%s', '%s', '%s' , '%s', '%s', '%d', '%s' ) ";

				$firstname = $user->firstname ? $user->firstname : "unknown";
				$lastname = $user->lastname ? $user->lastname : "unknown";

				$result = $this->_create ($insert, $user->username, $user->pass, $user->email, $firstname, $lastname, $initialCredits, $hash);
				if ($result)
				{
					//Add the languages selected by the user
					$motherTongueLocale = 'en_US';
					$languages = $user->languages;
					if ($languages && is_array($languages) && count($languages) > 0){
						$languageInsertResult = $this->addUserLanguages($languages, $result->id);
						//We get the first mother tongue as message locale
						$motherTongueLocale = $languages[0]->language;
					}

					if($result && $languageInsertResult){
						$this->conn->_endTransaction();
					} else {
						throw new Exception("Error inserting user or adding user languages");
					}

					// Submit activation email
					$mail = new Mailer($user->name);

					$subject = 'Babelium Project: Account Activation';

					//$params = new stdClass();
					//$params->name = $user->name;
					//$params->activationHash = $hash;
					$activation_link = htmlspecialchars('http://'.$_SERVER['HTTP_HOST'].'/Main.html#/activation/activate/hash='.$hash.'&user='.$user->username);	

					$args = array(
						'PROJECT_NAME' => 'Babelium Project',
						'USERNAME' => $user->username,
						'PROJECT_SITE' => 'http://'.$_SERVER['HTTP_HOST'],
						'ACTIVATION_LINK' => $activation_link,
						'SIGNATURE' => 'The Babelium Project Team');

					if ( !$mail->makeTemplate("mail_activation", $args, $motherTongueLocale) )
						return "error_sending_email";

					$mail = $mail->send($mail->txtContent, $subject, $mail->htmlContent);

					return $this->conn->recast('UserVO',$result);
				}
				return "error_user_email_exists";
			} catch (Exception $e){
				$this->conn->_failedTransaction();
				return "error_registering_user";
			}
		}
	}

	/**
	 * Adds a set of languages to the user's profile
	 * 
	 * @param array $languages
	 * 		An array of stdClass with information about each language the user has added to his/her profile
	 * @param int $userId
	 * 		The user id for the provided languages
	 * 
	 * @return int $result
	 * 		The user language id of the latest added user language. False on error.
	 */
	private function addUserLanguages($languages, $userId) {
		$positivesToNextLevel = $this->_getPositivesToNextLevel();

		$params = array();

		$sql = "INSERT INTO user_languages (fk_user_id, language, level, purpose, positives_to_next_level) VALUES ";
		foreach($languages as $language) {
			$sql .= " ('%d', '%s', '%d', '%s', '%d'),";
			array_push($params, $userId, $language->language, $language->level, $language->purpose, $positivesToNextLevel);
		}
		unset($language);
		$sql = substr($sql,0,-1);
		// put sql query and all params in one array
		$merge = array_merge((array)$sql, $params);

		$result = $this->conn->_insert($merge);
		return $result;

	}

	/**
	 * Activates the user profile so that the user is able to use the system
	 * 
	 * @param stdClass $user
	 * 		An object with user data that allows us to enable it's profile
	 * 
	 * @result mixed
	 * 		The prefered interface language of the just-activated user. Null on error.
	 */
	public function activate($user = null){

		if(!$user)
			return false;

		$sql = "SELECT language
				FROM user AS u INNER JOIN user_languages AS ul ON u.id = ul.fk_user_id 
				WHERE (u.username = '%s' AND u.activation_hash = '%s') LIMIT 1";
		$result = $this->conn->_singleSelect($sql, $user->name, $user->activationHash);

		if ( $result )
		{
			$sql = "UPDATE user SET active = 1, activation_hash = ''
			        WHERE (username = '%s' AND activation_hash = '%s')";
			$update = $this->conn->_update($sql, $user->username, $user->activationHash);
		}

		return ($result && $update)? $result->language : NULL ;
	}


	/**
	 * Inserts the new user data while checking of the username or email is duplicated
	 * 
	 * @param String $insert
	 * @param String $userName
	 * @param String $userPass
	 * @param String $userEmail
	 * @param String $userFirstname
	 * @param String $userLastname
	 * @param int $userInitialCredits
	 * @param String $userHash
	 * 
	 * @return int $result
	 * 		The latest inserted user id. False on error.
	 */
	private function _create($insert, $userName, $userPass, $userEmail, $userFirstname, $userLastname, $userInitialCredits, $userHash) {
		// Check user with same name or same email
		$sql = "SELECT id FROM user WHERE (username='%s' OR email = '%s' ) ";
		$result = $this->conn->_singleSelect($sql, $userName, $userEmail);
		if ($result)
			return false;
		
		$userId = $this->conn->_insert( $insert, $userName, $userPass, $userEmail, $userFirstname, $userLastname, $userInitialCredits, $userHash );
		if($userId){
			$sql = "SELECT id, username, email, password, creditCount FROM user WHERE (id=%d) ";
			$result = $this->conn->_singleSelect($sql,$userId);
			return $result;
		} else {
			return false;
		}
	}

	/**
	 * Generates a pseudo-random activation hash for the activation process
	 * 
	 * @return String $hash
	 * 		The random activation hash
	 */
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

	/**
	 * Retrieves the activation hash length from the preferences table of the application
	 *
	 * @return int $result
	 * 		Returns the value of the preference table. Returns 20 by default when the query fails
	 */
	private function _getHashLength()
	{
		$sql = "SELECT prefValue FROM preferences WHERE ( prefName = 'hashLength' ) ";
		$result = $this->conn->_singleSelect($sql);
		return $result ? $result->prefValue : 20;
	}

	/**
	 * Retrieves the subset of characters allowed to create the activation hash
	 * 
	 * @return String $result
	 * 		Returns the value of the preference table. Returns a default set of characters when the query fails.
	 */
	private function _getHashChars()
	{
		$sql = "SELECT prefValue FROM preferences WHERE ( prefName = 'hashChars' ) ";
		$result = $this->conn->_singleSelect($sql);
		return $result ? $result->prefValue : "abcdefghijklmnopqrstuvwxyz0123456789-_"; // Default: avoiding crashes
	}

	/**
	 * Get the initial amount of credits granted to new users
	 * 
	 * @return int
	 * 		The initial amount of credits granted to the user
	 * @throws Exception
	 * 		There was a problem while querying the database
	 */
	private function _getInitialCreditsQuery(){
		$sql = "SELECT prefValue FROM preferences WHERE ( prefName='initialCredits' )";
		$result = $this->conn->_singleSelect($sql);
		if($result){
			return $result->prefValue;
		} else {
			throw new Exception("An unexpected error occurred while trying to save your registration data.");
		}
	}

	/**
	 * Retrieves the amount of positive assessments an user has to receive in order to increase the knowledge level he/she has in a particular language
	 * 
	 * @return int
	 * 		The amount of positive reviews needed to get to the next level of a language
	 * @throws Exception
	 * 		There was a problem while querying the database
	 */
	private function _getPositivesToNextLevel(){
		$sql = "SELECT prefValue FROM preferences WHERE ( prefName='positives_to_next_level' )";
		$result = $this->conn->_singleSelect($sql);
		if($result){
			return $result->prefValue;
		} else {
			throw new Exception("Unexpected error while trying to retrieve preference data");
		}
	}
}
?>
