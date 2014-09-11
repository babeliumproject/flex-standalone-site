<?php

require_once 'migrationutils.php';


function generate_migration_template(){
	global $CFG;
	$models = get_database_models($CFG->db_name);
	return "<?php

require_once 'migrationutils';\n
		
function forwards(){
	
}

function backwards(){

}

\$models = '$models';
	
";
}

function run_command($_argv) {
	if (!isset($_argv[1])) {
		throw new \Exception('No command specified');
	}
	$cmd = $_argv[1];
	$opts = array_slice($_argv, 2);

	if (!in_array($cmd, array('create', 'migrate'))) {
		throw new \Exception('Invalid Command');
	}

	if ($cmd === 'create') {
		if ($opts[0] === '-n') {
			create_migration_file($opts[1]);
			return;
		} else {
			throw new \Exception('Invalid Command');
		}
	}

	if ($cmd === 'migrate') {
		$n = array_search('-n', $opts);
		$name = $n === false ? null : $opts[$n+1];
		$fake = array_search('--fake', $opts) === false ? false : true; // lol! php
		$recover = !$fake && array_search('--recover', $opts) !== false;
		run_migrations($name, $fake, $recover);
		return;
	}
}

function run_migrations($name, $fake, $recover){
	
}

function create_migration_file($name) {
	$name = preg_replace('/[^a-zA-Z_-]/', '_', $name);
	$arr = array(
			'{{ timestamp }}' => time(),
			'{{ name }}' => $name,
	);
	$filename = str_replace(array_keys($arr), array_values($arr), '{{ timestamp }}_{{ name }}');
	$file = dirname(__FILE__) . '/' . $filename.'.php';
	
	$t = generate_migration_template();
	$fh = fopen($file, 'w') or die("can't open file");
	fwrite($fh, $t);
	fclose($fh);
	echo 'Migration code generated in file - ' . $file;
}

try {
	run_command($argv);
}
catch (Exception $e) {
	echo ('Failed with ' . get_class($e) . ': ' . $e->getMessage()."\n");
}