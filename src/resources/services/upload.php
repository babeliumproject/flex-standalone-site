<?php

$errors = array ();
$data = "";
$success = "false";
/*
function return_result($success, $errors, $data) {
	echo ("<?xml version=\"1.0\" encoding=\"utf-8\"?>");
	?>
<results>
<success><?=$success;?></success>
<?=$data;?>
	<?=echo_errors ( $errors );?>
</results>
<?
}*/

function return_result($success, $errors, $data) {
	echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>";
	echo "<results>";
		echo "<success>".$success."</success>";
		echo "<data>";
			echo "<filepath>".$data[0]."</filepath>";
			echo "<filemimetype>".$data[1]."</filemimetype>";
		echo "</data>";
	echo "</results>";
}

function echo_errors($errors) {
	
	for($i = 0; $i < count ( $errors ); $i ++) {
		?>
<error><?=$errors [$i];?></error>
<?
	}
}

switch ($_REQUEST ['action']) {
	
	case "upload" :
		require_once("Config.php");

		$settings = new Config();
		
		$file_temp = $_FILES ['file'] ['tmp_name'];
		$file_name = $_FILES ['file'] ['name'];
		//$file_mime = $_FILES ['file'] ['type'];
		
		$file_path = $settings->filePath;
		
		
		
		//checks for duplicate files
		if (! file_exists ( $file_path . "/" . $file_name )) {
			
			//complete upload
			$filestatus = move_uploaded_file ( $file_temp, $file_path . "/" . $file_name );
			
			if (! $filestatus) {
				$success = "false";
				array_push ( $errors, "Upload failed. Please try again." );
			} else {
				$file_mime = mime_content_type($file_path."/".$file_name);
				$data = array($file_path, $file_mime);
				$success = "true";
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

return_result ( $success, $errors, $data );

?>
