<?php

// First import Zend's basic classes
require_once 'Zend/Loader.php';
require_once 'Zend/Amf/Server.php';



// Import here your DAO classes
require_once './amfphp/services/babelia/CreditDAO.php';
require_once './amfphp/services/babelia/EvaluationDAO.php';
require_once './amfphp/services/babelia/ExerciseDAO.php';
require_once './amfphp/services/babelia/ExerciseRoleDAO.php';
require_once './amfphp/services/babelia/LoginDAO.php';
require_once './amfphp/services/babelia/Mailer.php';
require_once './amfphp/services/babelia/PeriodicTaskDAO.php';
require_once './amfphp/services/babelia/PreferenceDAO.php';
require_once './amfphp/services/babelia/RegisterUser.php';
require_once './amfphp/services/babelia/ResponseDAO.php';
require_once './amfphp/services/babelia/SearchDAO.php';
require_once './amfphp/services/babelia/SubtitleDAO.php';
require_once './amfphp/services/babelia/TagCloudDAO.php';
require_once './amfphp/services/babelia/TranscriptionsDAO.php';
require_once './amfphp/services/babelia/UploadExerciseDAO.php';
require_once './amfphp/services/babelia/UserDAO.php';
require_once './amfphp/services/babelia/UserVideoHistoryDAO.php';
require_once './amfphp/services/babelia/YouTubeDAO.php';

/** Bootstrap */

// Instantiate server
$server = new Zend_Amf_Server();

// Disabling production shows more detailed errors.
$server->setProduction(false);

//Add directories reachable for Zend AMF
$server->addDirectory(dirname(__FILE__) .'/amfphp/services/babelia');
$server->addDirectory(dirname(__FILE__) .'/amfphp/services/babelia/utils');
$server->addDirectory(dirname(__FILE__) .'/amfphp/services/babelia/vo');

// Add class to be reflected
$server->setClass('CreditDAO');
$server->setClass('EvaluationDAO');
$server->setClass('ExerciseDAO');
$server->setClass('ExerciseRoleDAO');
$server->setClass('LoginDAO');
$server->setClass('Mailer');
$server->setClass('PeriodicTaskDAO');
$server->setClass('PreferenceDAO');
$server->setClass('RegisterUser');
$server->setClass('ResponseDAO');
$server->setClass('SearchDAO');
$server->setClass('SubtitleDAO');
$server->setClass('TagCloudDAO');
$server->setClass('TranscriptionsDAO');
$server->setClass('UploadExerciseDAO');
$server->setClass('UserDAO');
$server->setClass('UserVideoHistoryDAO');
$server->setClass('YouTubeDAO');


// Establish associations between PHP classes and their AS3 counterparts
$server->setClassMap('Bideoa',"Bideoa");
$server->setClassMap('CreditHistoryVO',"CreditHistoryVO");
$server->setClassMap('ExerciseCommentVO',"ExerciseCommentVO");
$server->setClassMap('ExerciseLevelVO',"ExerciseLevelVO");
$server->setClassMap('ExerciseRoleVO',"ExerciseRoleVO");
$server->setClassMap('ExerciseScoreVO',"ExerciseScoreVO");
$server->setClassMap('ExerciseVO',"ExerciseVO");
$server->setClassMap('EvaluationVO',"EvaluationVO");
$server->setClassMap('LoginVO',"LoginVO");
$server->setClassMap('PreferenceVO',"PreferenceVO");
$server->setClassMap('ResponseVO', "ResponseVO");
$server->setClassMap('SubtitleAndSubtitleLinesVO',"SubtitleAndSubtitleLinesVO");
$server->setClassMap('SubtitleLineVO',"SubtitleLineVO");
$server->setClassMap('UserVO',"UserVO");
$server->setClassMap('NewUserVO',"NewUserVO");
$server->setClassMap('TranscriptionsVO',"TranscriptionsVO");
$server->setClassMap('TagVO',"TagVO");
$server->setClassMap('ChangePassVO',"ChangePassVO");

// Handle request
$response = $server->handle();
echo $response;

?>