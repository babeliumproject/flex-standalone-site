<?php

require_once 'Config.php';
require_once 'Datasource.php';

$settings = new Config();
$json_input = file_get_contents('php://input');
$commit_info = json_decode($json_input, true);
$appRevision = $commit_info['revision'];

$projectSecretKey = $settings->project_secret_key;
$digest = hash_hmac("md5",$json_input,$projectSecretKey);

$headers = apache_request_headers();

if ($digest == $header["Google-Code-Project-Hosting-Hook-Hmac"]){
	if(!empty($appRevision) && is_numeric($appRevision)){
		$sql = "UPDATE preferences SET prefValue= '%s' WHERE (prefName='appRevision')";

		$conn = new Datasource ( $settings->host, $settings->db_name, $settings->db_username, $settings->db_password );
		$conn->_execute ( $sql, $appRevision );
		error_log("[Webhook] Commited revision = ".$appRevision."\n", 3, $settings->webRootPath.'/logs/error.log');

	} else {
		error_log("[Webhook] No input received\n", 3, $settings->webRootPath.'/logs/error.log');
	}
} else {
	error_log("[Webhook] Authentication failed.\n", 3, $settings->webRootPath.'/logs/error.log');
}


?>