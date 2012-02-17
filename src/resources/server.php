<?php

// First import Zend's basic classes
require_once 'Zend/Loader.php';
require_once 'Zend/Amf/Server.php';

define ('SERVICE_PATH', '/services/');

/** Bootstrap */

// Instantiate server
$server = new Zend_Amf_Server();

// Disabling production shows more detailed errors.
$server->setProduction(false);


/**
 * The addDirectory method is pretty unrealiable (specially when several requests come at the same time) so if you have problems with certain
 * classes use require_once 'path/to/ClassName.php' and $server->setClass('ClassName'). This way the service class is explicitly instantiated
 * and no other problems should arise.
 */

require_once dirname(__FILE__) . SERVICE_PATH . 'Evaluation.php';
require_once dirname(__FILE__) . SERVICE_PATH . 'Exercise.php';
$server->setClass('Evaluation');
$server->setClass('Exercise');


//Add directories reachable for Zend AMF
$server->addDirectory(dirname(__FILE__) . SERVICE_PATH);
$server->addDirectory(dirname(__FILE__) . SERVICE_PATH . 'utils');
$server->addDirectory(dirname(__FILE__) . SERVICE_PATH . 'vo');

// Handle request
$response = $server->handle();
echo $response;

?>