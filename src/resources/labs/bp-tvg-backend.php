<?php

session_start();

$action = isset($_REQUEST['action']) ? $_REQUEST['action'] : 'default';

if ( !in_array($action, array('querydictionary', 'saveslideshow'), true) )
$action = 'default';

if(isset($_SERVER['REQUEST_METHOD'])){
	$http_post = ('POST' == $_SERVER['REQUEST_METHOD']);
	if($http_post){
		if(isset($_POST['data'])){
			$post_data = $_POST['data'];
			if(is_string($post_data))
			{
				$res = json_decode($_POST['data'], true);
			} else {
				$res = $post_data;
			}
		}
	}
}

switch ($action) {
	case 'querydictionary':
		$query = $_GET['query'];
		echo cambridgeDictionaryQuery($query);
		break;
	case 'saveslideshow':
		if(isset($res)){
			if(generateTempFolder()){
				echo buildVideo($res);
			} else {
				echo "Couldn't create temp folder";
			}
		} else {
			echo 'No data provided';
		}
		break;
	default:
		echo 'No action requested';
		break;
}

function generateTempFolder(){
	//Generate a temporal folder for the incoming resources
	$folder_hash = md5(session_id());
	$folder_abs = dirname(__FILE__).'/images/'.$folder_hash;
	error_log($folder_abs."\n",3,"/tmp/error.log");
	if(!file_exists($folder_abs)){
		if(mkdir($folder_abs)){
			$_SESSION['temp_folder'] = $folder_abs;
			return true;
		} else {
			return false;
		}
	} else {
		return true;
	}
}

function cambridgeDictionaryQuery($query){
	$base_url = 'http://dictionary.cambridge.org';
	$ch = curl_init();
	$query_sanitized = str_replace(" ","-",$query);
	$query_sanitized = htmlentities($query_sanitized, ENT_QUOTES, 'UTF-8');
	curl_setopt($ch, CURLOPT_URL, $base_url.'/search/british/direct/?q='.$query_sanitized);

	//curl_setopt($ch, CURLOPT_POST, 1);

	curl_setopt($ch, CURLOPT_HEADER, 0);
	curl_setopt($ch, CURLOPT_FOLLOWLOCATION, 1);
	curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);

	curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
	curl_setopt($ch, CURLOPT_USERAGENT, "Mozilla/5.0 (Windows; U; Windows NT 6.0; en-US; rv:1.9.0.12) Gecko/2009070611 Firefox/3.0.12");

	$result = curl_exec($ch);

	if(preg_match('/id="cdo-spellcheck-container"/m',$result)){
		//The term you searched for didn't gave any results decomponse it (if it's possible) and search for individual words
		$results = "No results";

	} else {
		foreach(preg_split("/(\r?\n)/", $result) as $line){
			//WARNING: I'm not 100% sure this pattern is constant, maybe the <a> tag's attributes exchange order in certain cases.
			preg_match('/href="([^"]+)" class="cdo-topic cdo-link"/ism', $line, $matches);
			if (count($matches) > 0){
				//echo $matches[1]."\n";
				curl_setopt($ch, CURLOPT_URL, $base_url.$matches[1]);
				$result_topic = curl_exec($ch);
				break;
			}
		}
		if(isset($result_topic)){
			$relatedWords = array();
			foreach(preg_split("/(\r?\n)/", $result_topic) as $line){
				preg_match('/<span class="hwd">([^<]+)</ism', $line, $matches);
				if (count($matches) > 0){
					if(!array_search($matches[1],$relatedWords))
					array_push($relatedWords,$matches[1]);
				}
			}
			if(count($relatedWords) > 0)
			$results = json_encode($relatedWords);//implode(', ',$relatedWords);
			else
			$results = "No related thesaurus found";
		} else {
			$results = "No related thesaurus found";
		}
	}
	curl_close($ch);
	//return json_encode($results);
	return $results;

}

function makeImageFromText($text, $imageIndex){
	define('SLIDE_WIDTH', 720);   // width of image
	define('SLIDE_HEIGHT', 576);   // height of image
	define('SLIDE_FONTSIZE', 28);
	define('SLIDE_TEXTANGLE',0);
	define('MAX_CHARS_PER_LINE', 30); //calculated for a font size equal to 28 using arial font

	define('FONT','./arial.ttf');

	$words = explode(" ",trim($text));
	$lines = array();
	if(count($words) <= 1){
		array_push($lines,trim($text));
	} else {
		$line = '';
		for($j=0; $j<count($words); $j++){
			if(strlen($line)+1+strlen($words[$j]) <= MAX_CHARS_PER_LINE){
				$line .= $words[$j].' ';
			} else {
				array_push($lines,$line);
				$line = $words[$j].' ';
			}
			if($j == count($words) -1){
				array_push($lines,$line);
			}
		}
	}

	// Create the image
	$img = imagecreatetruecolor(SLIDE_WIDTH, SLIDE_HEIGHT);

	// Set a white background with black text and gray graphics
	$bg_color = imagecolorallocate($img, 255, 255, 255);     // white
	$text_color = imagecolorallocate($img, 0, 0, 0);         // black
	$graphic_color = imagecolorallocate($img, 64, 64, 64);   // dark gray

	// Fill the background
	imagefilledrectangle($img, 0, 0, SLIDE_WIDTH, SLIDE_HEIGHT, $bg_color);

	$textbox = imagettfbbox(SLIDE_FONTSIZE, SLIDE_TEXTANGLE, FONT, $lines[0]);
	$textbox_height = abs($textbox[3]-$textbox[5]);
	$image_center_x = imagesx($img)/2;
	$image_center_y = imagesy($img)/2;

	// Draw the word/phrase string
	for($i=0;$i<count($lines);$i++){
			
		//Return an 8 item array with the coords of the box as follows when succeeded: lower-left x,y lower-right x,y upper-right x,y upper-left x,y
		$bbox = imagettfbbox(SLIDE_FONTSIZE, SLIDE_TEXTANGLE, FONT, $lines[$i]);

		// This is our cordinates for X and Y
		$x = $image_center_x - abs($bbox[0]-$bbox[2])/2;
		$y = $image_center_y - (($textbox_height/2)*(count($lines)-2-(2*$i)));
		imagettftext($img, SLIDE_FONTSIZE, SLIDE_TEXTANGLE, $x, $y, $text_color, FONT, $lines[$i]);
			
	}
	$full_path;
	//Save the image we've just generated
	if(isset($_SESSION['temp_folder'])){
		$folder_abs = $_SESSION['temp_folder'];
		$full_path = $folder_abs.'/img'.sprintf("%02d",$imageIndex).'.png';
		imagepng($img, $full_path);
	}

	// Clean up
	imagedestroy($img);
	return $full_path;

}

