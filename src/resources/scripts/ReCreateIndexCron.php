<?php

/**
 *  This task rebuilds the search index on a periodic basis so that the users
 *  can search the latest exercises added to the database.
 */

define('SERVICE_PATH', '/var/www/babelium/services');
require_once SERVICE_PATH . '/Search.php';

$searchCron = new Search();
$searchCron->reCreateIndex();

?>