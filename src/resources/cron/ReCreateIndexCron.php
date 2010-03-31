<?php
require_once './SearchDAO.php';

$searchCron = new SearchDAO();
$this->searchCron->reCreateIndex();
?>