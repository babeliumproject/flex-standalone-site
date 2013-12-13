--
-- Table structure for table `teamMembers`
--

DROP TABLE IF EXISTS `teamMembers`;
CREATE TABLE `teamMembers` (
  `fk_user_id` int(10) unsigned NOT NULL,
  `fk_team_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`fk_user_id`,`fk_team_id`),
  KEY `fk_teamMembers_1_idx` (`fk_user_id`),
  KEY `fk_teamMembers_2_idx` (`fk_team_id`),
  CONSTRAINT `fk_teamMembers_1` FOREIGN KEY (`fk_user_id`) REFERENCES `users` (`ID`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_teamMembers_2` FOREIGN KEY (`fk_team_id`) REFERENCES `teams` (`ID`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `enrolment`
--

DROP TABLE IF EXISTS `enrolment`;
CREATE TABLE `enrolment` (
  `fk_group_id` int(11) NOT NULL,
  `fk_user_id` int(10) NOT NULL,
  `role` enum('student','teacher') DEFAULT 'student',
  PRIMARY KEY (`fk_group_id`,`fk_user_id`),
  KEY `fk_enrolment_1_idx` (`fk_group_id`),
  CONSTRAINT `fk_group_enrol` FOREIGN KEY (`fk_group_id`) REFERENCES `groups` (`ID`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `files`
--

DROP TABLE IF EXISTS `files`;
CREATE TABLE `files` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(250) NOT NULL,
  `mtime` varchar(45) DEFAULT NULL,
  `size` float(7,3) DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=208722 DEFAULT CHARSET=utf8;

--
-- Table structure for table `groups`
--

DROP TABLE IF EXISTS `groups`;
CREATE TABLE `groups` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(150) NOT NULL,
  `description` tinytext,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

--
-- Table structure for table `teams`
--

DROP TABLE IF EXISTS `teams`;
CREATE TABLE `teams` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `description` varchar(250) DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=87 DEFAULT CHARSET=utf8;
