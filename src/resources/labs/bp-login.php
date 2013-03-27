<?php 

//
// Main
//
session_start();

$action = isset($_REQUEST['action']) ? $_REQUEST['action'] : 'login';

if ( isset($_GET['key']) )
	$action = 'resetpass';

// validate action so as to default to the login screen
if ( !in_array($action, array('logout', 'lostpassword', 'retrievepassword', 'resetpass', 'rp', 'register', 'login'), true) )
	$action = 'login';

$http_post = ('POST' == $_SERVER['REQUEST_METHOD']);
switch ($action) {

case 'logout' :
	break;

case 'lostpassword' :
case 'retrievepassword' :
	break;

case 'resetpass' :
case 'rp' :
	break;

case 'register' :
	break;

case 'login' :
default:
	$response = '';
	// If the user wants ssl but the session is not ssl, force a secure cookie.
	if ( !empty($_POST['log']) && !empty($_POST['pwd'])) {
		//Sanitize these fields to avoid DB hijacking
		$user_name = trim($_POST['log']);
		$user_pass = trim($_POST['pwd']);
		/*
		require_once 'Zend/Rest/Client.php';
		//MAKE SURE you put your endpoint class' path here, otherways you'll receive nasty errors
		if(isset($_SERVER['SERVER_NAME']))
			$client = new Zend_Rest_Client('http://'.$_SERVER['SERVER_NAME'].'/rest/rest');
		else
			$client = new Zend_Rest_Client('http://babeliumhtml5/rest/rest');
		
		$request = array();
		$request['name'] = trim($user_name);
		$request['pass'] = sha1(trim($user_pass));
		$jrequest = json_encode($request);
		$b64req = base64_encode($jrequest);

		$result = $client->processLogin($b64req)->post();
		$success = $result->name();
		*/
		require_once 'services/Auth.php';
		$params = new stdClass();
		$params->name = $user_name;
		$params->pass = sha1($user_pass);
		$service = new Auth();
		$response = $service->processLogin($params);
	}
	//if(strlen($success)){
	if ( is_object($response) && strlen($response->name) ){
		//$_SESSION['logged'] = true;
		header('Location: '.$_POST['redirect_to']);
	} else {
?>





<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" dir="ltr" lang="en-US">
<head>
<title>Babelium Project: Log In</title>
<script type="text/javascript" src="js/jquery1.5.1.js"></script>

<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<link rel='stylesheet' id='login-css'  href='css/login.css' type='text/css' media='all' />
<meta name='robots' content='noindex,nofollow' />

</head>
<body class="login">

<div id="login">

<h1><a href="http://www.babeliumproject.com/" title="Babelium Project">Babelium Project</a></h1>

<form name="loginform" id="loginform" action="<?php echo $_SERVER['PHP_SELF']?>" method="post">
<p>
<label>Username<br />
<input type="text" name="log" id="user_login" class="input" value="" size="20" tabindex="10" /></label>
</p>
<p>
<label>Password<br />
<input type="password" name="pwd" id="user_pass" class="input" value="" size="20" tabindex="20" /></label>
</p>

<p class="forgetmenot">
<label>
<input name="rememberme" type="checkbox" id="rememberme" value="forever" tabindex="90" /> Remember Me
</label>
</p>
<br />
<br />
<p class="submit">
<input type="submit" name="bp-submit" id="bp-submit" class="button-primary" value="Log In" tabindex="100" />
<input type="hidden" name="redirect_to" value="<?php echo 'http://'.$_SERVER['SERVER_NAME'].'/bp-topic-video-generator.php' ?>" />
<input type="hidden" name="testcookie" value="1" />
</p>
</form>
<p id="nav">
<a href="http://babeliumhtml5/bp-login.php?action=register">Register</a> |
<a href="http://babeliumhtml5/bp-login.php?action=lostpassword" title="Password Lost and Found">Lost your password?</a>
</p>
</div>

<!--
<p id="backtoblog"><a href="http://blog.babeliumproject.com/" title="Are you lost?">&larr; Back to Babelium Project Blog</a></p>
-->
<script type="text/javascript">

function wp_attempt_focus(){
	setTimeout( function(){ 
			try{
			d = document.getElementById('user_login');
			d.focus();
			d.select();
			} catch(e){
			}
			}, 200);
}

wp_attempt_focus();

//if(typeof wpOnload=='function')
//   wpOnload();

</script>
</body>
</html>
<?php
}
break;
}
?>
