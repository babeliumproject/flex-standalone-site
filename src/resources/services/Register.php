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
require_once 'utils/SessionHandler.php';

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

	public function Register(){
		try{
			$verifySession = new SessionHandler();
			$this->settings = new Config();
			$this->conn = new Datasource($this->settings->host, $this->settings->db_name, $this->settings->db_username, $this->settings->db_password);
		} catch (Exception $e){
			throw new Exception($e->getMessage());
		}
	}

	public function register($user = null)
	{
		if(!$user)
			return 'error_no_parameters';
		$validator = new EmailAddressValidator();
		if(!$validator->check_email_address($user->email)){
			return 'wrong_email';
		} else {
			$initialCredits = $this->_getInitialCreditsQuery();
			$hash = $this->_createRegistrationHash();

			try{
				$this->conn->_startTransaction();
					
				$insert = "INSERT INTO users (name, password, email, realName, realSurname, creditCount, activation_hash)";
				$insert .= " VALUES ('%s', '%s', '%s' , '%s', '%s', '%d', '%s' ) ";

				$realName = $user->realName? $user->realName : "unknown";
				$realSurname = $user->realSurname? $user->realSurname : "unknown";

				$result = $this->_create ($insert, $user->name, $user->pass, $user->email,$realName, $realSurname, $initialCredits, $hash);
				if ($result)
				{
					//Add the languages selected by the user
					$motherTongueLocale = 'en_US';
					$languages = $user->languages;
					if ($languages && is_array($languages) && count($languages) > 0){
						$languageInsertResult = $this->addUserLanguages($languages, $result);
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

					$params = new stdClass();
					$params->name = $user->name;
					$params->activationHash = $hash;
					$activation_link = urlencode(htmlspecialchars('http://'.$_SERVER['HTTP_HOST'].'/?module=register&action=activate&params='.base64_encode(json_encode($params))));

					$args = array(
						'PROJECT_NAME' => 'Babelium Project',
						'USERNAME' => $user->name,
						'PROJECT_SITE' => 'http://'.$_SERVER['HTTP_HOST'],
						'ACTIVATION_LINK' => $activation_link,
						'SIGNATURE' => 'The Babelium Project Team');

					if ( !$mail->makeTemplate("mail_activation", $args, $motherTongueLocale) )
						return false;

					$mail = $mail->send($mail->txtContent, $subject, $mail->htmlContent);

					return $this->conn->recast('UserVO',$result);
				}
				return "user_email_already_registered";
			} catch (Exception $e){
				$this->conn->_failedTransaction();
				return "error_registering_user";
			}
		}
	}

	//The parameter should be an array of UserLanguageVO
	private function addUserLanguages($languages, $userId) {
		$positivesToNextLevel = $this->_getPositivesToNextLevel($sql);

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

	public function activate($user = null){

		if(!$user)
			return false;

		$sql = "SELECT language
				FROM users AS u INNER JOIN user_languages AS ul ON u.id = ul.fk_user_id 
				WHERE (u.name = '%s' AND u.activation_hash = '%s') LIMIT 1";
		$result = $this->conn->_singleSelect($sql, $user->name, $user->activationHash);

		if ( $result )
		{
			$sql = "UPDATE users SET active = 1, activation_hash = ''
			        WHERE (name = '%s' AND activation_hash = '%s')";
			$update = $this->conn->_update($sql, $user->name, $user->activationHash);
		}

		return ($result && $update)? $result->language : NULL ;
	}


	private function _create($insert, $userName, $userPass, $userEmail, $userRealName, $userRealSurname, $userInitialCredits, $userHash) {

		// Check user with same name or same email
		$sql = "SELECT ID FROM users WHERE (name='%s' OR email = '%s' ) ";
		$result = $this->conn->_singleSelect($sql, $userName, $userEmail);
		if ($result)
		return false;

		$result = $this->conn->_insert( $insert, $userName, $userPass, $userEmail, $userRealName, $userRealSurname, $userInitialCredits, $userHash );

		return $result;
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
		$result = $this->conn->_singleSelect($sql);
		return $result ? $result->prefValue : 20;
	}

	private function _getHashChars()
	{
		$sql = "SELECT prefValue FROM preferences WHERE ( prefName = 'hashChars' ) ";
		$result = $this->conn->_singleSelect($sql);
		return $result ? $result->prefValue : "abcdefghijklmnopqrstuvwxyz0123456789-_"; // Default: avoiding crashes
	}

	private function _getInitialCreditsQuery(){
		$sql = "SELECT prefValue FROM preferences WHERE ( prefName='initialCredits' )";
		$result = $this->conn->_singleSelect($sql);
		if($result){
			return $result->prefValue;
		} else {
			throw new Exception("An unexpected error occurred while trying to save your registration data.");
		}
	}

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
