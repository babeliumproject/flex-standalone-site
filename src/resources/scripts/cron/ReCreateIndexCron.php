<?php

/**
 *  This task rebuilds the search index on a periodic basis so that the users
 *  can search the latest exercises added to the database.
 */

require_once 'SearchDAO.php';

$searchCron = new SearchDAO();
$searchCron->reCreateIndex();

?>