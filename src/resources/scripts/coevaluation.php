<?

require_once 'services/utils/Datasource.php';
require_once 'services/utils/Config.php';

$settings = new Config();
$conn = new Datasource($settings->host, 
                        $settings->db_name, 
                        $settings->db_username, 
                        $settings->db_password);

	$tabla= array();
	$nombres = array();

$sql = "SELECT id, name FROM users";
$rusers = $conn->_multipleSelect($sql);
if($rusers){
	foreach($rusers as $ruser){
		$nombres[$ruser->id] = array('name' => $ruser->name, 'evs'=>0);

		$sql = "SELECT evaluation.fk_user_id AS evaluador, response.fk_user_id AS evaluado, evaluation.score_overall AS nota
		 	FROM   evaluation, response 
		  	WHERE  evaluation.fk_user_id= %d AND evaluation.fk_response_id = response.id";

		$results = $conn->_multipleSelect($sql, $ruser->id);
	
		if($results){
			foreach($results as $result){
				$tabla[$result->evaluado][$result->evaluador] = $result->nota;
				$nombres[$result->evaluador]['evs']++;
			}
			unset($result);
		}
	}
	unset($ruser);
}

// print_r($tabla);
echo "<!-- \n";
 //print_r($nombres);
echo "!-->\n";

echo '<html><head><title>Evaluations table</title>';

echo '<style type="text/css">
	*{ font-family: Arial;}
	.myTable { background-color:#FFFFE0;border-collapse:collapse; font-size: 10px;}
	.myTable th { background-color:#969257;color:white; }
	.myTable td, .myTable th { padding:5px;border:1px solid #BDB76B; }
      </style>';

echo '</head><body>';
echo "<h1> Tabla de evaluaciones </h1>\n";
echo "<h2> Total alumnos (" . count($nombres)  . ")</h2>\n";
echo "<h3>Total alumnos sin contar Babelium y Juanan (" . (count($nombres) -2)  . ")</h3>\n";
echo "<p>";
echo "<br>&Eacute;sta es una tabla din&aacute;mica (se actualiza s&oacute;la cada vez que alguien eval&uacute;a el trabajo de otro compa&ntilde;ero/a)\n";
echo "<br>Las filas indican el evaluado. Las columnas el evaluador";
echo "<br>\nPor ejemplo, a Juanan - persona evaluado-  le han calificado ane2 - le ha puesto un 8 - y beatriz - le ha puesto un 7 -, etc. ";
echo "<br>\n (En las filas) Al lado del nombre del evaluado aparece el n&uacute;mero de evaluaciones recibidas ";
echo "<br>\n (En las columnas) Al lado del nombre del evaluador aparece el n&uacute;mero de evaluaciones emitidas ";
echo "<br>\n Puedes copiar la tabla en una hoja de c&aacute;lculo Excel para tratarla mejor";
echo "<br>\n  (pulsa Ctrl+A para seleccionar todo, luego Ctr+C para copiar, abre Excel y pulsa Ctrl+V para pegar)";
echo "</p>";
echo "<table class='myTable'><tr><td></td>";


# mostrar cabecera
foreach ($nombres as $key=>$value){
 echo "<th>". $value['name']."(".$value['evs'].")</th> ";
};
 echo "<th> Nota media </th>";
echo "</tr>";

# alumno por alumno, mostrar las evaluaciones recibidas

foreach ($nombres as $evaluado=>$nombre_row){
//	if ($evaluado==0) continue;
	$nota = 0;
	$numeval = isset($tabla[$evaluado]) && is_array($tabla[$evaluado]) ? count($tabla[$evaluado]) : "";
	echo "<tr><th>". $nombres[$evaluado]['name'] . "(".$numeval.")" ."</th>";
	foreach ($nombres as $evaluador=>$nombre_col){
//		if ($evaluador==0) continue;
		
		$bg = "white";
		if ($evaluado == $evaluador)
			$bg = "grey";
		 if (isset($tabla[$evaluado][$evaluador])){
			$nota += $tabla[$evaluado][$evaluador];
			echo "<td bgcolor='".$bg."'>" . $tabla[$evaluado][$evaluador] ."</td>";
		}else{
			echo "<td bgcolor='".$bg."'> </td>";
		}
	}
	$notamedia = isset($tabla[$evaluado]) && is_array($tabla[$evaluado]) ? $nota/count($tabla[$evaluado]) : "";
	echo "<td>" . $notamedia  ."</td>";
	echo "</tr>\n";
}

echo "</table></body></html>";


?>
