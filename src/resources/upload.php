<?php

/**
 * Remember to set php.ini's post_max_size and upload_max_size to a size larger than the 
 * values of Config.php and/or or those of the preference table in the database. 
 * Otherways your POST will be truncated and the file won't be saved. 
 * 
 * If you're using Linux, Adobe Flash Player 10.1.51.000+ is required since previous versions
 * had a bug that caused a browser freeze/crash when uploading.
 * 
 * This file should be placed under <BABELIUM_ROOT>/upload.php
 */

global $result;
global $file_name;
global $file_size;
global $media_data;
global $cfg;

if ($_REQUEST && isset($_REQUEST['action']) && $_REQUEST['action'] == 'upload'){
	try{
		define('UTIL_PATH', dirname(__FILE__) . "/services/utils/");
		
		//Ensure all the classes exist and are readable
		$c_path = UTIL_PATH . 'Config.php';
		$d_path = UTIL_PATH . 'Datasource.php';
		$m_path = UTIL_PATH . 'VideoProcessor.php';
		if( !is_readable($c_path) || !is_readable($d_path) || !is_readable($m_path) ){
			fault_result(500, "classesmissing","Required classes are missing");
		} else {
			//Require the RPC services classes
			require_once $c_path; 
			require_once $d_path; 
			require_once $m_path;
	
			$cfg = new Config();
			$vp = new VideoProcessor();
			$db = new Datasource($cfg->host, $cfg->db_name, $cfg->db_username, $cfg->db_password);
			
			$file_temp = $_FILES ['file'] ['tmp_name'];
			$file_name = $_FILES ['file'] ['name'];
			$file_size = $_FILES ['file'] ['size'];
			
			$file_name = str_replace(' ', '_', $file_name);
			$file_name = preg_replace("/[^A-Za-z0-9\._]/","",$file_name);
			$file_name = time() . "_" . $file_name;
			
			//Filter the filename just in case someone wants to launch some cmd using trickery
			$escaped_file_name = escapeshellcmd($file_name);
			
			$file_path = $cfg->filePath;
			
			$file_max_size = min(return_bytes(ini_get('post_max_size')),return_bytes(ini_get('upload_max_filesize')));
			
			$result = $db->_singleSelect("SELECT DISTINCT(prefName), prefValue FROM preferences WHERE (prefName='maxExerciseDuration')");
			if($result)
				$file_max_duration = $result->prefValue;
			else
				$file_max_duration = $cfg->maxDuration; //If there's no preference set, use the value on the config file
			
			//Check if the filename is duplicated by chance
			$clean_path = $file_path . "/" . $escaped_file_name;
			if (file_exists ( $clean_path )){
				fault_result(400, "duplicatedfilename","A file with that name already exists on the server. Please choose other name");
			}else{
				//Move the file from the tmp location to uploads folder
				if (!$filestatus = move_uploaded_file ( $file_temp, $clean_path ) ){
					fault_result(500, "uploadfailed", "The file upload failed. Please try again");
				}else {
					@chmod($clean_path, 0644);
					try{
						$media_data = $vp->retrieveMediaInfo($file_path . "/" . $file_name);
					} catch(Exception $e){
						fault_result(400,"notmediafile","File is not a media file or is corrupted");
					}
					try{
						$validMime = $vp->checkMimeType($file_path . "/" . $file_name);
					} catch (Exception $e){
						fault_result(400,"invalidmime","File mimetype is invalid");
					}
					
					//Check if the video lasts longer than the allowed duration
					if($media_data->duration > $file_max_duration){
						fault_result(400, "videotoolong","Media file duration is too long. Should be less than ".$file_max_duration." seconds", $file_max_duration);
						@unlink($clean_path);
					} else if (!$validMime || !$media_data->hasVideo){
						fault_result(400, "novideotrack","Media file has no video track.");
						@unlink($clean_path);
					} else if ($file_size > $file_max_size){
						fault_result(400, "videotoobig", "Media file is too big. Should be less than ".($file_max_size/1048576)."MB", $file_max_size);
						@unlink($clean_path);
					} else {
						success_result($escaped_file_name);
					}
				}
			}
		}
		
	} catch(Exception $e){
		fault_result(500,"exception",$e->getMessage());
	}
}else{
	fault_result(400,"noaction","No action was requested or the POST request was truncated due to unknown reasons");
}

