<?php

require_once 'Config.php';
require_once 'Datasource.php';


$json_input = file_get_contents('php://input');
$commit_info = json_decode($json_input, true);
$appRevision = $commit_info['revision'];

if(!empty($appRevision) && is_numeric($appRevision)){
	$sql = "UPDATE preferences SET prefValue= '%s' WHERE (prefName='appRevision')";
	error_log("[Webhook] Commited revision = ".$appRevision."\n", 3, "/tmp/error.log");
	_databaseUpdate($sql, $appRevision);
} else {
	error_log("[Webhook] No input received\n", 3, "/tmp/error.log");
}

function _databaseUpdate() {
	$settings = new Config ( );
	$conn = new Datasource ( $settings->host, $settings->db_name, $settings->db_username, $settings->db_password );
    $conn->_execute ( func_get_args() );
}


?>