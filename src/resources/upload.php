<?php

/*
 * Remember to set your php.ini's post_max_size to a size that meets your expected uploads' 
 * size otherways your POST will be truncated and the file won't be saved. Also, remember
 * to restart your Apache server after you've saved your new configuration.
 * 
 * Example: post_max_size = 200M
 * 
 * If you're using Linux, Adobe Flash Player 10.1.51.000+ is needed since previous versions
 * had a bug that caused a browser freeze/crash when uploading.
 * 
 * This file should be placed on %WEB_ROOT%/babelia
 * 
 */


$errors = array ();
$data = "";
$success = "false";

function return_result($success, $errors, $data) {
	echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>";
	echo "<results>";
		echo "<success>".$success."</success>";
		echo "<data>";
			echo "<filepath>".$data[0]."</filepath>";
			echo "<filemimetype>".$data[1]."</filemimetype>";
		echo "</data>";
		echo_errors($errors);
	echo "</results>";
}

function echo_errors($errors) {
	
	for($i = 0; $i < count ( $errors ); $i ++) { ?>
		<error><?=$errors [$i];?></error>
	<?}
}

function check_duration($path, $maxDuration){
	$total = 200;
	$resultduration = (exec("ffmpeg -i '$path' 2>&1",$cmd));
	if (preg_match('/Duration: ((\d+):(\d+):(\d+))/s', implode($cmd), $time)){
		$total = ($time[2] * 3600) + ($time[3] * 60) + $time[4];
	}
	return ($total <= $maxDuration);
}

switch ($_REQUEST ['action']) {
	
	case "upload" :
		define ('SERVICE_PATH', '/services/');
		include_once dirname(__FILE__) . SERVICE_PATH ."utils/Config.php";

		$settings = new Config();
		
		$file_temp = $_FILES ['file'] ['tmp_name'];
		$file_name = $_FILES ['file'] ['name'];
		$file_size = $_FILES ['file'] ['size'];
		
		$file_path = $settings->filePath;
		
		$file_max_size = ($settings->maxSize)*1024*1024;
		$file_max_duration = $settings->maxDuration;
		
		//To grab the mimetype we use system(file -bi $path)
		//must comply with one of the list: video/x-msvideo, video/x-flv
		
		//checks for duplicate files
		if (! file_exists ( $file_path . "/" . $file_name )) {
			
			//complete upload
			$filestatus = move_uploaded_file ( $file_temp, $file_path . "/" . $file_name );
			
			if (! $filestatus) {
				$success = "false";
				array_push ( $errors, "Upload failed." );
			} else if (!check_duration($file_path . "/" . $file_name, $file_max_duration)){
				$success = "false";
				array_push ( $errors, "Maximum video duration exceeded. Should be less than ".$file_max_duration." seconds");
				@unlink($file_path . "/" . $file_name);
			} else if ($file_size > $file_max_size){
				$success = "false";
				array_push ( $errors, "Maximum video size exceeded. Should be less than ".$settings->maxSize."MB");
				@unlink($file_path . "/" . $file_name);
			}else{
				if (stristr(PHP_OS, 'Linux')){
					$file_mime = mime_content_type($file_path."/".$file_name);
				}
				$data = array($file_path, $file_mime);
				$success = "true";
				@chmod($file_path . "/" . $file_name, 0644);
			}
		
		} else {
			$success = "false";
			array_push ( $errors, "File already exists on server." );
		}
		
		break;
	
	default :
		$success = "false";
		array_push ( $errors, "No action was requested." );

}


/*
// We log the upload process so that we can check periodically if something went wrong.

error_log("success = ".$success."\n", 3, "/tmp/error.log");
for($i=0; $i<count($errors); $i++)
	error_log("error[".$i."] = ".$errors[$i]."\n", 3, "/tmp/error.log");
for($j=0; $j<count($data); $j++)
	error_log("data[".$j."] = ".$data[$j]."\n", 3, "/tmp/error.log");
error_log("file name = ". $file_name."\n", 3, "/tmp/error.log");
error_log("file temp = ". $file_temp."\n", 3, "/tmp/error.log");
error_log("file size = ". $file_size."\n\n", 3, "/tmp/error.log");

*/

return_result ( $success, $errors, $data );

?>
