<?php

   require_once('Sub.php');
   require_once('Epai.php');
   require_once('Datasource.php');
   require_once('Config.php');
   
   class Epaitu
   {

      var $conn;

      function Epaitu()
      {
		$settings = new Config();
        $this->conn = new Datasource($settings->host, $settings->db_name, $settings->db_username, $settings->db_password);
      }


      function _listQuery($sql)
      {
         $searchResults = array();
         $result = $this->conn->_execute($sql);

         while ($row = $this->conn->_nextRow($result))
         {
            $temp = new Epai();
            $temp->Id = $row[0];
            $temp->Kodea = $row[1];
            $temp->response_id = $row[2];
            $temp->Iraupena = $row[3];
	    $temp->Baloraturik = $row[4];
	    $temp->AukeratutakoPertsonaia = $row[5];
	    $temp->Data = $row[6];
	    $temp->Jabea = $row[7];
	    $temp->Batazbestekoa = $row[8];
            array_push($searchResults, $temp);
         }

         return $searchResults;
      }


  function _listQuery2($sql)
      {

	//error_log($sql, 3, "/tmp/amfphp.txt");

         $searchResults = array();
         $result = $this->conn->_execute($sql);

         while ($row = $this->conn->_nextRow($result))
         {
            $temp = new Sub();
            $temp->ID_SUB = $row[0];
	    $temp->ID_VID = $row[1];
            $temp->idioma = $row[2];
            $temp->textos = $row[3];
	    $temp->tiempo = $row[4];
	    $temp->duracion = $row[5];
            array_push($searchResults, $temp);
         }

         return $searchResults;
      }


      function _epaiketaEmaitzak($sql)
      {
         $searchResults = array();
         $result = $this->conn->_execute($sql);

         while ($row = $this->conn->_nextRow($result))
         {
            $temp = new Epai();
            $temp->Epailea = $row[0];
            $temp->Balorazioa = $row[1];
            $temp->Data = $row[2];
	    $temp->Iruzkinak = $row[3];
	    $temp->BideoIruzkina = $row[4];
            array_push($searchResults, $temp);
         }

         return $searchResults;
      }

      function _grafikoEmaitzak($sql)
      {
         $searchResults = array();
         $result = $this->conn->_execute($sql);

         while ($row = $this->conn->_nextRow($result))
         {
            $temp = new Epai();
            $temp->Epailea = $row[0];
            $temp->Balorazioa = $row[1];
	    $temp->Iruzkinak = $row[2];
            array_push($searchResults, $temp);
         }

         return $searchResults;
      }



	function datuakLortu($key)
	{
		/*
		$sql="Select ErabiltzaileFk,IF(Balorazioa='Ondo',10,IF(Balorazioa='Erdizka',5,0)) As Balorazioa,Iruzkinak
			From Epaiketa
			Where GrabaketaFk = '".$key."'";
		*/

		$sql = "Select C.name,A.score,A.comment
			From (evaluation AS A Inner Join users AS C on A.fk_user_id = C.id) Inner Join response As D on A.fk_response_id = D.id
			Where D.id = '".$key."'";


		error_log($sql, 3, "/tmp/amfphp.txt");
		$searchResults = $this->_grafikoEmaitzak($sql);
		$mezua = print_r($searchResults, true);
//         	//error_log($mezua, 3, "/tmp/amfphp.txt");
		return $searchResults;
	}


	function hizkuntzakLortu($key)
	{

        //error_log("hizkuntzakLortu \n", 3, "/tmp/amfphp.txt");

         $sql = "Select A.ID_SUB,A.ID_VID, A.idioma,A.textos,A.tiempo, A.duracion From subtitulos As A Inner Join videos as B on (A.ID_VID = B.ID) where B.nombre = '".$key."'";

	 //$mezua = print_r($sql, true);
         //error_log($mezua, 3, "/tmp/amfphp.txt");

         $searchResults = $this->_listQuery2($sql);

         

         return $searchResults;

	}






	function baloratuGabekoak($erabiltzaile)
	{

	$sql = "SELECT prefValue FROM preferences WHERE prefName='trial.threshold'";
			$result = $this->conn->_execute($sql);
			$row = $this->conn->_nextRow($result);
			$MAXBAL = $row[0]; // maximum number of assements before considering one video as evaluated  

         //error_log("Heldu da \n", 3, "/tmp/amfphp.txt");

	//Bideo bat inork ez duenean baloratu, c.fk_user_id null izango da, eta true itzultzen du konparaketak
	$sql = "Select DISTINCT A.file_identifier,B.name,A.id,B.duration,A.rating_amount,A.character_name,B.adding_date,F.name
		From (response As A Inner Join exercise As B on A.fk_exercise_id = B.id) Inner Join users AS F on A.fk_user_id = F.ID 
		     Left Outer Join evaluation As C on C.fk_response_id = A.id
		Where A.rating_amount < ".$MAXBAL."
		AND A.fk_user_id <> '".$erabiltzaile."'
		AND A.is_private = 0
		AND Not Exists (Select *
                                From evaluation AS D Inner Join response AS E on D.fk_response_id = E.id
                                Where E.id = A.id
                                And D.fk_user_id = '".$erabiltzaile."')";


	 // error_log($sql, 3, "/tmp/amfphp.txt");
         $searchResults = $this->_listQuery($sql);

         //$mezua = print_r($searchResults, true);
         //error_log($mezua, 3, "/tmp/amfphp.txt");

         return $searchResults;

	}


	function baloratuGabekoakLoginGabe()
	{

			$sql = "SELECT prefValue FROM preferences WHERE prefName='trial.threshold'";
			$result = $this->conn->_execute($sql);
			$row = $this->conn->_nextRow($result);
			$MAXBAL = $row[0]; // maximum number of assements before considering one video as evaluated  
         

	//Bideo bat inork ez duenean baloratu, c.fk_user_id null izango da, eta true itzultzen du konparaketak
	$sql = "Select DISTINCT B.file_identifier,A.name,B.id,A.duration,B.rating_amount,B.character_name,B.adding_date,D.name
		From (exercise As A Inner Join response As B on (A.id = B.fk_exercise_id)) Inner Join users AS D on B.fk_user_id = D.ID Left Outer Join evaluation As C on C.fk_response_id = B.id
		Where B.rating_amount < ".$MAXBAL."
		AND B.is_private = 0;";





	 //error_log($sql, 3, "/tmp/amfphp.txt");
         $searchResults = $this->_listQuery($sql);

         //$mezua = print_r($searchResults, true);
         //error_log($mezua, 3, "/tmp/amfphp.txt");

         return $searchResults;

	}



	function nikEpaitutakoak($key)
	{

/*
		$sql = "Select B.Id,B.BideoaFk,C.Iraupena,B.rating_amount,B.character_name
			From Epaiketa AS A Inner Join Grabaketa As B on (A.GrabaketaFk = B.Id) Inner Join Bideoa AS C on (B.BideoaFk = C.Kodea)
			Where A.ErabiltzaileFk = '".$key."'";

*/
			$sql = "Select DISTINCT A.name,B.file_identifier,C.fk_response_id,A.duration,B.rating_amount,B.character_name
			From (exercise As A Inner Join response As B on A.id = B.fk_exercise_id) Inner Join evaluation As C on C.fk_response_id = B.id
			Where C.fk_user_id = '".$key."'";


		$searchResults = $this->_listQuery($sql);
		return $searchResults;
	}


	function norberariEpaitutakoak($key)
	{
	/*
         $sql = "Select A.Id,B.Kodea,B.Iraupena,A.Baloraturik,A.AukeratutakoPertsonaia,AVG(IF(C.Balorazioa='Ondo',10,IF(C.Balorazioa='Erdizka',5,0))) AS Batazbestekoa 
		 From Grabaketa As A Inner Join Bideoa AS B on (A.BideoaFk = B.Kodea) Inner Join Epaiketa AS C on (A.Id = C.GrabaketaFk)
		 Where A.ErabiltzaileFk = '".$key."' Group By B.Kodea";
	*/

	$sql =  "Select A.name,B.file_identifier,B.id,A.duration,B.rating_amount,B.character_name,B.adding_date,B.adding_date,avg(C.score) AS Batazbestekoa 
		 From (exercise As A Inner Join response As B on A.id = B.fk_exercise_id) Inner Join evaluation As C on C.fk_response_id = B.id
		 Where B.fk_user_id = '".$key."' Group By A.id";

	//error_log($sql, 3, "/tmp/amfphp.txt");
	
         $searchResults = $this->_listQuery($sql);
		
         return $searchResults;
	}

	function epaitutakoGrabaketa($key)
	{
		//error_log("San Marcos \n", 3, "/tmp/amfphp.txt");
		//$sql = "Select ErabiltzaileFk, Balorazioa, Data, Iruzkinak,BideoIruzkina From Epaiketa Where GrabaketaFk = '".$key."'";

		$sql = "Select C.name,A.score,A.adding_date,A.comment,B.video_identifier
			From (evaluation AS A Inner Join users AS C ON A.fk_user_id = C.id)Left Outer Join evaluation_video AS B on A.id = B.fk_evaluation_id
			Where A.fk_response_id = '".$key."'";		


		//error_log($sql,3,"/tmp/amfphp.txt");
		$searchResults = $this->_epaiketaEmaitzak($sql);

		//$mezua = print_r($searchResults, true);
         	//error_log($mezua, 3, "/tmp/amfphp.txt");

		return $searchResults;
	}




	function updateGrabaketa($key)
	{
		//error_log("HELDU  DA \n",3,"/tmp/amfphp.txt");
		$sql = "UPDATE response SET rating_amount = (rating_amount + 1) WHERE (id = '".$key."')";

		//error_log($sql." \n",3,"/tmp/amfphp.txt");

		$result = $this->_databaseUpdate($sql);

	         if ($result != 1)
	         {
	            return false;
	         }
	         return true;
	}

	function bideoaEzabatu($key)
	{
		$agindua = "rm /usr/lib/red5/webapps/oflaDemo/streams/videoComment/".$key.".flv";
		//error_log($agindua." \n",3,"/tmp/amfphp.txt");		
		exec($agindua);
		return true;
	}


	function insertEpaiketa($grab,$erab,$bal,$com)
	{

		$sql = "INSERT INTO evaluation (id,fk_response_id,fk_user_id,score,comment)";
		$sql = $sql."VALUES ('',";
		$sql = $sql."'".$grab."', ";
		$sql = $sql."'".$erab."', ";
		$sql = $sql."'".$bal."', ";
		$sql = $sql."'".$com."')";

		$result = $this->_databaseUpdate($sql);


		$sql = "SELECT last_insert_id()";
		$result = $this->conn->_execute($sql);

		if ($row = $this->conn->_nextRow($result))
		{
			return $row[0];
		}
		else
		{
			return false;
		}
	
	}


	function insertVideoEpaiketa($grab,$erab,$bal,$com,$bid)
	{
		$sql = "INSERT INTO evaluation (id,fk_response_id,fk_user_id,score,comment)";
		$sql = $sql."VALUES ('',";
		$sql = $sql."'".$grab."', ";
		$sql = $sql."'".$erab."', ";
		$sql = $sql."'".$bal."', ";
		$sql = $sql."'".$com."')";
		$result = $this->_databaseUpdate($sql);


		$sql = "SELECT last_insert_id()";
		$result = $this->conn->_execute($sql);

		if ($row = $this->conn->_nextRow($result))
		{
			$lastid = $row[0];
			//video_sartu($lastid,$bid);

			$sql = "INSERT INTO evaluation_video (id,fk_evaluation_id,video_identifier,source)";
			$sql = $sql."VALUES ('',";
			$sql = $sql."'".$lastid."', ";
			$sql = $sql."'".$bid."', ";
			$sql = $sql."'Red5')";
			$result = $this->_databaseUpdate($sql);


			return $lastid;
		}
		else
		{
			return false;
		}
	
	}


      function _databaseUpdate($sql)
      {
         $result = $this->conn->_execute($sql);

         return $result;
      }
    
   }

?>