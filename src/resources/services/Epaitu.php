<?php

require_once ('Sub.php');
require_once ('Epai.php');
require_once ('Datasource.php');
require_once ('Config.php');

class Epaitu {
	
	private $conn;
	
	public function Epaitu() {
		$settings = new Config ();
		$this->conn = new Datasource ( $settings->host, $settings->db_name, $settings->db_username, $settings->db_password );
	}
	
	private function _listQuery() {
		$searchResults = array ();
		$result = $this->conn->_execute ( func_get_args() );
		
		while ( $row = $this->conn->_nextRow ( $result ) ) {
			$temp = new Epai ();
			$temp->Id = $row [0];
			$temp->Kodea = $row [1];
			$temp->response_id = $row [2];
			$temp->Iraupena = $row [3];
			$temp->Baloraturik = $row [4];
			$temp->AukeratutakoPertsonaia = $row [5];
			$temp->Data = $row [6];
			$temp->Jabea = $row [7];
			$temp->exerciseId = $row[8];
			$temp->Batazbestekoa = $row [9];
			array_push ( $searchResults, $temp );
		}
		
		return $searchResults;
	}
	
	private function _listQuery2() {

		$searchResults = array ();
		$result = $this->conn->_execute ( func_get_args() );
		
		while ( $row = $this->conn->_nextRow ( $result ) ) {
			$temp = new Sub ();
			$temp->ID_SUB = $row [0];
			$temp->ID_VID = $row [1];
			$temp->idioma = $row [2];
			$temp->textos = $row [3];
			$temp->tiempo = $row [4];
			$temp->duracion = $row [5];
			array_push ( $searchResults, $temp );
		}
		
		return $searchResults;
	}
	
	private function _epaiketaEmaitzak($sql) {
		$searchResults = array ();
		$result = $this->conn->_execute ( $sql );
		
		while ( $row = $this->conn->_nextRow ( $result ) ) {
			$temp = new Epai ();
			$temp->Epailea = $row [0];
			$temp->Balorazioa = $row [1];
			$temp->Data = $row [2];
			$temp->Iruzkinak = $row [3];
			$temp->BideoIruzkina = $row [4];
			array_push ( $searchResults, $temp );
		}
		
		return $searchResults;
	}
	
	public function _grafikoEmaitzak() {
		$searchResults = array ();
		$result = $this->conn->_execute ( func_get_params() );
		
		while ( $row = $this->conn->_nextRow ( $result ) ) {
			$temp = new Epai ();
			$temp->Epailea = $row [0];
			$temp->Balorazioa = $row [1];
			$temp->Iruzkinak = $row [2];
			array_push ( $searchResults, $temp );
		}
		
		return $searchResults;
	}
	
	public function datuakLortu($key) {
		
		$sql = "Select C.name,A.score,A.comment
			From (evaluation AS A Inner Join users AS C on A.fk_user_id = C.id) Inner Join response As D on A.fk_response_id = D.id
			Where D.id = '%d'";
		
		error_log ( $sql, 3, "/tmp/amfphp.txt" );
		$searchResults = $this->_grafikoEmaitzak ( $sql, $key );
		$mezua = print_r ( $searchResults, true );
		//         	//error_log($mezua, 3, "/tmp/amfphp.txt");
		return $searchResults;
	}
	
	public function hizkuntzakLortu($key) {
		
		$sql = "SELECT S.id, E.id, S.language, L.text, TRUNCATE(L.show_time*1000,0), L.hide_time*0 ";
		$sql .= "FROM exercise AS E INNER JOIN subtitle AS S ON (E.id = S.fk_exercise_id) INNER JOIN ";
		$sql .= "subtitle_line AS L ON (S.id = L.fk_subtitle_id) ";
		$sql .= "WHERE (E.name = '%s' ) ";
		
		$searchResults = $this->_listQuery2 ( $sql, $key );
		
		return $searchResults;
	
	}
	
	public function baloratuGabekoak($erabiltzaile) {
		
		$sql = "SELECT prefValue FROM preferences WHERE prefName='trial.threshold'";
		$result = $this->conn->_execute ( $sql );
		$row = $this->conn->_nextRow ( $result );
		$MAXBAL = $row [0]; // maximum number of assements before considering one video as evaluated  
		

		//Bideo bat inork ez duenean baloratu, c.fk_user_id null izango da, eta true itzultzen du konparaketak
		$sql = "SELECT DISTINCT A.file_identifier,B.name,A.id,B.duration,A.rating_amount,A.character_name,A.adding_date,F.name,B.id
				FROM (response AS A INNER JOIN exercise AS B on A.fk_exercise_id = B.id) INNER JOIN users AS F on A.fk_user_id = F.ID 
		     	LEFT OUTER JOIN evaluation AS C on C.fk_response_id = A.id
				WHERE B.status = 'Available' AND A.rating_amount < %d AND A.fk_user_id <> %d AND A.is_private = 0
				AND NOT EXISTS (SELECT *
                                FROM evaluation AS D INNER JOIN response AS E on D.fk_response_id = E.id
                                WHERE E.id = A.id AND D.fk_user_id = %d)";
		
		$searchResults = $this->_listQuery ( $sql, $MAXBAL, $erabiltzaile, $erabiltzaile );

		return $searchResults;
	
	}
	
