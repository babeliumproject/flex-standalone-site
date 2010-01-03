<?php

class Datasource
{
   var $dbLink;

   function Datasource($dbHost, $dbName, $dbuser, $dbpasswd)
   {
      $this->dbLink = mysql_connect ($dbHost, $dbuser, $dbpasswd);
      mysql_select_db ($dbName, $this->dbLink);
   }

   function _execute($sql)
   {
      $result = mysql_query($sql, $this->dbLink);
      $this->_checkErrors($sql);
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
