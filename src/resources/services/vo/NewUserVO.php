<?php

class NewUserVO
	{
	
	public $username;
	public $password;
	public $firstname;
	public $lastname;
	public $email;
	public $activationHash;
	
	public $languages;

	//This string specifies the path to a same kind ValueObject AS3 class in our Flex application
	public $_explicitType = "NewUserVO";
	}
?>
