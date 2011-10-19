<?php

require_once 'Zend/Loader.php';
require_once 'utils/Config.php';
require_once 'utils/Datasource.php';
require_once 'utils/SessionHandler.php';

class YouTubeDAO {

	// Enter your Google account credentials
	private $email;
	private $passwd;
	private $devKey;

	// Video duration size
	private $maxDuration;

	private $filePath;
	private $imagePath;
	private $red5Path;
	private $exerciseFolder;
	private $conn;
	private $mediaHelper;

	function YouTubeDAO() {
		Zend_Loader::loadClass ( 'Zend_Gdata_YouTube' );
		Zend_Loader::loadClass ( 'Zend_Gdata_ClientLogin' );
		Zend_Loader::loadClass ( 'Zend_Gdata_App_Exception' );
		Zend_Loader::loadClass ( 'Zend_Gdata_App_Extension_Control' );
		Zend_Loader::loadClass ( 'Zend_Gdata_App_CaptchaRequiredException' );
		Zend_Loader::loadClass ( 'Zend_Gdata_App_HttpException' );
		Zend_Loader::loadClass ( 'Zend_Gdata_App_AuthException' );
		Zend_Loader::loadClass ( 'Zend_Gdata_YouTube_VideoEntry' );
		Zend_Loader::loadClass ( 'Zend_Gdata_App_Entry' );

		try {
			$verifySession = new SessionHandler();

			$settings = new Config();

			$this->filePath = $settings->filePath;
			$this->imagePath = $settings->imagePath;
			$this->red5Path = $settings->red5Path;
			$this->email = $settings->yt_user;
			$this->passwd = $settings->yt_password;
			$this->devKey = $settings->yt_developerKey;

			$this->maxDuration = $settings->maxDuration;

			$this->conn = new Datasource ( $settings->host, $settings->db_name, $settings->db_username, $settings->db_password );

		} catch (Exception $e) {
			throw new Exception($e->getMessage());
		}
	}

	private function authenticate() {
		try {
			$client = Zend_Gdata_ClientLogin::getHttpClient ( $this->email, $this->passwd, 'youtube' );
		} catch ( Zend_Gdata_App_CaptchaRequiredException $cre ) {
			throw new Exception ( "Captcha required: " . $cre->getCaptchaToken () . "\n" . "URL of CAPTCHA image: " . $cre->getCaptchaUrl () . "\n" );
		} catch ( Zend_Gdata_App_AuthException $ae ) {
			throw new Exception ( "Problem authenticating: " . $ae->getMessage () . "\n" );
		}

		$client->setHeaders ( 'X-GData-Key', 'key=' . $this->devKey );
		return $client;
	}

	public function retrieveVideo($data) {

		$url = escapeshellcmd($data);
		$pattern = '/v=([A-Za-z0-9._%-]*)[&\w;=\+_\-]*/';
		preg_match($pattern, $url, $matches);
		$result = $matches[1];
			
		return $result;
	}

	public function retrieveUserVideo($data) {

		$url = escapeshellcmd($data);
		$pattern = '/\/([^\/]*)$/'; //Captures each character starting from the last / of the Url
		preg_match($pattern, $url, $matches);
		$result = $matches[1];

		return $result;
	}

	public function insertVideoSlice($data, $data2) {

		set_time_limit(0); // Bypass the execution time limit

		try {
			new SessionHandler(true);

			$watchUrl = $data->watchUrl;

			// Microsoft Windows developers only
			// $sql = "SELECT prefValue FROM preferences WHERE (prefName = 'sliceDownCommandPath')";
			// $pathComando = $this->_singleQuery($sql);
			// $ytThumbnailUrlRetrieveCommand = $pathComando." -e --get-thumbnail ".$watchUrl;
				
			$ytThumbnailUrlRetrieveCommand = "youtube-dl -e --get-thumbnail ".$watchUrl;
			$thumbnail = exec($ytThumbnailUrlRetrieveCommand); //Get VideoSlice's Thumbnail Uri

			$sql = "INSERT INTO video_slice (name, watchUrl, start_time, duration) VALUES ('%s', '%s', %d, %d)";
			$result = $this->conn->_insert($sql, $data->name, $data->watchUrl, $data->start_time, $data->duration);

			$sql2 = "INSERT INTO exercise (name, description, source, language, fk_user_id, tags, title, thumbnail_uri, duration, status, license, reference, adding_date) VALUES ('%s', '%s', '%s', '%s', %d, '%s', '%s', '%s', %d, '%s', '%s', '%s', NOW())";
			$result = $this->conn->_insert($sql2, $data2->name, $data2->description, $data2->source, $data2->language, $_SESSION['uid'], $data2->tags, $data2->title, $thumbnail, $data->duration, $data2->status, $data2->license, $data2->reference);

			return $result;

		}catch (Exception $e){
			throw new Exception($e->getMessage());
		}
	}

	private function _singleQuery() {

		$result = $this->conn->_execute ( func_get_args() );
		$row = $this->conn->_nextRow($result);
		if ($row){
			return $row[0];
		}
	}
}
?>