echo $result;

/**
 * HELPER FUNCTIONS
 */

/**
 * Logs file upload activity to the local filesystem
 * @param String $code
 * 			A code to identify the problem
 * @param String $description
 * 			A description of the problem
 */
function log_result($code,$description){
	global $file_name, $file_size, $result, $media_data, $cfg;
	
	$message = "[".date("d/m/Y H:i:s")."] VIDEO UPLOAD LOG\n";
	$message .= "\tError Code: ".$code."\n";
	$message .= "\tError description: ".$description."\n";
	$message .= "\tUnescaped filename: ".$file_name."\n";
	$message .= "\tFilesize: ".$file_size."\n";
	$message .= "\tResponse: ".$result."\n";
	$message .= "\tMediainfo: ".print_r($media_data,true)."\n";
	
	$log_file = ($cfg && isset($cfg->logPath)) ? $cfg->logPath . '/upload.log' : '/tmp/upload.log';
	error_log($message,3,$log_file);
}

/**
 * Sends a notification e-mail to Babelium's staff, so that they get in touch with the user to solve the problem
 * @param String $message
 * 			A copy of the message that's being recorded in the server's log file
 */
function notify_fault_result($message){
	//TODO
}

/**
 * The upload process failed in some step, make a fault response to inform the user about this fact
 * @param int $header
 * 			An HTTP status code (can be useful for future iterations if REST-like script is implemented)
 * @param String $code
 * 			A code to identify the problem
 * @param String $description
 * 			A description of the problem
 */
function fault_result($header, $code, $description, $data=null){
	$status = 'failure';
	$httpstatus = '<httpstatus>'. str_replace(array("\r","\n"),"",$header) .'</httpstatus>';
	$message = '<message>'. str_replace(array("\r","\n"),"",$description) .'</message>';
	$errorcode = '<code>'. str_replace(array("\r","\n"),"",$code) .'</code>';
	$errordata = $data ? '<data>'.str_replace(array("\r","\n"),"",$data) .'</data>' : '';
	$response = $message.$errorcode.$errordata;
	build_result_xml($httpstatus,$status,$response);
	log_result($code,$description);
}

/**
 * The upload process finished without errors. Return the uploaded filename to the client to mark the video
 * for transcoding.
 * @param String $filename
 * 		The file name of the video before the transcoding stage
 */
function success_result($filename){
	$code = '';
	$description = '';
	$status = 'success';
	$httpstatus = '<httpstatus>200</httpstatus>';
	$response = '<filename>'. str_replace(array("\r","\n"),"",$filename) .'</filename>';
	build_result_xml($httpstatus,$status,$response);
	log_result($code,$description);
}

/**
 * Builds and XML response that needs to be parsed by the client
 * @param String $header
 * 			The response headers as seen in the HTTP protocol
 * @param String $status
 * 			Tells whether the request was a successful or not
 * @param String $response
 * 			Information about either the failure or the file when the upload is successful
 */
function build_result_xml($header, $status, $response) {
	global $result;
	$result = "<?xml version=\"1.0\" encoding=\"utf-8\"?><result><header>".$header."</header><status>".$status."</status><response>".$response."</response></result>";
}

/**
 * Returns the byte representation of a configuration directive
 * @param mixed $val
 * 		Either a byte or shorthand notation of a directive (K for kilobytes, M for megabytes, G for gigabytes)
 * @return int $val
 * 		Byte notation of the directive
 */
function return_bytes($val) {
    $val = trim($val);
    $last = strtolower($val[strlen($val)-1]);
    $val = (int)$val;
    switch($last) {
    	// The 'G' modifier is available since PHP 5.1.0
       	case 'g':
           	$val *= 1024;
       	case 'm':
           	$val *= 1024;
       	case 'k':
           	$val *= 1024;
    }
    return $val;
}

?>
