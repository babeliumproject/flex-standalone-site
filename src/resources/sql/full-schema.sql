-- CREATE DATABASE  IF NOT EXISTS `babelium` /*!40100 DEFAULT CHARACTER SET utf8 */;
-- USE `babelium`;

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
-- Table structure for table `assignment`
--

DROP TABLE IF EXISTS `assignment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `assignment` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `fk_course_id` int(10) unsigned NOT NULL,
  `fk_exercise_id` int(10) unsigned NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` longtext NOT NULL,
  `duedate` bigint(10) unsigned NOT NULL DEFAULT '0',
  `allowsubmissionsfromdate` bigint(10) unsigned NOT NULL DEFAULT '0',
  `grade` bigint(10) unsigned NOT NULL DEFAULT '0',
  `timemodified` bigint(10) unsigned NOT NULL DEFAULT '0',
  `maxattempts` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `fk_assignment_1` (`fk_course_id`),
  KEY `fk_assignment_2_idx` (`fk_exercise_id`),
  CONSTRAINT `fk_assignment_1` FOREIGN KEY (`fk_course_id`) REFERENCES `course` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_assignment_2` FOREIGN KEY (`fk_exercise_id`) REFERENCES `exercise` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `assignment_submission`
--

DROP TABLE IF EXISTS `assignment_submission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `assignment_submission` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `fk_assignment_id` int(10) unsigned NOT NULL,
  `fk_user_id` int(10) unsigned NOT NULL,
  `timecreated` bigint(10) NOT NULL DEFAULT '0',
  `timemodified` bigint(10) NOT NULL DEFAULT '0',
  `status` varchar(255) NOT NULL DEFAULT '',
  `attempnumber` int(10) unsigned DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `fk_assignment_submission_1` (`fk_assignment_id`),
  KEY `fk_assignment_submission_2` (`fk_user_id`),
  CONSTRAINT `fk_assignment_submission_1` FOREIGN KEY (`fk_assignment_id`) REFERENCES `assignment` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_assignment_submission_2` FOREIGN KEY (`fk_user_id`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `course`
--

DROP TABLE IF EXISTS `course`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `course` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `fullname` varchar(255) NOT NULL DEFAULT '',
  `shortname` varchar(255) NOT NULL DEFAULT '',
  `summary` longtext,
  `startdate` bigint(10) NOT NULL DEFAULT '0',
  `visible` tinyint(1) NOT NULL DEFAULT '1',
  `language` varchar(45) NOT NULL DEFAULT '',
  `timecreated` bigint(10) NOT NULL DEFAULT '0',
  `timemodified` bigint(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `credithistory`
--

DROP TABLE IF EXISTS `credithistory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `credithistory` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `fk_user_id` int(10) unsigned NOT NULL,
  `fk_exercise_id` int(10) unsigned NOT NULL,
  `fk_response_id` int(10) unsigned DEFAULT NULL,
  `fk_eval_id` int(10) unsigned DEFAULT NULL,
  `changeDate` datetime NOT NULL,
  `changeType` varchar(45) NOT NULL,
  `changeAmount` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `FK_credithistory_1` (`fk_user_id`),
  KEY `FK_credithistory_3` (`fk_response_id`),
  KEY `FK_credithistory_2` (`fk_exercise_id`),
  CONSTRAINT `FK_credithistory_1` FOREIGN KEY (`fk_user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
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
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `fk_response_id` int(10) unsigned NOT NULL,
  `fk_user_id` int(10) unsigned NOT NULL,
  `comment` text,
  `adding_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `score_overall` tinyint(4) DEFAULT '0',
  `score_intonation` tinyint(3) unsigned DEFAULT '0',
  `score_fluency` tinyint(3) unsigned DEFAULT '0',
  `score_rhythm` tinyint(3) unsigned DEFAULT '0',
  `score_spontaneity` tinyint(3) unsigned DEFAULT '0',
  `score_comprehensibility` tinyint(3) unsigned DEFAULT '0',
  `score_pronunciation` tinyint(3) unsigned DEFAULT '0',
  `score_adequacy` tinyint(3) unsigned DEFAULT '0',
  `score_range` tinyint(3) unsigned DEFAULT '0',
  `score_accuracy` tinyint(3) unsigned DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `FK_evaluation_1` (`fk_response_id`),
  KEY `FK_evaluation_2` (`fk_user_id`),
  CONSTRAINT `FK_evaluation_1` FOREIGN KEY (`fk_response_id`) REFERENCES `response` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_evaluation_2` FOREIGN KEY (`fk_user_id`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `evaluation_video`
--

DROP TABLE IF EXISTS `evaluation_video`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `evaluation_video` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `fk_evaluation_id` int(10) unsigned NOT NULL,
  `video_identifier` varchar(100) NOT NULL,
  `source` enum('Youtube','Red5') NOT NULL,
  `thumbnail_uri` varchar(200) NOT NULL DEFAULT 'nothumb.png',
  `duration` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
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
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `exercisecode` varchar(255) NOT NULL COMMENT 'In case it''s Youtube video we''ll store here it''s uid',
  `title` varchar(80) NOT NULL,
  `description` text NOT NULL COMMENT 'Describe the video''s content',
  `language` varchar(45) NOT NULL COMMENT 'The spoken language of this exercise',
  `difficulty` int(10) unsigned NOT NULL COMMENT '1: A1, 2: A2, 3: B1, 4: B2, 5: C',
  `fk_user_id` int(10) unsigned NOT NULL COMMENT 'Who suggested or uploaded this video',
  `status` tinyint(2) NOT NULL DEFAULT '0' COMMENT '0: draft, 1: ready',
  `visible` tinyint(1) NOT NULL DEFAULT '0' COMMENT '0: visible only to author, 1: visible in scope',
  `fk_scope_id` int(10) unsigned NOT NULL DEFAULT '1',
  `timecreated` int(11) NOT NULL DEFAULT '0',
  `timemodified` int(11) NOT NULL DEFAULT '0',
  `type` int(11) NOT NULL DEFAULT '5',
  `situation` int(11) DEFAULT NULL,
  `competence` int(11) DEFAULT NULL,
  `lingaspects` int(11) DEFAULT NULL,
  `licence` varchar(60) NOT NULL DEFAULT 'cc-by',
  `attribution` text,
  `likes` int(11) NOT NULL DEFAULT '0',
  `dislikes` int(11) NOT NULL DEFAULT '0',
  `ismodel` tinyint(1) NOT NULL DEFAULT '0',
  `model_id` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name_UNIQUE` (`exercisecode`),
  KEY `FK_exercises_1` (`fk_user_id`),
  CONSTRAINT `fk_exercises_1` FOREIGN KEY (`fk_user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `exercise_comment`
--

DROP TABLE IF EXISTS `exercise_comment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `exercise_comment` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `fk_exercise_id` int(10) unsigned NOT NULL,
  `fk_user_id` int(10) unsigned NOT NULL,
  `comment` text NOT NULL,
  `comment_date` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_exercise_comments_1` (`fk_exercise_id`),
  KEY `FK_exercise_comments_2` (`fk_user_id`),
  CONSTRAINT `FK_exercise_comments_1` FOREIGN KEY (`fk_exercise_id`) REFERENCES `exercise` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_exercise_comments_2` FOREIGN KEY (`fk_user_id`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `exercise_descriptor`
--

DROP TABLE IF EXISTS `exercise_descriptor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `exercise_descriptor` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `situation` tinyint(2) unsigned NOT NULL DEFAULT '1',
  `level` tinyint(3) unsigned NOT NULL DEFAULT '1',
  `competence` tinyint(3) unsigned NOT NULL DEFAULT '1',
  `number` int(10) unsigned NOT NULL DEFAULT '1',
  `alte` tinyint(1) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`situation`,`level`,`competence`,`number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `exercise_descriptor_i18n`
--

DROP TABLE IF EXISTS `exercise_descriptor_i18n`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `exercise_descriptor_i18n` (
  `fk_exercise_descriptor_id` int(10) unsigned NOT NULL,
  `locale` varchar(8) NOT NULL,
  `name` text NOT NULL,
  PRIMARY KEY (`fk_exercise_descriptor_id`,`locale`),
  KEY `fk_exercise_descriptor_i18n_1` (`fk_exercise_descriptor_id`),
  CONSTRAINT `fk_exercise_descriptor_i18n_1` FOREIGN KEY (`fk_exercise_descriptor_id`) REFERENCES `exercise_descriptor` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `exercise_like`
--

DROP TABLE IF EXISTS `exercise_like`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `exercise_like` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `fk_exercise_id` int(10) unsigned NOT NULL,
  `fk_user_id` int(10) unsigned NOT NULL,
  `like` tinyint(1) NOT NULL DEFAULT '0',
  `timecreated` int(11) NOT NULL,
  `timemodified` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UNIQUE_exercise_like` (`fk_exercise_id`,`fk_user_id`),
  KEY `FK_exercise_like_1` (`fk_exercise_id`),
  KEY `FK_exercise_like_2` (`fk_user_id`),
  CONSTRAINT `fk_exercise_like_1` FOREIGN KEY (`fk_exercise_id`) REFERENCES `exercise` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_exercise_like_2` FOREIGN KEY (`fk_user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `exercise_report`
--

DROP TABLE IF EXISTS `exercise_report`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `exercise_report` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `fk_exercise_id` int(10) unsigned NOT NULL,
  `fk_user_id` int(10) unsigned NOT NULL,
  `reason` varchar(100) NOT NULL,
  `report_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `FK_exercise_report_1` (`fk_exercise_id`),
  KEY `FK_exercise_report_2` (`fk_user_id`),
  CONSTRAINT `FK_exercise_report_1` FOREIGN KEY (`fk_exercise_id`) REFERENCES `exercise` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `FK_exercise_report_2` FOREIGN KEY (`fk_user_id`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `media`
--

DROP TABLE IF EXISTS `media`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `media` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `mediacode` varchar(45) NOT NULL,
  `instanceid` int(10) unsigned NOT NULL,
  `component` varchar(45) NOT NULL,
  `type` varchar(45) NOT NULL DEFAULT 'video',
  `timecreated` int(11) NOT NULL DEFAULT '0',
  `timemodified` int(11) NOT NULL DEFAULT '0',
  `duration` int(10) unsigned NOT NULL DEFAULT '0',
  `level` tinyint(1) NOT NULL DEFAULT '0' COMMENT '0: undefined, 1: primary, 2: model, 3: attempt, 4: raw',
  `fk_user_id` int(10) unsigned NOT NULL,
  `defaultthumbnail` int(11) DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `code_UNIQUE` (`mediacode`),
  KEY `fk_media_1` (`fk_user_id`),
  CONSTRAINT `fk_media_1` FOREIGN KEY (`fk_user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `media_rendition`
--

DROP TABLE IF EXISTS `media_rendition`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `media_rendition` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `fk_media_id` int(10) unsigned NOT NULL,
  `filename` varchar(255) NOT NULL,
  `contenthash` varchar(40) NOT NULL,
  `status` tinyint(10) NOT NULL DEFAULT '0' COMMENT '0: raw 1: encoding, 2: ready, 3: duplicate, 4: error',
  `timecreated` int(11) NOT NULL,
  `timemodified` int(11) NOT NULL DEFAULT '0',
  `filesize` int(11) NOT NULL DEFAULT '0',
  `metadata` text,
  `dimension` int(10) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_media_rendition_1` (`fk_media_id`),
  CONSTRAINT `fk_media_rendition_1` FOREIGN KEY (`fk_media_id`) REFERENCES `media` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `motd`
--

DROP TABLE IF EXISTS `motd`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `motd` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(250) NOT NULL,
  `message` text NOT NULL,
  `resource` varchar(250) NOT NULL,
  `displaydate` datetime NOT NULL,
  `displaywhenloggedin` tinyint(1) NOT NULL DEFAULT '0',
  `code` varchar(45) DEFAULT NULL COMMENT 'A numeric code to identify this particular message in different languages',
  `language` varchar(5) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `preferences`
--

DROP TABLE IF EXISTS `preferences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `preferences` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `prefName` varchar(45) NOT NULL,
  `prefValue` varchar(200) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `prefName_UNIQUE` (`prefName`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `rel_course_role_user`
--

DROP TABLE IF EXISTS `rel_course_role_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rel_course_role_user` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `fk_role_id` int(10) unsigned NOT NULL,
  `fk_course_id` int(10) unsigned NOT NULL,
  `fk_user_id` int(10) unsigned NOT NULL,
  `timemodified` bigint(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `fk_rel_course_role_user_1` (`fk_course_id`),
  KEY `fk_rel_course_role_user_2` (`fk_role_id`),
  KEY `fk_rel_course_role_user_3` (`fk_user_id`),
  CONSTRAINT `fk_rel_course_role_user_1` FOREIGN KEY (`fk_course_id`) REFERENCES `course` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_rel_course_role_user_2` FOREIGN KEY (`fk_role_id`) REFERENCES `role` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_rel_course_role_user_3` FOREIGN KEY (`fk_user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `rel_exercise_descriptor`
--

DROP TABLE IF EXISTS `rel_exercise_descriptor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rel_exercise_descriptor` (
  `fk_exercise_id` int(10) unsigned NOT NULL,
  `fk_exercise_descriptor_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`fk_exercise_id`,`fk_exercise_descriptor_id`),
  KEY `fk_rel_exercise_descriptor_1` (`fk_exercise_id`),
  KEY `fk_rel_exercise_descriptor_2` (`fk_exercise_descriptor_id`),
  CONSTRAINT `fk_rel_exercise_descriptor_1` FOREIGN KEY (`fk_exercise_id`) REFERENCES `exercise` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_rel_exercise_descriptor_2` FOREIGN KEY (`fk_exercise_descriptor_id`) REFERENCES `exercise_descriptor` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `rel_exercise_tag`
--

DROP TABLE IF EXISTS `rel_exercise_tag`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rel_exercise_tag` (
  `fk_exercise_id` int(10) unsigned NOT NULL,
  `fk_tag_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`fk_exercise_id`,`fk_tag_id`),
  KEY `fk_rel_exercise_tag_1` (`fk_exercise_id`),
  KEY `fk_rel_exercise_tag_2` (`fk_tag_id`),
  CONSTRAINT `fk_rel_exercise_tag_1` FOREIGN KEY (`fk_exercise_id`) REFERENCES `exercise` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_rel_exercise_tag_2` FOREIGN KEY (`fk_tag_id`) REFERENCES `tag` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `response`
--

DROP TABLE IF EXISTS `response`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `response` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `fk_user_id` int(10) unsigned NOT NULL,
  `fk_exercise_id` int(10) unsigned NOT NULL,
  `fk_media_id` int(10) unsigned DEFAULT NULL,
  `file_identifier` varchar(100) NOT NULL,
  `is_private` tinyint(1) NOT NULL,
  `thumbnail_uri` varchar(200) NOT NULL DEFAULT 'nothumb.png',
  `source` enum('Youtube','Red5') NOT NULL,
  `duration` int(10) unsigned NOT NULL,
  `adding_date` datetime NOT NULL,
  `rating_amount` int(10) NOT NULL,
  `character_name` varchar(45) NOT NULL,
  `fk_transcription_id` int(10) unsigned DEFAULT NULL,
  `fk_subtitle_id` int(10) unsigned DEFAULT NULL,
  `priority_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `fileidentifier_UNIQUE` (`file_identifier`),
  KEY `FK_response_1` (`fk_user_id`),
  KEY `FK_response_2` (`fk_exercise_id`),
  KEY `fk_response_transcriptions1` (`fk_transcription_id`),
  KEY `FK_response_3` (`fk_subtitle_id`),
  CONSTRAINT `FK_response_2` FOREIGN KEY (`fk_exercise_id`) REFERENCES `exercise` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_response_3` FOREIGN KEY (`fk_subtitle_id`) REFERENCES `subtitle` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_response_transcriptions1` FOREIGN KEY (`fk_transcription_id`) REFERENCES `transcription` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `role`
--

DROP TABLE IF EXISTS `role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `role` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT '',
  `shortname` varchar(255) NOT NULL,
  `description` varchar(45) DEFAULT '',
  `sortorder` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `spinvox_request`
--

DROP TABLE IF EXISTS `spinvox_request`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `spinvox_request` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `x_error` varchar(45) NOT NULL,
  `url` varchar(200) DEFAULT NULL,
  `date` datetime NOT NULL,
  `fk_transcription_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
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
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `fk_media_id` int(10) unsigned NOT NULL,
  `fk_user_id` int(10) unsigned NOT NULL,
  `language` varchar(45) NOT NULL,
  `translation` tinyint(1) NOT NULL DEFAULT '0',
  `timecreated` int(11) NOT NULL DEFAULT '0',
  `complete` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `serialized_subtitles` longtext NOT NULL,
  `subtitle_count` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_exercise_subtitle_2` (`fk_user_id`),
  KEY `fk_subtitle_media_idx` (`fk_media_id`),
  CONSTRAINT `FK_exercise_subtitle_2` FOREIGN KEY (`fk_user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_subtitle_media` FOREIGN KEY (`fk_media_id`) REFERENCES `media` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tag`
--

DROP TABLE IF EXISTS `tag`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tag` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `transcription`
--

DROP TABLE IF EXISTS `transcription`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `transcription` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `adding_date` datetime NOT NULL,
  `status` varchar(45) NOT NULL,
  `transcription` text,
  `transcription_date` datetime DEFAULT NULL,
  `system` varchar(45) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(45) NOT NULL,
  `password` varchar(45) NOT NULL,
  `email` varchar(45) NOT NULL,
  `firstname` varchar(45) NOT NULL,
  `lastname` varchar(45) NOT NULL,
  `creditCount` int(10) unsigned NOT NULL DEFAULT '0',
  `joiningDate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `active` tinyint(1) NOT NULL DEFAULT '0',
  `activation_hash` varchar(20) NOT NULL,
  `isAdmin` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name_UNIQUE` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_languages`
--

DROP TABLE IF EXISTS `user_languages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_languages` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `fk_user_id` int(10) unsigned NOT NULL,
  `language` varchar(45) NOT NULL,
  `level` int(10) unsigned NOT NULL COMMENT 'Level goes from 1 to 6. 7 used for mother tongue',
  `positives_to_next_level` int(10) unsigned NOT NULL,
  `purpose` enum('practice','evaluate') NOT NULL DEFAULT 'practice',
  PRIMARY KEY (`id`),
  KEY `fk_user_id` (`fk_user_id`),
  CONSTRAINT `fk_user_id` FOREIGN KEY (`fk_user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_session`
--

DROP TABLE IF EXISTS `user_session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_session` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `session_id` varchar(100) NOT NULL COMMENT 'Value generated by PHPs builtin function',
  `session_date` datetime NOT NULL,
  `duration` int(10) NOT NULL,
  `keep_alive` tinyint(1) NOT NULL,
  `fk_user_id` int(10) unsigned NOT NULL,
  `closed` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `FK_user_session_1` (`fk_user_id`),
  CONSTRAINT `FK_user_session_1` FOREIGN KEY (`fk_user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_videohistory`
--

DROP TABLE IF EXISTS `user_videohistory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_videohistory` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `fk_user_id` int(10) unsigned NOT NULL,
  `fk_user_session_id` int(10) unsigned NOT NULL,
  `fk_exercise_id` int(10) unsigned NOT NULL,
  `response_attempt` tinyint(1) NOT NULL DEFAULT '0',
  `fk_response_id` int(10) unsigned DEFAULT NULL,
  `incidence_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `subtitles_are_used` tinyint(1) NOT NULL DEFAULT '0',
  `fk_subtitle_id` int(10) unsigned DEFAULT NULL,
  `response_role` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_user_videohistory_1` (`fk_user_id`),
  KEY `FK_user_videohistory_2` (`fk_user_session_id`),
  KEY `FK_user_videohistory_3` (`fk_exercise_id`),
  KEY `FK_user_videohistory_4` (`fk_response_id`),
  KEY `FK_user_videohistory_5` (`fk_subtitle_id`),
  CONSTRAINT `FK_user_videohistory_1` FOREIGN KEY (`fk_user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_user_videohistory_2` FOREIGN KEY (`fk_user_session_id`) REFERENCES `user_session` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_user_videohistory_3` FOREIGN KEY (`fk_exercise_id`) REFERENCES `exercise` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_user_videohistory_4` FOREIGN KEY (`fk_response_id`) REFERENCES `response` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_user_videohistory_5` FOREIGN KEY (`fk_subtitle_id`) REFERENCES `subtitle` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
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

