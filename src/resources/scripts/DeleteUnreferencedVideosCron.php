<?php

/**
 * This periodic task is meant to be launched every 30 minutes. 
 * See crontab_lines.example file for configuration examples.
 * 
 */

require_once 'CleanupTask.php';

$ct = new CleanupTask();
$ct->deleteAllUnreferenced();

?>