	public function baloratuGabekoakLoginGabe() {
		
		$sql = "SELECT prefValue FROM preferences WHERE prefName='trial.threshold'";
		$result = $this->conn->_execute ( $sql );
		$row = $this->conn->_nextRow ( $result );
		$MAXBAL = $row [0]; // maximum number of assements before considering one video as evaluated  
		

		//Bideo bat inork ez duenean baloratu, c.fk_user_id null izango da, eta true itzultzen du konparaketak
		$sql = "Select DISTINCT B.file_identifier,A.name,B.id,A.duration,B.rating_amount,B.character_name,B.adding_date,D.name,A.id
		From (exercise As A Inner Join response As B on (A.id = B.fk_exercise_id)) Inner Join users AS D on B.fk_user_id = D.ID Left Outer Join evaluation As C on C.fk_response_id = B.id
		Where A.status = 'Available' AND B.rating_amount < %d
		AND B.is_private = 0;";
		
		$searchResults = $this->_listQuery ( $sql, $MAXBAL );
		
		return $searchResults;
	
	}
	
	public function nikEpaitutakoak($key) {
		
		$sql = "Select DISTINCT A.name,B.file_identifier,C.fk_response_id,A.duration,B.rating_amount,B.character_name,A.id
			From (exercise As A Inner Join response As B on A.id = B.fk_exercise_id) Inner Join evaluation As C on C.fk_response_id = B.id
			Where C.fk_user_id = '%d'";
		
		$searchResults = $this->_listQuery ( $sql, $key );
		return $searchResults;
	}
	
	public function norberariEpaitutakoak($key) {
		
		$sql = "Select A.name,B.file_identifier,B.id,A.duration,B.rating_amount,B.character_name,B.adding_date,B.adding_date, A.id, avg(C.score) AS Batazbestekoa  
		 From (exercise As A Inner Join response As B on A.id = B.fk_exercise_id) Inner Join evaluation As C on C.fk_response_id = B.id
		 Where B.fk_user_id = '%d' Group By A.id";

		$searchResults = $this->_listQuery ( $sql, $key );
		
		return $searchResults;
	}
	
	public function epaitutakoGrabaketa($key) {
		
		$sql = "Select C.name,A.score,A.adding_date,A.comment,B.video_identifier
			From (evaluation AS A Inner Join users AS C ON A.fk_user_id = C.id)Left Outer Join evaluation_video AS B on A.id = B.fk_evaluation_id
			Where A.fk_response_id = '%d'";
		
		$searchResults = $this->_epaiketaEmaitzak ( $sql, $key );
		
		return $searchResults;
	}
	
	public function updateGrabaketa($key) {
		$sql = "UPDATE response SET rating_amount = (rating_amount + 1) WHERE (id = '%d')";
		

		$result = $this->_databaseUpdate ( $sql, $key );
		
		if ($result != 1) {
			return false;
		}
		return true;
	}
	
	public function bideoaEzabatu($key) {
		$agindua = "rm /usr/lib/red5/webapps/oflaDemo/streams/videoComment/" . $key . ".flv";	
		exec ( $agindua );
		return true;
	}
	
	public function insertEpaiketa($grab, $erab, $bal, $com) {
		
		$sql = "INSERT INTO evaluation (fk_response_id, fk_user_id, score, comment, adding_date) VALUES (";
		$sql = $sql . "'%d', ";
		$sql = $sql . "'%d', ";
		$sql = $sql . "'%d', ";
		$sql = $sql . "'%s', NOW() )";
		
		$result = $this->_databaseUpdate ( $sql, $grab, $erab, $bal, $com  );
		
		$sql = "SELECT last_insert_id()";
		$result = $this->conn->_execute ( $sql );
		
		if ($row = $this->conn->_nextRow ( $result )) {
			return $row [0];
		} else {
			return false;
		}
	
	}
	
	public function insertVideoEpaiketa($grab, $erab, $bal, $com, $bid) {
		$sql = "INSERT INTO evaluation (fk_response_id, fk_user_id, score, comment, adding_date) VALUES (";
		$sql = $sql . "'%d', ";
		$sql = $sql . "'%d', ";
		$sql = $sql . "'%d', ";
		$sql = $sql . "'%s', NOW() )";
		
		$result = $this->_databaseUpdate ( $sql, $grab, $erab, $bal, $com  );
		
		$sql = "SELECT last_insert_id()";
		$result = $this->conn->_execute ( $sql );
		
		if ($row = $this->conn->_nextRow ( $result )) {
			$lastid = $row [0];

			$sql = "INSERT INTO evaluation_video (fk_evaluation_id, video_identifier, source) VALUES (";
			$sql = $sql . "'%d', ";
			$sql = $sql . "'%s', ";
			$sql = $sql . "'Red5')";
			$result = $this->_databaseUpdate ( $sql, $lastid, $bid  );
			
			return $lastid;
		} else {
			return false;
		}
	
	}
	
	private function _databaseUpdate() {
		$result = $this->conn->_execute ( func_get_args() );
		
		return $result;
	}

}

?>