function whiteImage($imageIndex){
	$call = "convert -size 720x576 xc:white %s 2>&1";
	$outputPath = $_SESSION['temp_folder'] . sprintf('/img%02d.png',$imageIndex);
	$sysCall = sprintf($call,$outputPath,$imageIndex);
	$result = (exec($sysCall,$output));
	return $outputPath;
}

function buildVideo($slides){
	//Command-line call to melt or ffmpeg. Video format: (Image |5s| Word/Phrase/Phrasal verb |5s|)xN times + White image |2min| explain what you saw in the images
	//$ melt ABSOLUTE_PATH/*png out=125 -filter luma:%luma01.pgm luma.softness=0.2 -repeat 2 -consumer avformat:OUTPUTFILENAME.EXTENSION b=1500k

	foreach ($slides as $key => $row) {
		$index[$key]  = $row['index'];
	}
	array_multisort($index, SORT_ASC, $slides);


	$video_paths = array();
	for($i=0; $i<count($slides);$i++){
		//This slide contains an image
		if(isset($slides[$i]['img']) && $slides[$i]['img'] != ''){
			$path = retrieveImageFile($slides[$i]['img'],$slides[$i]['index']);
			error_log($path."\n",3,"/tmp/error.log");
			$video_path = videoFromImage($path, $slides[$i]['displayTime']);

		} elseif(isset($slides[$i]['text']) && $slides[$i]['text'] != '') {
			$path = makeImageFromText($slides[$i]['text'],$slides[$i]['index']);
			error_log($path."\n",3,"/tmp/error.log");
			$video_path = videoFromImage($path, $slides[$i]['displayTime']);
		} else {
			$path = whiteImage($slides[$i]['index']);
			error_log($path."\n",3,"/tmp/error.log");
			$video_path = videoFromImage($path, $slides[$i]['displayTime']);
		}
		array_push($video_paths,$video_path);
	}
	concatVideos($video_paths);
	echo 'All done';
}

function videoFromImage($inputPath,$time){
	$preset = "ffmpeg -y -loop_input -f image2 -i %s -acodec pcm_s16le -f s16le -i /dev/zero -r 25 -t %d -s 720x576 %s.flv 2>&1";
	$sysCall = sprintf($preset, $inputPath, $time, $inputPath);
	error_log($sysCall."\n",3,"/tmp/error.log");
	$result = (exec($sysCall,$output));
	error_log($result."\n",3,"/tmp/error.log");
	return $inputPath.'.flv';
}

function concatVideos($video_paths){
	$outputpath = $_SESSION['temp_folder'].'/concat.flv';
	$call = "mencoder -oac copy -ovc copy -idx -o ".$outputpath." %s 2>&1";
	$pieces = '';
	foreach($video_paths as $video_path){
		$pieces.= $video_path.' ';
	}
	$sysCall = sprintf($call, $pieces);
	$result = (exec($sysCall,$output));
	return $result;
}

function retrieveImageFile($url, $imageIndex){
	$urlPieces = explode('/',$url);
	if(!(count($urlPieces) > 0))
	return;

	$filename = $urlPieces[count($urlPieces)-1]; //the filename
	$filename_pieces = explode('.',$url);
	$file_ext = $filename_pieces[count($filename_pieces) - 1]; //the extension

	//$filedir = '/md5 hash of the session_id + randomly generated identifier, for example/';

	$imgFile = file_get_contents($url);

	if(isset($_SESSION['temp_folder'])){
		$file_loc=$_SESSION['temp_folder'].'/img'.sprintf("%02d",$imageIndex).'.'.$file_ext;

		$file_handler=fopen($file_loc,'w');

		if(fwrite($file_handler,$imgFile)==false){
			return false;
		} else {
			return $file_loc;
		}
	}
}

/*
 function retrieveSelectedImageFiles($imgUrls){
 for($i=0; $i<count($imgUrls);$i++){
 $urlPieces = explode($imgUrls[$i],'/');
 if(!(count($urlPieces) > 0))
 return;

 $filename = $urlPieces[count($urlPieces)-1]; //the filename
 //$filedir = '/md5 hash of the session_id + randomly generated identifier, for example/';

 $imgFile = file_get_contents($imgUrls[$i]);

 if(isset($_SESSION['temp_folder'])){
 $file_loc=$_SESSION['temp_folder'].'/img'.sprintf("%02d",$i);

 $file_handler=fopen($file_loc,'w');

 if(fwrite($file_handler,$imgFile)==false){
 echo "Error saving file: ".$imgUrls[$i]."\n";
 }
 }
 }
 }
 */

?>