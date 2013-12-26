<?

  require_once("Correo.php");
  $correo = new Correo("juanan@babeliumproject.com");
  $html = "<html><body><font color='red'>Red5 is down!</font></body></html>";
  $correo->send("Red5 is down", "Red5 is down", $html);



