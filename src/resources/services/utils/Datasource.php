<?php

class Datasource
{
   var $dbLink;

   function Datasource($dbHost, $dbName, $dbuser, $dbpasswd)
   {
      $this->dbLink = mysql_connect ($dbHost, $dbuser, $dbpasswd);
      mysql_select_db ($dbName, $this->dbLink);
      mysql_set_charset('utf8',$this->dbLink);	
   }

   function _execute()
   {
      if ( is_array(func_get_arg(0)) ) 
         return $this->_vexecute(func_get_arg(0)); // Get's an array of parameters
      else
         return $this->_vexecute(func_get_args()); // Get's separate parameteres
   }
   
   function _vexecute($params)
   {
      $query = array_shift($params);
      
      for ( $i = 0; $i < count($params); $i++ )
         $params[$i] = mysql_real_escape_string($params[$i]);
      
      $query = vsprintf($query, $params);
 
      $result = mysql_query($query, $this->dbLink);
      $this->_checkErrors($query);
      
      return $result;
   }

   function _executeBlind($sql)
   {
      $result = mysql_query($sql, $this->dbLink);
      return $result;
   }

   function _nextRow ($result)
   {
      $row = mysql_fetch_array($result);
      return $row;
   }

   function _checkErrors($sql)
   {
      $err=mysql_error();
      $errno=mysql_errno();

      if($errno)
      {
         $message = "The following SQL command ".$sql." caused Database error: ".$err.".";

         print "Unrecowerable error has occurred. All data will be logged.";
         print "Please contact System Administrator for help! \n";
         print "<!-- ".$message." -->\n";
         exit;
      }
      else
      {
         return;
      }
   }
}

?>
