<?php


require_once ("../Config.php");
require_once ("../Datasource.php");


class videoCommentDelete
{
	public function delete()
	{

		$settings = new Config();
		$this->conn = new DataSource($settings->host, $settings->db_name, $settings->db_username, $settings->db_password);


		//Datu basetik datuak lortu
		$sql = "SELECT video_identifier FROM evaluation_video";
		$result = $this->conn->_execute($sql);

		$i = 0;
		while ( $row = $this->conn->_nextRow($result) ) {
			$zerrenda_db[$i] = $row[1];
			$i++;
		}



		//Zerbitzaritik fitxategiak lortu
		$sql = "SELECT prefValue FROM preferences WHERE prefName='videoCommentPath'";
		$result = $this->conn->_execute($sql);
		$row = $this->conn->_nextRow($result);
		$path = $row[0]; // videoComment path

		$directorio = dir($path);


		//echo "Directorio".$path.":<br><br>";

		$i = 0;
		while ($archivo = $directorio->read())
		{
			$helbidea = pathinfo($path.$archivo);
			if ($helbidea['extension'] == 'flv'){
				$zerrenda_iz[$i] = $helbidea['filename'];
				$zerrenda[$i] = $archivo;
				$i++;
			}
		}

		sort($zerrenda_iz);
		sort($zerrenda_db);
		sort($zerrenda);
		$i=0;
		for($i=0;$i<=count($zerrenda);$i++)
		{
			if(!in_array($zerrenda_iz[$i],$zerrenda_db)){
				//echo $zerrenda[$i];
				//ezabatzeko agindua
				exec("rm ".$path.$zerrenda[$i]);
				//echo $path.$zerrenda[$i]."<br><br><br>";
			}

		}


		$directorio->close();

	}
}
//$own = new videoCommentDelete();
//$own->delete();
?>