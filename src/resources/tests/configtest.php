<?

// PATH definition
$LOCALHOST = "babelia";
$HOME = "/var/www/babelia/";
$SERVICES  = "amfphp/services/babelia/";
$RED5_HOST = "localhost";
$RED5 = "http://" . $RED5_HOST  . ":5088/";
$OFLADEMO = "demos/ofla_demo.html";
$RTMP_PORT = "1935";
$RED5_STREAMS = "/opt/red5/dist/webapps/oflaDemo/streams";
$WORKSPACE = "/home/juanan/workspace/babelia_credits/";
$SQL = "src/resources/sql/all.sql";

// ================================
@require_once ($HOME . $SERVICES . "Config.php");
@require_once ($HOME . $SERVICES . "Datasource.php");
@require_once ("rtmpcheck.php");

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
?>
<html>

<body>
<h1>Configuration test</h1>


Testing if there is a correct amfphp folder:  <? test( file_exists($HOME . $SERVICES )) ?> 
<br>

Testing if Config.php exists: <? test( file_exists($HOME . $SERVICES . "Config.php")) ?>

<br>
Testing if there is a correct DB login configuration: <?
$settings = new Config ( );
$conn = @ new Datasource ( $settings->host, $settings->db_name, $settings->db_username, $settings->db_password );
test($conn->dbLink != null);
?>

<br>
Testing if there is an instance of Red5 running: <?

  test(url_exists($RED5));

?>
<br>
Testing if there is an instance of oflaDemo running: <?

  test(url_exists($RED5 . $OFLADEMO));

?>

<br>
Testing RTMP connection: <?
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
Searching for RTMP videos: cue_cuatro.flv, kutsi9.flv, water.flv: <?


$array = array(0=>"cue_cuatro.flv", 1=>"kutsi9.flv", 2=>"water.flv");

if ($handle = opendir($RED5_STREAMS)) {
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
Trying to determine if Zend Framework is actually installed: <?
  
   $lines = @file_get_contents("http://" . $LOCALHOST. "/server.php");
   test(strstr($lines, "Zend Amf Endpoint"));

?>

<br>
Trying to determine if we are in the latest sql build: <?
  
   $lines = @file_get_contents($WORKSPACE . $SQL);
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
</body>
</html>
