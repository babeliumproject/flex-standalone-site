#!/usr/bin/php -q
<?php require_once 'ExerciseDAO.php';
      $exerciseDAO = new ExerciseDAO();
      $exerciseDAO->deactivateReportedVideos(); 
?>