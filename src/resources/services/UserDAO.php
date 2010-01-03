<?php

require_once ('Datasource.php');
require_once ('Config.php');
require_once ('UserVO.php');


/**
 * This class is used to make queries related to an VO object. When the results
 * are stored on our VO class AMFPHP parses this data and makes it available for
 * AS3/Flex use.
 *
 * It must be placed under amfphp's services folder, once we have successfully
 * installed amfphp's files in apache's web folder.
 *
 */
class UserDAO {
	private $conn;

	public function UserDAO(){
		$settings = new Config();
		$this->conn = new Datasource($settings->host, $settings->db_name, $settings->db_username, $settings->db_password);
	}

	public function getTopTenCredited()
	{
		$sql = "SELECT id, name, email, creditCount FROM users AS U WHERE U.active = 1 ORDER BY creditCount DESC LIMIT 10 ";

		$searchResults = $this->_listQuery($sql);

		return (count($searchResults))? $searchResults : false ;
	}

	public function getUserInfo($userId){
		if (!$userId)
		{
			return false;
		}

		$sql = "SELECT id, name, email, creditCount FROM users WHERE (id = '". $userId ."') ";

		return $this->_singleQuery($sql);
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
	
	//Returns an array of Users
	private function _listQuery($sql)
	{
		$searchResults = array();
		$result = $this->conn->_execute($sql);

		while ($row = $this->conn->_nextRow($result))
		{
			$temp = new UserVO();
			$temp->id = $row[0];
			$temp->name = $row[1];
			$temp->email = $row[2];
			$temp->creditCount = $row[3];
			array_push($searchResults, $temp);
		}

		return $searchResults;
	}

	private function _databaseUpdate($sql)
	{
		$result = $this->conn->_execute($sql);

		return $result;
	}
	
	public function restorePass($username)
	{
		$id = -1;
		$email = "";
		$user = "";

		require_once('Mailer.php');

		$aux = "name";
		if ( Mailer::checkEmail($username) )
			$aux = "email";

		// Username or email checking
		$sql = "SELECT id, name, email FROM users WHERE $aux = '$username'";
		$result = $this->conn->_execute($sql);
		$row = $this->conn->_nextRow($result);

		if ($row)
		{
			$id = $row[0];
			$user = $row[1];
			$email = $row[2];
		}
		
		// User dont exists
		if ( $id == -1 ) return "Unregistered user";

		$newPassword = $this->_createNewPassword();
		
		$sql = "UPDATE users SET password = '".sha1($newPassword)."' WHERE id = $id";
		$result = $this->conn->_execute($sql);

		$text = "user: $user\npass: $newPassword\n";
		$htmlText = "<b>user:</b> $user<br/><b>pass:</b> $newPassword<br/>";
		$subject = "Your password has been reseted";

		$mail = new Mailer($email);
		$mail->send($text, $subject, $htmlText);
		
		return "Done";
	}

	private function _createNewPassword()
	{
		$pass = "";
		$chars = "zbcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
		$length = rand(6,10);

		// Generate password
		for ( $i = 0; $i < $length; $i++ )
			$pass .= substr($chars, rand(0, strlen($chars)-1), 1);  // java: chars.charAt( random );

		return $pass;
	}

}

?>
