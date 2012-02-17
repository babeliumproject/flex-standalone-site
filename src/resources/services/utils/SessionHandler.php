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

/**
 * Import here the definitions of the classes of the data you're going to store in 
 * the $_SESSION superglobal to avoid PHP and Zend AMF errors.
 */
 require_once dirname(__FILE__).'/../vo/UserVO.php';
 require_once dirname(__FILE__).'/../vo/UserLanguageVO.php';
 require_once dirname(__FILE__).'/../vo/SubtitleLineVO.php';


/**
 * Handles system's session manipulation operations
 * 
 * @author Babelium Team
 */
class SessionHandler{
	
	//When an exception is thrown on the services side we should consider automatically
	//logging out the users for security purposes.
	
	public function SessionHandler($restrictedArea = false){
		if(session_id() == ''){
			session_start();
			$_SESSION['initiated'] = true;
		}
		$this->avoidSessionFixation();
		
		if($restrictedArea)
			$this->avoidSessionHijacking();
	}

	private function avoidSessionFixation(){
		if (!isset($_SESSION['initiated']))
		{
			session_regenerate_id();
			$_SESSION['initiated'] = true;
		}
	}

	/**
	 * For now, we disable the IP check. Many ISPs have load-balance based dynamic IPs so it could be a bother for the user.
	 * 
	 * @throws Exception
	 */
	private function avoidSessionHijacking(){
		if( isset($_SESSION['logged']) && isset($_SESSION['uid']) && isset($_SESSION['user-agent-hash']) /*&& isset($_SESSION['user-addr'])*/){

			if ( $_SESSION['logged'] == false || $_SESSION['uid'] == 0 || $_SESSION['user-agent-hash'] != sha1($_SERVER['HTTP_USER_AGENT']) /*|| $_SESSION['user-addr'] != $_SERVER['REMOTE_ADDR']*/ )
			{
				throw new Exception("Unauthorized");
			}
		} else {
			throw new Exception("Unauthorized");
		}
	}
}

?>
