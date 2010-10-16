<?php

// First import Zend's basic classes
require_once 'Zend/Loader.php';
require_once 'Zend/Amf/Server.php';

/** Bootstrap */

// Instantiate server
$server = new Zend_Amf_Server();

// Disabling production shows more detailed errors.
$server->setProduction(false);

//Add directories reachable for Zend AMF
$server->addDirectory(dirname(__FILE__) .'/amfphp/services/babelia');
$server->addDirectory(dirname(__FILE__) .'/amfphp/services/babelia/utils');
$server->addDirectory(dirname(__FILE__) .'/amfphp/services/babelia/vo');

// Handle request
$response = $server->handle();
echo $response;

?>