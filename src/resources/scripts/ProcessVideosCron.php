<?php 

require_once 'MediaTask.php';
echo "[".date("d/m/Y H:i:s")."] Commencing video processing task...\n"; 
$mt = new MediaTask();
$mt->processRawMedia(); 

?>
