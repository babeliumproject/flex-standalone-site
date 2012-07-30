-- MySQL dump 10.13  Distrib 5.1.49, for debian-linux-gnu (i686)
--
-- Host: localhost    Database: babeliaproject
-- ------------------------------------------------------
-- Server version	5.0.51a-3ubuntu5.4

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Not dumping tablespaces as no INFORMATION_SCHEMA.FILES table on this server
--

--
-- Current Database: `babeliumproject`
--

-- CREATE DATABASE /*!32312 IF NOT EXISTS*/ `babeliumproject` /*!40100 DEFAULT CHARACTER SET utf8 */;

-- USE `babeliumproject`;

--
-- Table structure for table `credithistory`
--

DROP TABLE IF EXISTS `credithistory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `credithistory` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `fk_user_id` int(10) unsigned NOT NULL,
  `fk_exercise_id` int(10) unsigned NOT NULL,
  `fk_response_id` int(10) unsigned default NULL,
  `fk_eval_id` int(10) unsigned default NULL,
  `changeDate` datetime NOT NULL,
  `changeType` varchar(45) NOT NULL,
  `changeAmount` int(11) NOT NULL default '0',
  PRIMARY KEY  USING BTREE (`id`),
  KEY `FK_credithistory_1` (`fk_user_id`),
  KEY `FK_credithistory_3` (`fk_response_id`),
  KEY `FK_credithistory_2` (`fk_exercise_id`),
  CONSTRAINT `FK_credithistory_1` FOREIGN KEY (`fk_user_id`) REFERENCES `users` (`ID`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `FK_credithistory_2` FOREIGN KEY (`fk_exercise_id`) REFERENCES `exercise` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_credithistory_3` FOREIGN KEY (`fk_response_id`) REFERENCES `response` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `evaluation`
--

