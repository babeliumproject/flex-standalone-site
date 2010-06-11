<?

// PATH definition
// Change this three variables to comply with your settings
if(stristr(PHP_OS, 'Win')){
	$HOME = "C:/AppServ/www";
	$RED5_HOME = "C:/Archivos de programa/Red5";
	$WORKSPACE = "C:/Documents and settings/user/workspaces/babeliumproject/babelia_credits";
}else if (stristr(PHP_OS, 'Linux')){
	$HOME = "/var/www/babelia";
	$RED5_HOME = "/opt/red5_0_8";
	$WORKSPACE = "/home/user/workspace/babelium/babelia_credits";
}


$LOCALHOST = "babelia";
$SERVICES  = "/amfphp/services/babelia";
$DEPLOY = "/babelia";
$THUMBS = "/resources/images/thumbs";
$UPLOADS = "/resources/uploads";
$RED5_HOST = "localhost";
$RED5 = "http://" . $RED5_HOST  . ":5080/";
$OFLADEMO = "demos/ofla_demo.html";
$BANDWIDTHDEMO = "demos/bwcheck.html";
$RTMP_PORT = "1935";
$RED5_STREAMS = $RED5_HOME."/webapps/oflaDemo/streams";
$RED5_EXERCISES = 'exercises';
$RED5_EVALUATIONS = 'evaluations';
$RED5_RESPONSES = 'responses';
$SQL = "/src/resources/sql/all.sql";
$INPUT_TEST_VIDEO = $HOME . $UPLOADS . "/test.flv";
$OUTPUT_TEST_VIDEO = $HOME . $UPLOADS . "/output.flv";

// ================================
require_once ($HOME . $SERVICES . "/Config.php");
require_once ($HOME . $SERVICES . "/Datasource.php");

// ================================

function test($result){
	if ($result)
	echo "<span style='background-color:#00FF00;'>OK</span>";
	else
	echo "<span style='background-color:#FF0000;'>NOT OK</span>";
}

function url_exists($url) {
	$hdrs = @get_headers($url);
	return is_array($hdrs) ? preg_match('/^HTTP\\/\\d+\\.\\d+\\s+2\\d\\d\\s+.*$/',$hdrs[0]) : false;
}

function check_perms($path, $perm)
{
	clearstatcache();
	$configmod = substr(sprintf('%o', fileperms($path)), -3);
	if ($configmod == $perm)
	return true;
	else
	return false;
}

/*
 *
 * RTMPHP - by Espen Holm Nilsen (holm@blackedge.org) (www.gho.no / www.arpa.no)
 * You can use and modify this code as long as the above reference to me still exists.
 *
 */
function createPacket ($intType) {

	switch ($intType) {
		case 'startHandshake':
			$strHandshake = generateHandshake(getUptimeMs());
			break;
	}

}

function generateHandshake ($uptime_ms) {
	$handshake = NULL;

	$uptime_ms = getUptimeMs();
	$handshake = pack('N', $uptime_ms);
	$handshake .= "\x00\x00\x00\x00";
	$magic = $uptime_ms % 256;

	$bytes = 8;
	while ($bytes < 1536) {

		$magic = (1211121 * $magic + 1) % 256;

		if (strlen($handshake) != 1535) {
			$handshake .= sprintf("%c", $magic) . "\x00";
		} else {
			$handshake .= $magic;
		}
		$bytes += 2;
	}

	$handshake = "\x03" . $handshake;
	return $handshake;
}



function getUptimeMs () {
	$fd = fopen("/proc/uptime", 'r');

	if ($fd) {
		$strUptime = fgets($fd, 1024);
	} else {
		return FALSE;
	}

	$arrUptime = explode(" ", $strUptime);
	$arrUptime[0] = str_replace("\n", "", $arrUptime[0]);

	$arrTmpUptime = explode(".", $arrUptime[0]);

	$strUptime = $arrTmpUptime[0] . $arrTmpUptime[1] * 100;

	if ($fd) {
		fclose($fd);
	}

	// FIXME, THIS GOTTA BE BETTER!
	return substr($strUptime, 0, 10);

}

