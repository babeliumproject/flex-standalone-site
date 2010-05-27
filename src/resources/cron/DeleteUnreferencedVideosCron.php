<?php

require_once 'CleanUpDAO.php';
$cleanUpDAO = new CleanUpDAO();
$cleanUpDAO->deleteAllUnreferenced();

?>
