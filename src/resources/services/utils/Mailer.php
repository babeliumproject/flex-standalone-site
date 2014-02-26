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

require_once 'Datasource.php';
require_once 'Config.php';
require_once 'Zend/Mail.php';
require_once 'Zend/Mail/Transport/Smtp.php';
require_once 'EmailAddressValidator.php';

/**
 * This class performs mail sending duties
 * 
 * @author Babelium Team
 *
 */
class Mailer
{
	
	private $_conn;
	private $_settings;
	private $_userMail;
	private $_userFirstname;
	private $_validUser;

	// Template related vars
	private $_tplDir;
	private $_template;
	private $_tplFile;
	private $_keys;
	private $_values;

	public $txtContent;
	public $htmlContent;

	public function __construct($username)
	{
		$this->_settings = new Config();
		$this->_conn = new DataSource($this->_settings->host, $this->_settings->db_name, $this->_settings->db_username, $this->_settings->db_password);

		$this->_tplDir = $this->_settings->templatePath . "/";


		$this->_validUser = $this->_getUserInfo($username);
	}

	private function _getUserInfo($username)
	{
		if (!$username)
			return false;

		$aux = "username";
		if ( Mailer::checkEmail($username) )
			$aux = "email";

		$sql = "SELECT username, email FROM user WHERE (".$aux." = '%s') ";
		$result = $this->_conn->_singleSelect($sql, $username);
		if ($result)
		{
			$this->_userFirstname = $result->username;
			$this->_userMail = $result->email;
		}
		else
			return false;

		return true;
	}

	public function send($body, $subject, $htmlBody = null)
	{
		if ( !$this->_validUser ){
			error_log("[".date("d/m/Y H:i:s")."] Problem while sending notification mail. The provided username is not correct or it's duplicated in the database\n",3,$this->_settings->logPath.'/mail_smtp.log');
			return false;
		}
		
		try {
			//STMP server config
			$auth_config = $ssl_config = $port_config = array();
			if(!empty($this->_settings->smtp_server_auth)){
				$auth_config = array('auth' => $this->_settings->smtp_server_auth, 'username' => $this->_settings->smtp_server_username, 'password' => $this->_settings->smtp_server_password);
			}
			if(!empty($this->_settings->smtp_server_ssl)){
				$ssl_config = array('ssl' => $this->_settings->smtp_server_ssl);
			}
			if(!empty($this->_settings->smtp_server_port)){
				$port_config = array('port' => $this->_settings->smtp_server_port);
			}
			$config = array_merge($auth_config, $ssl_config, $port_config);
			$transport = count($config) ? new Zend_Mail_Transport_Smtp($this->_settings->smtp_server_host, $config) : new Zend_Mail_Transport_Smtp($this->_settings->smtp_server_host);

			$mail = new Zend_Mail('UTF-8');
			$mail->setBodyText(utf8_decode($body));
			if ( $htmlBody != null )
				$mail->setBodyHtml($htmlBody);
			$mail->setFrom($this->_settings->smtp_mail_setFromMail, $this->_settings->smtp_mail_setFromName);
			$mail->addTo($this->_userMail, $this->_userFirstname);
			$mail->setSubject($subject);
		
		
			$mail->send($transport);
		} catch (Exception $e) {
			error_log("[".date("d/m/Y H:i:s")."] Problem while sending notification mail to ". $this->_userMail . ":" . $e->getMessage() . "\n",3,$this->_settings->logPath.'/mail_smtp.log');
			return false;
		}
		error_log("[".date("d/m/Y H:i:s")."] Notification mail successfully sent to ". $this->_userMail . "\n",3,$this->_settings->logPath.'/mail_smtp.log');
		return true;
	}

	public static function checkEmail($email)
	{
		$reg = "/^[^0-9][a-zA-Z0-9_-]+([.][a-zA-Z0-9_-]+)*[@][a-zA-Z0-9_-]+([.][a-zA-Z0-9_-]+)*[.][a-zA-Z]{2,4}$/";
		return preg_match($reg, $email);
	}
	
	public static function checkEmailWithValidator($email)
	{
		$validator = new EmailAddressValidator();
		return $validator->check_email_address($email);
	}
	
	public function makeTemplate($templateFile, $templateArgs, $language)
	{
		$this->_tplFile = $this->_tplDir . $language . "/" . $templateFile;
		if( !file_exists($this->_tplFile) || !is_file($this->_tplFile) || !is_readable($this->_tplFile) ){
			$this->_tplFile = $this->_tplDir . "en_US/" . $templateFile;
		}

		$this->_keys = array();
		$this->_values = array();
		
		while ( list($tmp1,$tmp2) = each($templateArgs) )
		{
			array_push($this->_keys, "/{" . $tmp1 . "}/");
			array_push($this->_values, $tmp2);
		}

		$txtFile = $this->_tplFile.".txt";
		$htmlFile = $this->_tplFile.".html";

		// txt content
		if ( !$fd = fopen($txtFile, "r") ) return false;
		$this->_template = fread($fd, filesize($txtFile));
		fclose($fd);
		$this->txtContent = preg_replace($this->_keys, $this->_values, $this->_template);
		

		// html content
		if ( !$fd = fopen($htmlFile, "r") ) return false;
		$this->_template = fread($fd, filesize($htmlFile));
		fclose($fd);
		$this->htmlContent = preg_replace($this->_keys, $this->_values, $this->_template);

		return true;
	}
}

?>