function gimmeSocket ($strServer, $intPort, $strBind = NULL) {
    if (($fdSocket = socket_create(AF_INET, SOCK_STREAM, 0)) == FALSE)
        die("Unable to create socket.\n");

    if ($strBind != NULL) {
        if ((@socket_bind($fdSocket, $strBind)) == FALSE)
            die("Unable to bind to $strBind.\n");
    }

    if ((@socket_connect($fdSocket, $strServer, $intPort)) == FALSE)
        die("<span style='background-color:#FF0000'>Could not connect</span>\n");

    return $fdSocket;

}

?>
<html>
<head>
    <title>Babelium Project Configuration Test</title>
</head>

<body>
<h1>Configuration test</h1>


Testing if there is a correct amfphp folder (<?php echo $HOME . $SERVICES ?>):
<? test( file_exists($HOME . $SERVICES )) ?>
<br>

Testing if Config.php exists where it should (<?php echo $HOME.$SERVICES .'/Config.php' ?>):
<? test( file_exists($HOME . $SERVICES . "/Config.php")) ?>

<br>
Testing if there is a correct DB login configuration:
<?
$settings = new Config ( );
$conn = @ new Datasource ( $settings->host, $settings->db_name, $settings->db_username, $settings->db_password );
test($conn->dbLink != null);
?>

<br>
Testing if there is an instance of Red5 running:
<?

test(url_exists($RED5));

?>
<br>
Testing if there is an instance of oflaDemo running:
<?

test(url_exists($RED5 . $OFLADEMO));

?>

<br>
Testing if there is an instance of bandWidthDemo running:
<?

test(url_exists($RED5 . $BANDWIDTHDEMO));

?>

<br>
Testing RTMP connection:
<?
$socket = gimmeSocket($RED5_HOST, $RTMP_PORT);

$arrReadSockets = array($socket);

$handshake = generateHandshake(0);
socket_write($socket, $handshake);

while (1) {
	$read = $arrReadSockets;
	if (socket_select($read, $write = NULL, $except = NULL, 0) > 0) {
		test($socket);
		break;
	}
	usleep(8000);
}
?>

<br>
Searching for RTMP videos: tdes_1065_qa.flv, tdes_1170_qa.flv,
tdes_1179_qa.flv:
<?
$array = array(0=>"tdes_1065_qa.flv", 1=>"tdes_1170_qa.flv", 2=>"tdes_1179_qa.flv");

if ($handle = opendir($RED5_STREAMS .'/'.$RED5_EXERCISES)) {
	while (false !== ($file = readdir($handle))) {
		if ($file != "." && $file != "..") {
			$key = array_search( $file, $array );
			if ($key != NULL || $key !== FALSE) {
				unset($array[$key]);
			}
		}
	}
	closedir($handle);

	test(count($array)==0);

}
?>

<br>
Trying to determine if Zend Framework is correctly installed:
<?php
test((include 'Zend/Loader.php'));

?>

<br>
Trying to determine if server.php is present and has no errors:
<?

$lines = @file_get_contents("http://" . $LOCALHOST. "/server.php");
test(strstr($lines, "Zend Amf Endpoint"));

?>

<br>
Trying to determine if you have the latest SQL build:
<?

$lines = file_get_contents($WORKSPACE . $SQL);
preg_match('/\$Revision: (.*)\$/', $lines, $availableversion);

$sql = "select prefValue from preferences where prefName='dbrevision'";
$result = $conn->_execute($sql);

list($prefValue) = $conn->_nextRow ( $result )  ;
preg_match('/\$Revision: (.*)\$/', $prefValue, $deployedversion);
test($availableversion[1] == $deployedversion[1]);

echo "<br><font size='-1'>";
echo "( Available: $availableversion[1]";
echo "Deployed:  $deployedversion[1] )";
echo "</font>";
?>

<br>
Trying to determine if upload script exists where it should (<?php echo $HOME ?>/upload.php):
<?php test(file_exists($HOME."/upload.php") ); ?>

<br>
Tyring to determine if uploads script has the appropriate permissions (755):
<?php test(check_perms($HOME."/upload.php","755")); ?>

<br>
Trying to determine if thumb folder exists where it should (<?php echo $HOME. $THUMBS ?>):
<?php test(file_exists($HOME. $THUMBS) ); ?>

<br>
Tyring to determine if thumb folder has the appropriate permissions (777):
<?php test(check_perms($HOME. $THUMBS, "777")); ?>

