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

<form name="loginform" id="loginform" action="bp-login.php" method="post">
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
<input type="hidden" name="redirect_to" value="http://babeliumhtml5/bp-labs/" />
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