DROP TABLE IF EXISTS `evaluation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `evaluation` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `fk_response_id` int(10) unsigned NOT NULL,
  `fk_user_id` int(10) unsigned NOT NULL,
  `score_overall` tinyint(4) default '0',
  `comment` text,
  `adding_date` timestamp NULL default CURRENT_TIMESTAMP,
  `score_intonation` tinyint(3) unsigned default '0',
  `score_fluency` tinyint(3) unsigned default '0',
  `score_rhythm` tinyint(3) unsigned default '0',
  `score_spontaneity` tinyint(3) unsigned default '0',
  PRIMARY KEY  (`id`),
  KEY `FK_evaluation_1` (`fk_response_id`),
  KEY `FK_evaluation_2` (`fk_user_id`),
  CONSTRAINT `FK_evaluation_1` FOREIGN KEY (`fk_response_id`) REFERENCES `response` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_evaluation_2` FOREIGN KEY (`fk_user_id`) REFERENCES `users` (`ID`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `evaluation_video`
--

DROP TABLE IF EXISTS `evaluation_video`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `evaluation_video` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `fk_evaluation_id` int(10) unsigned NOT NULL,
  `video_identifier` varchar(100) NOT NULL,
  `source` enum('Youtube','Red5') NOT NULL,
  `thumbnail_uri` varchar(200) NOT NULL default 'nothumb.png',
  `duration` int(10) unsigned NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `FK_evaluation_video_1` (`fk_evaluation_id`),
  CONSTRAINT `FK_evaluation_video_1` FOREIGN KEY (`fk_evaluation_id`) REFERENCES `evaluation` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `exercise`
--

DROP TABLE IF EXISTS `exercise`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `exercise` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(200) NOT NULL COMMENT 'In case it''s Youtube video we''ll store here it''s uid',
  `description` text NOT NULL COMMENT 'Describe the video''s content',
  `source` enum('Youtube','Red5') NOT NULL COMMENT 'Specifies where the video comes from',
  `language` varchar(45) NOT NULL COMMENT 'The spoken language of this exercise',
  `fk_user_id` int(10) unsigned NOT NULL COMMENT 'Who suggested or uploaded this video',
  `tags` varchar(100) NOT NULL COMMENT 'Tag list each item separated with a comma',
  `title` varchar(80) NOT NULL,
  `thumbnail_uri` varchar(200) character set latin1 NOT NULL default 'nothumb.png',
  `adding_date` datetime NOT NULL,
  `duration` int(10) unsigned NOT NULL,
  `status` enum('Unprocessed','Processing','Available','Rejected','Error','Unavailable','UnprocessedNoPractice') NOT NULL default 'Unprocessed',
  `filehash` varchar(32) character set latin1 NOT NULL default 'none',
  `fk_transcription_id` int(10) unsigned default NULL,
  `license` varchar(60) NOT NULL default 'cc-by' COMMENT 'The kind of license this exercise is attached to',
  `reference` text NOT NULL COMMENT 'The url or name of the entity that provided this resource (if any)',
  PRIMARY KEY  (`id`),
  KEY `FK_exercises_1` (`fk_user_id`),
  KEY `fk_exercise_transcriptions1` (`fk_transcription_id`),
  CONSTRAINT `FK_exercises_1` FOREIGN KEY (`fk_user_id`) REFERENCES `users` (`ID`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_exercise_transcriptions1` FOREIGN KEY (`fk_transcription_id`) REFERENCES `transcription` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `exercise_comment`
--

DROP TABLE IF EXISTS `exercise_comment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `exercise_comment` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `fk_exercise_id` int(10) unsigned NOT NULL,
  `fk_user_id` int(10) unsigned NOT NULL,
  `comment` text NOT NULL,
  `comment_date` datetime NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `FK_exercise_comments_1` (`fk_exercise_id`),
  KEY `FK_exercise_comments_2` (`fk_user_id`),
  CONSTRAINT `FK_exercise_comments_1` FOREIGN KEY (`fk_exercise_id`) REFERENCES `exercise` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_exercise_comments_2` FOREIGN KEY (`fk_user_id`) REFERENCES `users` (`ID`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `exercise_level`
--

DROP TABLE IF EXISTS `exercise_level`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `exercise_level` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `fk_exercise_id` int(10) unsigned NOT NULL,
  `fk_user_id` int(10) unsigned NOT NULL,
  `suggested_level` int(10) unsigned NOT NULL COMMENT 'Level dificulty goes upwards from 1 to 6',
  `suggest_date` datetime NOT NULL,
  PRIMARY KEY  USING BTREE (`id`),
  KEY `FK_exercise_level_1` (`fk_exercise_id`),
  KEY `FK_exercise_level_2` (`fk_user_id`),
  CONSTRAINT `FK_exercise_level_1` FOREIGN KEY (`fk_exercise_id`) REFERENCES `exercise` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_exercise_level_2` FOREIGN KEY (`fk_user_id`) REFERENCES `users` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `exercise_report`
--

DROP TABLE IF EXISTS `exercise_report`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `exercise_report` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `fk_exercise_id` int(10) unsigned NOT NULL,
  `fk_user_id` int(10) unsigned NOT NULL,
  `reason` varchar(100) NOT NULL,
  `report_date` timestamp NOT NULL default CURRENT_TIMESTAMP,
  PRIMARY KEY  (`id`),
  KEY `FK_exercise_report_1` (`fk_exercise_id`),
  KEY `FK_exercise_report_2` (`fk_user_id`),
  CONSTRAINT `FK_exercise_report_1` FOREIGN KEY (`fk_exercise_id`) REFERENCES `exercise` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `FK_exercise_report_2` FOREIGN KEY (`fk_user_id`) REFERENCES `users` (`ID`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `exercise_role`
--

DROP TABLE IF EXISTS `exercise_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `exercise_role` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `fk_exercise_id` int(10) unsigned NOT NULL,
  `fk_user_id` int(10) unsigned NOT NULL,
  `character_name` varchar(45) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `FK_exercise_characters_1` (`fk_exercise_id`),
  KEY `FK_exercise_characters_2` (`fk_user_id`),
  CONSTRAINT `FK_exercise_characters_1` FOREIGN KEY (`fk_exercise_id`) REFERENCES `exercise` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_exercise_characters_2` FOREIGN KEY (`fk_user_id`) REFERENCES `users` (`ID`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `exercise_score`
--

DROP TABLE IF EXISTS `exercise_score`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `exercise_score` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `fk_exercise_id` int(10) unsigned NOT NULL,
  `fk_user_id` int(10) unsigned NOT NULL,
  `suggested_score` int(10) unsigned NOT NULL COMMENT 'Score will be a value between 1 and 5',
  `suggestion_date` datetime NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `FK_exercise_score_1` (`fk_exercise_id`),
  KEY `FK_exercise_score_2` (`fk_user_id`),
  CONSTRAINT `FK_exercise_score_1` FOREIGN KEY (`fk_exercise_id`) REFERENCES `exercise` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_exercise_score_2` FOREIGN KEY (`fk_user_id`) REFERENCES `users` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `motd`
--

DROP TABLE IF EXISTS `motd`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `motd` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `title` varchar(250) NOT NULL,
  `message` text NOT NULL,
  `resource` varchar(250) NOT NULL,
  `displaydate` datetime NOT NULL,
  `displaywhenloggedin` tinyint(1) NOT NULL default '0',
  `code` varchar(45) default NULL COMMENT 'A numeric code to identify this particular message in different languages',
  `language` varchar(5) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `preferences`
--

DROP TABLE IF EXISTS `preferences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `preferences` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `prefName` varchar(45) NOT NULL,
  `prefValue` varchar(200) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `response`
--

DROP TABLE IF EXISTS `response`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `response` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `fk_user_id` int(10) unsigned NOT NULL,
  `fk_exercise_id` int(10) unsigned NOT NULL,
  `file_identifier` varchar(100) NOT NULL,
  `is_private` tinyint(1) NOT NULL,
  `thumbnail_uri` varchar(200) NOT NULL default 'nothumb.png',
  `source` enum('Youtube','Red5') NOT NULL,
  `duration` int(10) unsigned NOT NULL,
  `adding_date` datetime NOT NULL,
  `rating_amount` int(10) NOT NULL,
  `character_name` varchar(45) NOT NULL,
  `fk_transcription_id` int(10) unsigned default NULL,
  `fk_subtitle_id` int(10) unsigned default NULL,
  `priority_date` timestamp NOT NULL default CURRENT_TIMESTAMP,
  PRIMARY KEY  (`id`),
  KEY `FK_response_1` (`fk_user_id`),
  KEY `FK_response_2` (`fk_exercise_id`),
  KEY `fk_response_transcriptions1` (`fk_transcription_id`),
  KEY `FK_response_3` (`fk_subtitle_id`),
  CONSTRAINT `FK_response_1` FOREIGN KEY (`fk_user_id`) REFERENCES `users` (`ID`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `FK_response_2` FOREIGN KEY (`fk_exercise_id`) REFERENCES `exercise` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_response_3` FOREIGN KEY (`fk_subtitle_id`) REFERENCES `subtitle` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_response_transcriptions1` FOREIGN KEY (`fk_transcription_id`) REFERENCES `transcription` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `spinvox_request`
--

DROP TABLE IF EXISTS `spinvox_request`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `spinvox_request` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `x_error` varchar(45) NOT NULL,
  `url` varchar(200) default NULL,
  `date` datetime NOT NULL,
  `fk_transcription_id` int(10) unsigned NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `fk_spinvox_requests_transcription1` (`fk_transcription_id`),
  CONSTRAINT `fk_spinvox_requests_transcription1` FOREIGN KEY (`fk_transcription_id`) REFERENCES `transcription` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `subtitle`
--

DROP TABLE IF EXISTS `subtitle`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `subtitle` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `fk_exercise_id` int(10) unsigned NOT NULL,
  `fk_user_id` int(10) unsigned NOT NULL,
  `language` varchar(45) NOT NULL,
  `translation` tinyint(1) NOT NULL default '0',
  `adding_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `complete` TINYINT(1) UNSIGNED NOT NULL DEFAULT '0',
  PRIMARY KEY  (`id`),
  KEY `FK_exercise_subtitle_1` (`fk_exercise_id`),
  KEY `FK_exercise_subtitle_2` (`fk_user_id`),
  CONSTRAINT `FK_exercise_subtitle_1` FOREIGN KEY (`fk_exercise_id`) REFERENCES `exercise` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_exercise_subtitle_2` FOREIGN KEY (`fk_user_id`) REFERENCES `users` (`ID`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `subtitle_line`
--

DROP TABLE IF EXISTS `subtitle_line`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `subtitle_line` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `fk_subtitle_id` int(10) unsigned NOT NULL,
  `show_time` float unsigned NOT NULL,
  `hide_time` float unsigned NOT NULL,
  `text` varchar(255) NOT NULL,
  `fk_exercise_role_id` int(10) unsigned NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `FK_subtitle_line_1` (`fk_subtitle_id`),
  KEY `FK_subtitle_line_2` (`fk_exercise_role_id`),
  CONSTRAINT `FK_subtitle_line_1` FOREIGN KEY (`fk_subtitle_id`) REFERENCES `subtitle` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_subtitle_line_2` FOREIGN KEY (`fk_exercise_role_id`) REFERENCES `exercise_role` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `subtitle_score`
--

DROP TABLE IF EXISTS `subtitle_score`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `subtitle_score` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `fk_subtitle_id` int(10) unsigned NOT NULL,
  `fk_user_id` int(10) unsigned NOT NULL,
  `suggested_score` int(10) unsigned NOT NULL,
  `suggestion_date` datetime NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `FK_subtitle_score_1` (`fk_subtitle_id`),
  KEY `FK_subtitle_score_2` (`fk_user_id`),
  CONSTRAINT `FK_subtitle_score_1` FOREIGN KEY (`fk_subtitle_id`) REFERENCES `subtitle` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `FK_subtitle_score_2` FOREIGN KEY (`fk_user_id`) REFERENCES `users` (`ID`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tagcloud`
--

DROP TABLE IF EXISTS `tagcloud`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tagcloud` (
  `tag` varchar(100) NOT NULL,
  `amount` int(10) unsigned NOT NULL,
  PRIMARY KEY  (`tag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `transcription`
--

DROP TABLE IF EXISTS `transcription`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `transcription` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `adding_date` datetime NOT NULL,
  `status` varchar(45) NOT NULL,
  `transcription` text,
  `transcription_date` datetime default NULL,
  `system` varchar(45) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_languages`
--

DROP TABLE IF EXISTS `user_languages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_languages` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `fk_user_id` int(10) unsigned NOT NULL,
  `language` varchar(45) NOT NULL,
  `level` int(10) unsigned NOT NULL COMMENT 'Level goes from 1 to 6. 7 used for mother tongue',
  `positives_to_next_level` int(10) unsigned NOT NULL,
  `purpose` enum('practice','evaluate') NOT NULL default 'practice',
  PRIMARY KEY  (`id`),
  KEY `fk_user_id` (`fk_user_id`),
  CONSTRAINT `fk_user_id` FOREIGN KEY (`fk_user_id`) REFERENCES `users` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_session`
--

DROP TABLE IF EXISTS `user_session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_session` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `session_id` varchar(100) NOT NULL COMMENT 'Value generated by PHPs builtin function',
  `session_date` datetime NOT NULL,
  `duration` int(10) NOT NULL,
  `keep_alive` tinyint(1) NOT NULL,
  `fk_user_id` int(10) unsigned NOT NULL,
  `closed` tinyint(1) NOT NULL default '0',
  PRIMARY KEY  (`id`),
  KEY `FK_user_session_1` (`fk_user_id`),
  CONSTRAINT `FK_user_session_1` FOREIGN KEY (`fk_user_id`) REFERENCES `users` (`ID`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_videohistory`
--

DROP TABLE IF EXISTS `user_videohistory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_videohistory` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `fk_user_id` int(10) unsigned NOT NULL,
  `fk_user_session_id` int(10) unsigned NOT NULL,
  `fk_exercise_id` int(10) unsigned NOT NULL,
  `response_attempt` tinyint(1) NOT NULL default '0',
  `fk_response_id` int(10) unsigned default NULL,
  `incidence_date` timestamp NOT NULL default CURRENT_TIMESTAMP,
  `subtitles_are_used` tinyint(1) NOT NULL default '0',
  `fk_subtitle_id` int(10) unsigned default NULL,
  `fk_exercise_role_id` int(10) unsigned default NULL,
  PRIMARY KEY  (`id`),
  KEY `FK_user_videohistory_1` (`fk_user_id`),
  KEY `FK_user_videohistory_2` (`fk_user_session_id`),
  KEY `FK_user_videohistory_3` (`fk_exercise_id`),
  KEY `FK_user_videohistory_4` (`fk_response_id`),
  KEY `FK_user_videohistory_5` (`fk_subtitle_id`),
  KEY `FK_user_videohistory_6` (`fk_exercise_role_id`),
  CONSTRAINT `FK_user_videohistory_1` FOREIGN KEY (`fk_user_id`) REFERENCES `users` (`ID`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `FK_user_videohistory_2` FOREIGN KEY (`fk_user_session_id`) REFERENCES `user_session` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `FK_user_videohistory_3` FOREIGN KEY (`fk_exercise_id`) REFERENCES `exercise` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_user_videohistory_4` FOREIGN KEY (`fk_response_id`) REFERENCES `response` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_user_videohistory_5` FOREIGN KEY (`fk_subtitle_id`) REFERENCES `subtitle` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_user_videohistory_6` FOREIGN KEY (`fk_exercise_role_id`) REFERENCES `exercise_role` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `ID` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(45) NOT NULL,
  `password` varchar(45) NOT NULL,
  `email` varchar(45) NOT NULL,
  `realName` varchar(45) NOT NULL,
  `realSurname` varchar(45) NOT NULL,
  `creditCount` int(10) unsigned NOT NULL default '0',
  `joiningDate` timestamp NOT NULL default CURRENT_TIMESTAMP,
  `active` tinyint(1) NOT NULL default '0',
  `activation_hash` varchar(20) NOT NULL,
  `isAdmin` tinyint(4) NOT NULL default '0',
  PRIMARY KEY  (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;


/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2011-06-13 10:21:47