<br>
Trying to determine if upload folder exists where it should (<?php echo $HOME . $UPLOADS ?>):
<?php test(file_exists($HOME . $UPLOADS) ); ?>

<br>
Trying to determine if upload folder has the appropriate permissions (777):
<?php test(check_perms($HOME. $UPLOADS, "777")); ?>

<br>
Trying to determine if searchIndexes folder exists where it should (<?php echo $HOME . $SEARCHINDEXES ?>):
<?php test(file_exists($HOME . $SEARCHINDEXES) );?>

<br>
Trying to determine if searchIndexes folder has the appropriate permissions (777):
<?php test(check_perms($HOME . $SEARCHINDEXES) );?>

<br>
Trying to determine if Red5's exercises folder exists where it should (<?php echo $RED5_STREAMS .'/'. $RED5_EXERCISES ?>):
<?php test(file_exists($RED5_STREAMS .'/'. $RED5_EXERCISES) ); ?>

<br>
Trying to determine if Red5's exercises folder has the appropiate permissions (777):
<?php test(check_perms($RED5_STREAMS.'/'.$RED5_EXERCISES, "777"))?>

<br>
Trying to determine if Red5's evaluations folder exists where it should (<?php echo $RED5_STREAMS .'/'. $RED5_EVALUATIONS ?>):
<?php test(file_exists($RED5_STREAMS .'/'. $RED5_EVALUATIONS) ); ?>

<br>
Trying to determine if Red5's evaluations folder has the appropiate permissions (777):
<?php test(check_perms($RED5_STREAMS.'/'.$RED5_EVALUATIONS, "777"))?>

<br>
Trying to determine if Red5's evaluations folder exists where it should (<?php echo $RED5_STREAMS .'/'. $RED5_RESPONSES ?>):
<?php test(file_exists($RED5_STREAMS .'/'. $RED5_RESPONSES) ); ?>

<br>
Trying to determine if red5's responses folder has the appropiate permissions (777):
<?php test(check_perms($RED5_STREAMS.'/'.$RED5_RESPONSES, "777"))?>

<br>
Trying to determine if appropiate POST size is set in php.ini (post_max_size =200M):
<?php test(substr(ini_get("post_max_size"),0,-1) >= 200); ?>

<br>
Trying to determine if enough upload size is set in php.ini (upload_max_filesize =200M):
<?php test(substr(ini_get("upload_max_filesize"),0,-1) >= 200); ?>

<br>
Trying to determine if crossdomain.xml file exists where it should (<?php echo $HOME ?>):
<?php test(file_exists($HOME.'/crossdomain.xml'))?>

<br>
Trying to determine is ffmpeg is correctly installed:
<?php
$result = exec("ffmpeg 2>&1", $output);
test ("At least one output file must be specified" == $result); ?>

<br>
Trying to determine if the test video exists in uploads (<?php echo $INPUT_TEST_VIDEO ?>):
<?php test(file_exists($INPUT_TEST_VIDEO) ); ?>

<br>
Trying to determine if the test video can be successfully transcoded (<?php echo $OUTPUT_TEST_VIDEO ?> is created):
<?php

$result=(exec("ffmpeg -y -i ".$INPUT_TEST_VIDEO." -s 426x240 -g 300 -qmin 3 -acodec libmp3lame -ar 22050 -ac 2 -f flv ".$OUTPUT_TEST_VIDEO." 2>&1",$output));
test(file_exists($OUTPUT_TEST_VIDEO) && (filesize($OUTPUT_TEST_VIDEO) > 0));

?>

<br>
Trying to determine if ffmpeg-php extension is correctly installed:
<?php
if (file_exists($INPUT_TEST_VIDEO)){
	$movie = new ffmpeg_movie($INPUT_TEST_VIDEO, false) or die;
	test(11.65 == $movie->getDuration());
} else {
	test(0);
}
?>

<br>
Trying to determine if you added the SMTP account credentials to Config.php:
<?php 
test(!empty($settings->smtp_server_host) && !empty($settings->smtp_server_username) && !empty($settings->smtp_server_password) && !empty($settings->smtp_mail_setFromMail) );
?>

<br>
Trying to determine if the scheduled jobs are added to your crontab:
<?php
//$user = get_current_user();
exec('crontab -l 2>&1', $cronout);
test(strpos(implode($cronout), 'ProcessVideosCron.php'));
?>

</body>
</html>
