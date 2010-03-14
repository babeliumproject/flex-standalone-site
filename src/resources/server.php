<?php

// First import Zend's basic classes
require_once 'Zend/Loader.php';
require_once 'Zend/Amf/Server.php';

// Import here your DAO classes
require_once './amfphp/services/babelia/Epaitu.php';
require_once './amfphp/services/babelia/ShowSubLang.php';

require_once './amfphp/services/babelia/CreditDAO.php';
require_once './amfphp/services/babelia/ExerciseDAO.php';
require_once './amfphp/services/babelia/LoginDAO.php';
require_once './amfphp/services/babelia/PreferenceDAO.php';
require_once './amfphp/services/babelia/RegisterUser.php';
require_once './amfphp/services/babelia/ResponseDAO.php';
require_once './amfphp/services/babelia/SubtitleDAO.php';
require_once './amfphp/services/babelia/SubtitlesAndRolesDAO.php';
require_once './amfphp/services/babelia/TranscriptionsDAO.php';
require_once './amfphp/services/babelia/UserDAO.php';
require_once './amfphp/services/babelia/UploadExerciseDAO.php';
require_once './amfphp/services/babelia/YouTubeDAO.php';


/** Bootstrap */

// Instantiate server
$server = new Zend_Amf_Server();

// Disabling production shows more detailed errors.
$server->setProduction(false);

// Add class to be reflected
$server->setClass('Epaitu');
$server->setClass('ShowSubLang');
$server->setClass('CreditDAO');
$server->setClass('ExerciseDAO');
$server->setClass('LoginDAO');
$server->setClass('PreferenceDAO');
$server->setClass('RegisterUser');
$server->setClass('ResponseDAO');
$server->setClass('SubtitleDAO');
$server->setClass('SubtitlesAndRolesDAO');
$server->setClass('UserDAO');
$server->setClass('UploadExerciseDAO');
$server->setClass('YouTubeDAO');
$server->setClass('TranscriptionsDAO');

// Establish associations between PHP classes and their AS3 counterparts
$server->setClassMap('ContactVO',"Contact");
$server->setClassMap('Bideoa',"Bideoa");
$server->setClassMap('CreditHistoryVO',"CreditHistoryVO");
$server->setClassMap('Epai',"Epai");
$server->setClassMap('ExerciseCommentVO',"ExerciseCommentVO");
$server->setClassMap('ExerciseLevelVO',"ExerciseLevelVO");
$server->setClassMap('ExerciseRoleVO',"ExerciseRoleVO");
$server->setClassMap('ExerciseScoreVO',"ExerciseScoreVO");
$server->setClassMap('ExerciseVO',"ExerciseVO");
$server->setClassMap('LoginVO',"LoginVO");
$server->setClassMap('PreferenceVO',"PreferenceVO");
$server->setClassMap('ResponseVO', "ResponseVO");
$server->setClassMap('Sub',"Sub");
$server->setClassMap('SubtitleAndSubtitleLinesVO',"SubtitleAndSubtitleLinesVO");
$server->setClassMap('SubtitlesAndRolesVO', "SubtitlesAndRolesVO");
$server->setClassMap('SubtitleLineVO',"SubtitleLineVO");
$server->setClassMap('UserVO',"UserVO");
$server->setClassMap('NewUserVO',"NewUserVO");
$server->setClassMap('TranscriptionsVO',"TranscriptionsVO");

//Add directories reachable for Zend AMF
$server->addDirectory(dirname(__FILE__) .'/amfphp/services/babelia');

// Handle request
$response = $server->handle();
echo $response;

?>