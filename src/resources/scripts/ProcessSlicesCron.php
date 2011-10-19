<?php 

	require_once 'UploadExerciseDAO.php';
	echo "[".date("d/m/Y H:i:s")."] Commencing video slice processing task...\n"; 
	$uploadExercise = new UploadExerciseDAO();
	$uploadExercise->processPendingSlices(); 

?>
