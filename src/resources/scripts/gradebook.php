<?php
	//Register some global variables to use them in all functions	
	global $exercises, $users, $data, $errormsg;
	
	//TODO Check if the user is logged in
	/*
	try{
		$s = new SessionValidation(true);
		evaluationDoneByUser($_SESSION['userId']);
	} catch($exception){
		header('Location': 'http://'.$_SERVER['SERVER_NAME'].'/bp-login.php');
	}
	*/

	/*
         * HELPER FUNCTIONS
         */
	function evaluationsDoneByUser($userId){
		global $exercises, $users, $data, $errormsg;
		
		if(!$userId){
			$errormsg = "The provided user ID is not valid.\n";
			return false;
		}

		$c_path = dirname(__FILE__) . "/services/utils/Config.php";
		$d_path = dirname(__FILE__) . "/services/utils/Datasource.php";

		if( !is_readable($c_path) || !is_readable($d_path)){
			$errormsg = "Can't find one or more required scripts.\n";
			return false;
		}
		
		require_once $c_path;
		require_once $d_path;

		$exercises = array();
		$users = array();
		$data = array();

		$cfg = new Config();
		$db = new Datasource($cfg->host, $cfg->db_name, $cfg->db_username, $cfg->db_password);
		$sql = "SELECT 	
			u.id AS responseUserId,
			u.username AS responseUserName,
			u.firstname AS responseUserRealName,
			u.lastname AS responseUserRealSurname,
			r.adding_date AS responseDate,
			r.character_name AS responsePickedRole,
			ex.id AS exerciseId,
			ex.title AS exerciseTitle,
			ex.adding_date AS exerciseDate,
			ev.score_overall AS evaluationOverallScore,
			ev.score_intonation AS evaluationIntonationScore,
			ev.score_fluency AS evaluationFluencyScore,
			ev.score_rhythm AS evaluationRhythmScore,
			ev.score_spontaneity AS evaluationSpontaneityScore,
			ev.comment AS evaluationComment,
			ev.adding_date AS evaluationDate
				FROM
				evaluation ev
				INNER JOIN
				response r ON ev.fk_response_id = r.id
				INNER JOIN
				exercise ex ON r.fk_exercise_id = ex.id
				INNER JOIN
				user u ON r.fk_user_id = u.id
				WHERE
				ev.fk_user_id = %d
				ORDER BY u.lastname, u.firstname, u.username ASC";
		$exercises = array();
		$users = array();
		$data = array();
		$queryResults = $db->_multipleSelect($sql,$userId);
		if($queryResults){
			foreach($queryResults as $qr){
				$evaluationdata = array('responseDate' => $qr->responseDate,
						'intonation' => $qr->evaluationIntonationScore, 
						'fluency' => $qr->evaluationFluencyScore,
						'rhythm' => $qr->evaluationRhythmScore,
						'spontaneity' => $qr->evaluationSpontaneityScore,
						'overall' => $qr->evaluationOverallScore);

				$data[$qr->responseUserId][$qr->exerciseId][] = $evaluationdata;
				if(!isset($exercises[$qr->exerciseId])){
					$exercises[$qr->exerciseId] = array('title' =>$qr->exerciseTitle, 'criteriacount' => count($evaluationdata), 'criterias' => array_keys($evaluationdata) );
				}
				if(!isset($users[$qr->responseUserId])){
					$users[$qr->responseUserId] = $qr->responseUserRealSurname .", ".$qr->responseUserRealName." (".$qr->responseUserName.")";
				}
			}
			unset($qr);
			//print_r($exercises); print_r($users); print_r($data);
			return true;
		} else {
			$errormsg = "You haven't done any evaluations yet.\n";
			return false;
		}
	}

	function drawColHeaders(){
		global $exercises, $data;
		$header = '<tr><th></th>';
		$subheader = $header;
		foreach($exercises as $ekey => $edata){
			$header .= '<th id="ex'.$ekey.'" colspan="'.$edata['criteriacount'].'">'.$edata['title'].'</th>';
			foreach($edata['criterias'] as $criteria){
				$subheader.='<th>'.$criteria.'</th>';
			}
		}
		$header .= '</tr>';
		$subheader .= '</tr>';
		return $header . $subheader;
	}

	function drawData(){
		global $users, $exercises, $data;
		$rows = '';
		foreach($users as $userId => $userData){
			//Get this user's row span
			$userrowspan = 1;
			$userrows = array();
			foreach($data[$userId] as $exerciseId => $responses){			
				if(($rc = count($responses)) > $userrowspan)
					$userrowspan = $rc;
			}
			unset($exerciseId); unset($responses);
			for($k=0;$k<$userrowspan;$k++){
				$userrows[$k] = '<tr>';
			}

			$rowheader = '<th id="us'.$userId.'" rowspan="'.$userrowspan.'">'.$userData.'</th>';
			$userrows[0] = $userrows[0].$rowheader;

			foreach($exercises as $exerciseId => $exerciseData){
				$rowdata = '';
				//It is highly likely that not all the users made the same exercises
				if(isset($data[$userId][$exerciseId])){
					$responses = $data[$userId][$exerciseId];
					for($l=0;$l<$userrowspan;$l++){
						if(isset($responses[$l])){
							foreach($responses[$l] as $rfield){
								$userrows[$l] = $userrows[$l].'<td>'.$rfield.'</td>';
							}
						} else {
							for($i=0;$i<$exerciseData['criteriacount'];$i++){
								$userrows[$l] = $userrows[$l].'<td>-</td>';
							}
						}
					}
				} else {
					for($j=0;$j<$userrowspan;$j++){
						for($i=0;$i<$exerciseData['criteriacount'];$i++){
							$userrows[$j] = $userrows[$j].'<td>-</td>';
						}
					}
				}
			}
			for($k=0;$k<$userrowspan;$k++){
				$userrows[$k] = $userrows[$k].'</tr>';
			}
			$rows .= implode('',$userrows);
		}
		return $rows;
	}

?>
<html>
<head>
<title>Instance Gradebook</title>
<style type="text/css">
	*{ font-family: Arial;}
	.myTable { background-color:#FFFFE0;border-collapse:collapse; font-size: 10px;}
	.myTable th { background-color:#969257;color:white; }
	.myTable td, .myTable th { padding:5px;border:1px solid #BDB76B; }
</style>
</head>
<body>
<? if (evaluationsDoneByUser(1)) { ?>
	<table class="myTable">
	<? echo drawColHeaders(); ?>
	<? echo drawData(); ?>
	</table>
<? } else { ?>
	<h1><? echo $errormsg; ?></h1> 
<? } ?>

</body>
</html>
