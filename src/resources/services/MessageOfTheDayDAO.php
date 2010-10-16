<?php

require_once 'utils/Config.php';
require_once 'utils/Datasource.php';
require_once 'utils/SessionHandler.php';

require_once 'vo/MotdVO.php';

class MessageOfTheDayDAO{

	private $conn;

	public function MessageOfTheDayDAO(){
		try {
			$verifySession = new SessionHandler();
			$settings = new Config ();
			$this->conn = new Datasource ( $settings->host, $settings->db_name, $settings->db_username, $settings->db_password );
		} catch (Exception $e) {
			throw new Exception($e->getMessage());
		}

	}

	public function unsignedMessagesOfTheDay($messageLocale){

		$sql = "SELECT title, message, code, language, resource FROM motd WHERE ( CURDATE() = displayDate AND language='%s' AND displaywhenloggedin = false ) ";

		$searchResults = $this->_listMessagesOfTheDayQuery($sql, $messageLocale);

		return $searchResults;

	}

	public function signedMessagesOfTheDay($messageLocale){

		$sql = "SELECT title, message, code, language, resource FROM motd WHERE ( CURDATE() = displayDate AND language='%s' AND displaywhenloggedin = true ) ";

		$searchResults = $this->_listMessagesOfTheDayQuery($sql, $messageLocale);

		return $searchResults;

	}

	private function _listMessagesOfTheDayQuery($query){

		$searchResults = array();
		$result = $this->conn->_execute ( func_get_args() );

		while ( $row = $this->conn->_nextRow($result)){
			$temp = new MotdVO();
			$temp->title = $row[0];
			$temp->message = $row[1];
			$temp->code = $row[2];
			$temp->language = $row[3];
			$temp->resourceUrl = $row[4];
				
			array_push ( $searchResults, $temp );
		}

		return $searchResults;
	}


}
