--
-- ============== refactorization_schema.sql ==============
-- $Revision$

-- phpMyAdmin SQL Dump
-- version 3.1.3
-- http://www.phpmyadmin.net
--
-- Servidor: localhost
-- Tiempo de generación: 30-09-2009 a las 16:11:43
-- Versión del servidor: 5.0.67
-- Versión de PHP: 5.2.6-2ubuntu4.3

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

SET FOREIGN_KEY_CHECKS = 0;

--
-- Base de datos: `mydb`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `credithistory`
--

CREATE TABLE IF NOT EXISTS `credithistory` (
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
  KEY `FK_credithistory_2` (`fk_exercise_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `evaluation`
--

CREATE TABLE IF NOT EXISTS `evaluation` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `fk_response_id` int(10) unsigned NOT NULL,
  `fk_user_id` int(10) unsigned NOT NULL,
  `score` int(5) default NULL,
  `comment` text,
  `adding_date` date default NULL,
  PRIMARY KEY  (`id`),
  KEY `FK_evaluation_1` (`fk_response_id`),
  KEY `FK_evaluation_2` (`fk_user_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `evaluation_video`
--

CREATE TABLE IF NOT EXISTS `evaluation_video` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `fk_evaluation_id` int(10) unsigned NOT NULL,
  `video_identifier` varchar(100) NOT NULL,
  `source` enum('Youtube','Red5') NOT NULL,
  `thumbnail_uri` varchar(200) NOT NULL,
  `duration` int(10) unsigned NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `FK_evaluation_video_1` (`fk_evaluation_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `exercise`
--

CREATE TABLE IF NOT EXISTS `exercise` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(80) NOT NULL COMMENT 'In case it''s Youtube video we''ll store here it''s uid',
  `description` text NOT NULL COMMENT 'Describe the video''s content',
  `source` enum('Youtube','Red5') NOT NULL COMMENT 'Specifies where the video comes from',
  `language` varchar(45) NOT NULL COMMENT 'The spoken language of this exercise',
  `fk_user_id` int(10) unsigned NOT NULL COMMENT 'Who suggested or uploaded this video',
  `tags` varchar(100) NOT NULL COMMENT 'Tag list each item separated with a comma',
  `title` varchar(80) NOT NULL,
  `thumbnail_uri` varchar(200) NOT NULL DEFAULT 'nothumb.png',
  `adding_date` datetime NOT NULL,
  `duration` int(10) unsigned NOT NULL,
  `status` enum('Unprocessed','Processing','Available','Rejected','Error','Unavailable') NOT NULL DEFAULT 'Unprocessed',
  `filehash` varchar(32) NOT NULL DEFAULT 'none',
  PRIMARY KEY  (`id`),
  KEY `FK_exercises_1` (`fk_user_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `exercise_comment`
--

CREATE TABLE IF NOT EXISTS `exercise_comment` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `fk_exercise_id` int(10) unsigned NOT NULL,
  `fk_user_id` int(10) unsigned NOT NULL,
  `comment` text NOT NULL,
  `comment_date` datetime NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `FK_exercise_comments_1` (`fk_exercise_id`),
  KEY `FK_exercise_comments_2` (`fk_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `exercise_level`
--

CREATE TABLE IF NOT EXISTS `exercise_level` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `fk_exercise_id` int(10) unsigned NOT NULL,
  `fk_user_id` int(10) unsigned NOT NULL,
  `suggested_level` int(10) unsigned NOT NULL COMMENT 'Level dificulty goes upwards from 1 to 6',
  `suggest_date` datetime NOT NULL,
  PRIMARY KEY  USING BTREE (`id`),
  KEY `FK_exercise_level_1` (`fk_exercise_id`),
  KEY `FK_exercise_level_2` (`fk_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `exercise_role`
--

CREATE TABLE IF NOT EXISTS `exercise_role` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `fk_exercise_id` int(10) unsigned NOT NULL,
  `fk_user_id` int(10) unsigned NOT NULL,
  `character_name` varchar(45) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `FK_exercise_characters_1` (`fk_exercise_id`),
  KEY `FK_exercise_characters_2` (`fk_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `exercise_score`
--

CREATE TABLE IF NOT EXISTS `exercise_score` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `fk_exercise_id` int(10) unsigned NOT NULL,
  `fk_user_id` int(10) unsigned NOT NULL,
  `suggested_score` int(10) unsigned NOT NULL COMMENT 'Score will be a value between 1 and 5',
  `suggestion_date` datetime NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `FK_exercise_score_1` (`fk_exercise_id`),
  KEY `FK_exercise_score_2` (`fk_user_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

-- --------------------------------------------------------


--
-- Estructura de tabla para la tabla `preferences`
--

CREATE TABLE IF NOT EXISTS `preferences` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `prefName` varchar(45) NOT NULL,
  `prefValue` varchar(200) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `response`
--

CREATE TABLE IF NOT EXISTS `response` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `fk_user_id` int(10) unsigned NOT NULL,
  `fk_exercise_id` int(10) unsigned NOT NULL,
  `file_identifier` varchar(100) NOT NULL,
  `is_private` tinyint(1) NOT NULL,
  `thumbnail_uri` varchar(200) NOT NULL,
  `source` enum('Youtube','Red5') NOT NULL,
  `duration` int(10) unsigned NOT NULL,
  `adding_date` datetime NOT NULL,
  `rating_amount` int(10) NOT NULL,
  `character_name` varchar(45) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `FK_response_1` (`fk_user_id`),
  KEY `FK_response_2` (`fk_exercise_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `subtitle`
--

CREATE TABLE IF NOT EXISTS `subtitle` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `fk_exercise_id` int(10) unsigned NOT NULL,
  `fk_user_id` int(10) unsigned NOT NULL,
  `language` varchar(45) NOT NULL,
  `translation` tinyint(1) NOT NULL,
  `adding_date` datetime NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `FK_exercise_subtitle_1` (`fk_exercise_id`),
  KEY `FK_exercise_subtitle_2` (`fk_user_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `subtitle_line`
--

CREATE TABLE IF NOT EXISTS `subtitle_line` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `fk_subtitle_id` int(10) unsigned NOT NULL,
  `show_time` float(10) unsigned NOT NULL,
  `hide_time` float(10) unsigned NOT NULL,
  `text` varchar(80) NOT NULL,
  `fk_exercise_role_id` int(10) unsigned NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `FK_subtitle_line_1` (`fk_subtitle_id`),
  KEY `FK_subtitle_line_2` (`fk_exercise_role_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `subtitle_score`
--

CREATE TABLE IF NOT EXISTS `subtitle_score` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `fk_subtitle_id` int(10) unsigned NOT NULL,
  `fk_user_id` int(10) unsigned NOT NULL,
  `suggested_score` int(10) unsigned NOT NULL,
  `suggestion_date` datetime NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `FK_subtitle_score_1` (`fk_subtitle_id`),
  KEY `FK_subtitle_score_2` (`fk_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `users`
--

CREATE TABLE IF NOT EXISTS `users` (
  `ID` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(45) NOT NULL,
  `password` varchar(45) NOT NULL,
  `email` varchar(45) NOT NULL,
  `realName` varchar(45) NOT NULL,
  `realSurname` varchar(45) NOT NULL,
  `creditCount` int(10) unsigned NOT NULL default '0',
  `joiningDate` timestamp NOT NULL default CURRENT_TIMESTAMP,
  PRIMARY KEY  (`ID`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `user_languages`
--

CREATE TABLE IF NOT EXISTS `user_languages` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `fk_user_id` int(10) unsigned NOT NULL,
  `language` varchar(45) NOT NULL,
  `level` int(10) unsigned NOT NULL COMMENT 'Level goes from 1 to 6. 7 used for mother tongue',
  `positives_to_next_level` int(10) unsigned NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------


--
-- Filtros para las tablas descargadas (dump)
--

--
-- Filtros para la tabla `credithistory`
--
ALTER TABLE `credithistory`
  ADD CONSTRAINT `FK_credithistory_1` FOREIGN KEY (`fk_user_id`) REFERENCES `users` (`ID`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `FK_credithistory_2` FOREIGN KEY (`fk_exercise_id`) REFERENCES `exercise` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `FK_credithistory_3` FOREIGN KEY (`fk_response_id`) REFERENCES `response` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `evaluation`
--
ALTER TABLE `evaluation`
  ADD CONSTRAINT `FK_evaluation_1` FOREIGN KEY (`fk_response_id`) REFERENCES `response` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `FK_evaluation_2` FOREIGN KEY (`fk_user_id`) REFERENCES `users` (`ID`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `evaluation_video`
--
ALTER TABLE `evaluation_video`
  ADD CONSTRAINT `FK_evaluation_video_1` FOREIGN KEY (`fk_evaluation_id`) REFERENCES `evaluation` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `exercise`
--
ALTER TABLE `exercise`
  ADD CONSTRAINT `FK_exercises_1` FOREIGN KEY (`fk_user_id`) REFERENCES `users` (`ID`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `exercise_comment`
--
ALTER TABLE `exercise_comment`
  ADD CONSTRAINT `FK_exercise_comments_1` FOREIGN KEY (`fk_exercise_id`) REFERENCES `exercise` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `FK_exercise_comments_2` FOREIGN KEY (`fk_user_id`) REFERENCES `users` (`ID`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `exercise_level`
--
ALTER TABLE `exercise_level`
  ADD CONSTRAINT `FK_exercise_level_1` FOREIGN KEY (`fk_exercise_id`) REFERENCES `exercise` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `FK_exercise_level_2` FOREIGN KEY (`fk_user_id`) REFERENCES `users` (`ID`);

--
-- Filtros para la tabla `exercise_role`
--
ALTER TABLE `exercise_role`
  ADD CONSTRAINT `FK_exercise_characters_1` FOREIGN KEY (`fk_exercise_id`) REFERENCES `exercise` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `FK_exercise_characters_2` FOREIGN KEY (`fk_user_id`) REFERENCES `users` (`ID`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `exercise_score`
--
ALTER TABLE `exercise_score`
  ADD CONSTRAINT `FK_exercise_score_1` FOREIGN KEY (`fk_exercise_id`) REFERENCES `exercise` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `FK_exercise_score_2` FOREIGN KEY (`fk_user_id`) REFERENCES `users` (`ID`);

--
-- Filtros para la tabla `response`
--
ALTER TABLE `response`
  ADD CONSTRAINT `FK_response_1` FOREIGN KEY (`fk_user_id`) REFERENCES `users` (`ID`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `FK_response_2` FOREIGN KEY (`fk_exercise_id`) REFERENCES `exercise` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `subtitle`
--
ALTER TABLE `subtitle`
  ADD CONSTRAINT `FK_exercise_subtitle_1` FOREIGN KEY (`fk_exercise_id`) REFERENCES `exercise` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `FK_exercise_subtitle_2` FOREIGN KEY (`fk_user_id`) REFERENCES `users` (`ID`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `subtitle_line`
--
ALTER TABLE `subtitle_line`
  ADD CONSTRAINT `FK_subtitle_line_1` FOREIGN KEY (`fk_subtitle_id`) REFERENCES `subtitle` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `FK_subtitle_line_2` FOREIGN KEY (`fk_exercise_role_id`) REFERENCES `exercise_role` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `subtitle_score`
--
ALTER TABLE `subtitle_score`
  ADD CONSTRAINT `FK_subtitle_score_1` FOREIGN KEY (`fk_subtitle_id`) REFERENCES `subtitle` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `FK_subtitle_score_2` FOREIGN KEY (`fk_user_id`) REFERENCES `users` (`ID`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- ============== refactorization_data.sql ==============
--


--
-- Base de datos: `mydb`
--

--
-- Volcar la base de datos para la tabla `credithistory`
--

INSERT INTO `credithistory` (`id`, `fk_user_id`, `fk_exercise_id`, `fk_response_id`, `fk_eval_id`, `changeDate`, `changeType`, `changeAmount`) VALUES
(1, 2, 2, NULL, 0, '2009-08-07 13:43:48', 'subtitling', 2),
(2, 1, 2, NULL, 0, '2009-08-07 13:54:11', 'subtitling', 2),
(3, 1, 2, 22, 0, '2009-08-07 14:01:35', 'eval_request', -2),
(4, 1, 2, 23, 0, '2009-08-07 14:06:28', 'eval_request', -2),
(5, 1, 2, 24, 0, '2009-08-08 19:10:34', 'eval_request', -2),
(6, 1, 2, 26, 0, '2009-08-15 00:58:09', 'eval_request', -2),
(7, 2, 2, 29, 0, '2009-08-20 01:21:27', 'eval_request', -2),
(8, 5, 2, 30, 0, '2009-08-20 01:53:46', 'eval_request', -2),
(9, 3, 2, 31, 0, '2009-08-20 01:54:49', 'eval_request', -2),
(10, 3, 2, 32, 0, '2009-08-20 01:59:47', 'eval_request', -2),
(11, 3, 2, 42, 0, '2009-08-23 16:57:46', 'eval_request', -2),
(12, 3, 2, 43, 0, '2009-08-21 12:03:31', 'eval_request', -2),
(13, 1, 2, 44, 0, '2009-08-26 18:07:56', 'eval_request', -2),
(14, 2, 2, 45, 0, '2009-08-30 18:32:39', 'eval_request', -2),
(15, 1, 2, 46, 0, '2009-09-01 00:45:34', 'eval_request', -2);

--
-- Volcar la base de datos para la tabla `evaluation`
--

--
-- Volcar la base de datos para la tabla `evaluation_video`
--

--
-- Volcar la base de datos para la tabla `exercise`
--

INSERT INTO `exercise` (`id`, `name`, `description`, `source`, `language`, `fk_user_id`, `tags`, `title`, `thumbnail_uri`, `adding_date`, `duration`, `status`, `filehash`) VALUES
(1, 'kutsidazu_zatia', 'Kutsidazu bidea ixabel filmeko zatia', 'Red5', 'Basque', 1, 'euskaltegia, berri', 'Kutsidazu bidea ixabel', 'kutsidazu_zatia.jpg', '2009-09-01 00:24:04', 129.64, 'Unavailable', '6990471c4ac782c4329a662b061e17e2'),
(2, 'serie_cuatro', 'Escena de serie', 'Red5', 'Spanish', 1, 'cuatro, serie', 'Extracto serie', 'serie_cuatro.jpg', '2009-09-01 00:24:04', 9.8, 'Unavailable', '9d9bd82503637191e53ef955f9ea0ea4'),
(3, 'mafiosos_conv', 'Conversación entre mafiosos', 'Red5', 'Spanish', 1, 'serie, mafiosos', 'Conversación mafiosos', 'mafiosos_conv.jpg', '2010-02-02 00:23:33', 38.48, 'Unavailable', 'bc1f4ee5459657d761e70582d6c12bfc'),
(4, 'pokemon_zatia', 'Pokemon marrazki bizidunen zatia', 'Red5', 'Basque', 1, 'pokemon, zatia', 'Pokemon zatia', 'pokemon_zatia.jpg', '2010-02-02 01:23:34', 84.28, 'Unavailable', '00c843cdaccae236dc4e33f6bf9423c6'),
(5, 'tdes_1065_qa', 'Repeat phrases and then talk to Sarah', 'Red5', 'English', 1, 'daily, english, show', 'The Daily English Show #1065 Fragment', 'tdes_1065_qa.jpg', '2010-03-08 12:10:00', 43.09, 'Available', '161abc5e831c545305f55f4139fd4799'),
(6, 'tdes_1170_qa', 'Repeat phrases and then talk to Sarah', 'Red5', 'English', 1, 'daily, english, show', 'The Daily English Show #1170 Fragment', 'tdes_1170_qa.jpg', '2010-03-08 12:10:00', 51.97, 'Available', '38b99457f8cd8af5b56728c5e2f0485b'),
(7, 'tdes_1179_qa', 'Repeat phrases and then talk to Sarah', 'Red5', 'English', 1, 'daily, english, show', 'The Daily English Show #1179 Fragment', 'tdes_1179_qa.jpg', '2010-03-08 12:10:00', 29.73, 'Available', '4fe59e622c208b53dc4e61cfdcb7b2a8'),
(8, 'tdes_1183_qa', 'Repeat phrases and then talk to Sarah', 'Red5', 'English', 1, 'daily, english, show', 'The Daily English Show #1183 Fragment', 'tdes_1183_qa.jpg', '2010-03-08 12:10:00', 40.12, 'Available', '2f8d1bde45ae7a7d303d663bcdf2ae8c'),
(9, 'tdes_1187_qa', 'Repeat phrases and then talk to Sarah', 'Red5', 'English', 1, 'daily, english, show', 'The Daily English Show #1187 Fragment', 'tdes_1187_qa.jpg', '2010-03-08 12:10:00', 57.15, 'Available', 'a0cd07a3ac94d2dbf77ca1c02c6278cc'),
(12, '4BU3y3nkB7c', 'Presentation', 'Red5', 'French', 1, 'french, talk', 'Presentation', '4BU3y3nkB7c.jpg', '2010-04-15 13:17:08', 31, 'Available', 'e52964a1d207b5014b778ceb1016da8b'),
(13, '08s08c4o3El', 'Goenkale telesaileko zati bat', 'Red5', 'Basque', 1, 'euskara, goenkale', 'Goenkale Zatia I', '08s08c4o3El.jpg', '2010-04-15 13:18:14', 38, 'Available', 'f03a80496520e2d275cef027b69aa379'),
(14, 'iQ8pI4bFwQh', 'Goenkale telesaileko zatia', 'Red5', 'Basque', 1, 'euskara, goenkale', 'Goenkale Zatia II', 'iQ8pI4bFwQh.jpg', '2010-04-15 13:19:33', 110, 'Available', '632fbbf33993892b9794f1cc324cd8d1'),
(15, 'COSYB49sT1G', 'Frases sencillas de la vida cotidiana', 'Red5', 'Spanish', 1, 'frases, cotidianas', 'EspaÃ±ol Latino Para NiÃ±os', 'COSYB49sT1G.jpg', '2010-04-15 13:21:45', 63, 'Available', '4878a56679f48167686adc80e267506f');



--
-- Volcar la base de datos para la tabla `exercise_comment`
--


--
-- Volcar la base de datos para la tabla `exercise_level`
--


--
-- Volcar la base de datos para la tabla `exercise_role`
--
INSERT INTO `exercise_role` (`id`, `fk_exercise_id`, `fk_user_id`, `character_name`) VALUES
(1, 2, 1, 'Capataz'),
(2, 2, 1, 'Joven'),
(3, 2, 1, 'Tipo zaharra'),
(4, 2, 1, 'Tipo gaztea'),
(5, 2, 1, 'Old guy'),
(6, 2, 1, 'Young guy'),
(7, 1, 1, 'Koro'),
(8, 1, 1, 'Joxe Mari'),
(9, 5, 1, 'NPC'),
(10, 5, 1, 'Yourself'),
(11, 6, 1, 'NPC'),
(12, 6, 1, 'Yourself'),
(13, 7, 1, 'NPC'),
(14, 7, 1, 'Yourself'),
(15, 8, 1, 'NPC'),
(16, 8, 1, 'Yourself'),
(17, 9, 1, 'NPC'),
(18, 9, 1, 'Yourself');


--
-- Volcar la base de datos para la tabla `exercise_score`
--

INSERT INTO `exercise_score` (`id`, `fk_exercise_id`, `fk_user_id`, `suggested_score`, `suggestion_date`) VALUES
(1, 1, 1, 3, '2009-09-03 02:41:43'),
(2, 1, 1, 2, '2009-09-03 02:41:43'),
(3, 1, 2, 4, '2009-09-03 02:41:43'),
(4, 1, 3, 1, '2009-09-03 02:41:43');


--
-- Volcar la base de datos para la tabla `grabaciones`
--


--
-- Volcar la base de datos para la tabla `preferences`
--

INSERT INTO `preferences` (`prefName`, `prefValue`) VALUES
('initialCredits', 15),
('subtitleAdditionCredits', 2),
('evaluationRequestCredits', 2),
('evaluatedWithVideoCredits', 2),
('videoSuggestCredits', 2),
('dailyLoginCredits', 0.5),
('evaluatedWithCommentCredits', 1.5),
('evaluatedWithScoreCredits', 0.5),
('subtitleTranslationCredits', 1.5),
('uploadExerciseCredits', 2),
('dbrevision', '$Revision$'),
('appRevision', 0),
('trial.threshold', 10);

--
-- Volcar la base de datos para la tabla `response`
--

--
-- Volcar la base de datos para la tabla `subtitle`
--

INSERT INTO `subtitle` (`id`, `fk_exercise_id`, `fk_user_id`, `language`, `translation`, `adding_date`) VALUES
(1, 2, 2, 'Spanish', 0, '2009-09-10 13:52:37'),
(2, 2, 1, 'Basque', 1, '2009-09-10 13:52:37'),
(3, 2, 3, 'English', 1, '2009-09-10 13:52:37'),
(4, 1, 1, 'Basque', 0, '2010-03-01 10:59:20'),
(5, 5, 1, 'English', 0, NOW()),
(6, 6, 1, 'English', 0, NOW()),
(7, 7, 1, 'English', 0, NOW()),
(8, 8, 1, 'English', 0, NOW()),
(9, 9, 1, 'English', 0, NOW());

--
-- Volcar la base de datos para la tabla `subtitle_line`
--

INSERT INTO `subtitle_line` (`fk_subtitle_id`, `show_time`, `hide_time`, `text`, `fk_exercise_role_id`) VALUES
(1, 1.6, 3.76, '¿Por qué quiere un boxeador trabajar en la construcción?', 1),
(1, 4.96, 6.76, 'Está arruinado, y no tiene trabajo y...', 2),
(1, 6.92, 8, 'y quiere que le contrate...', 1),
(1, 8.1, 9.4, 'Yo podría enseñarle a manejar la excavadora.', 2),

(2, 1.6, 3.76, 'Zergatik nahi du boxeolari batek eraikuntzan lan egin?', 3),
(2, 4.96, 6.76, 'Dirurik ez du, eta ez lanik ere...', 4),
(2, 6.92, 8, 'eta nik kontratatzea nahi duzu...', 3),
(2, 8.1, 9.4, 'Nik erakutsi niezaioke eskabadora erabiltzen.', 4),

(3, 1.6, 3.76, 'Why a boxer wants to work in construction?', 5),
(3, 4.96, 6.76, 'He is ruined, and doesn''t have a job', 6),
(3, 6.92, 8, 'and you want me to hire him...', 5),
(3, 8.1, 9.4, 'I could teach him to handle the excavator.', 6),

(4, 5.8, 7.48, 'Esan zertan ari zareten. Ikasten...', 7),
(4, 7.79, 11.2, 'edo lanean, edo alferkeri goxo-goxoan... e?', 7),
(4, 11.34, 15.04, 'eta zergaitik etorri zareten udako eskola honetara.', 7),
(4, 18.96, 22.32, 'Ni? bueno ni Joxemari naiz. Haragizko... ez, haragijale', 8),

(5, 0.300, 1.204, 'What''s that?',9),
(5, 1.404, 2.904, 'What''s that?',10),
(5, 3.104, 5.215, 'Can''t you just use your sleeve?',9),
(5, 5.415, 8.204, 'Can''t you just use your sleeve?',10),
(5, 8.404, 9.226, 'Who gave it to you?',9),
(5, 9.426, 11.504, 'Who gave it to you?',10),
(5, 11.704, 14.307, 'Look I got a present',9),
(5, 14.507, 15.604, 'What''s that?',10),
(5, 15.804, 18.519, 'It''s a Key-tay kabino',9),
(5, 18.719, 19.600, 'What''s that?',10),
(5, 19.800, 28.513, 'Well, Keytime is so fun and this has material on the back of it and it''s for cleaning your cellphone''s screen',9),
(5, 28.713, 30.900, 'Can''t you just use your sleeve?',10),
(5, 31.100, 32.825, 'Well... yeah, but...',9),
(5, 33.025, 34.300, 'Who gave it to you?',10),
(5, 34.500, 43.000, 'Am Anichke. They made a new website, and they used a few seconds of one of my videos, so they sent me this.',9),

(6, 0.300, 2.307, 'Oh, it''s going that well, huh?',11),
(6, 2.507, 4.900, 'Oh, it''s going that well, huh?',12),
(6, 5.100, 8.023, 'When do I get to meet the phantom physician?',11),
(6, 8.223, 10.700, 'When do I get to meet the phantom physician?',12),
(6, 10.900, 12.205, 'You guys got plans tonight?',11),
(6, 12.405, 13.900, 'You guys got plans tonight?',12),
(6, 14.100, 15.410, 'You know what you should do?',11),
(6, 15.610, 17.000, 'You know what you should do?',12),
(6, 17.200, 19.321, 'You should fly up and surprise him.',11),
(6, 19.521, 21.900, 'You should fly up and surprise him.',12),
(6, 22.100, 23.232, 'Yeah, why not?',11),
(6, 23.432, 25.000, 'Yeah, why not?',12),
(6, 25.200, 26.716, 'He''s just the first decent guy I dated in a long time.',11),
(6, 26.916, 31.200, 'Oh, it''s going that well, huh?',12),
(6, 31.400, 34.831, 'I''m so sick of dating. I''m so jealous of you guys.',11),
(6, 35.031, 37.600, 'When do I get to meet the phantom physician?',12),
(6, 37.800, 38.608, 'I think soon.',11),
(6, 38.808, 40.700, 'You guys got plans tonight?',12),
(6, 40.900, 45.828, 'No, nothing. Just... he has to go to San Francisco so we''re gonna talk on the phone.',11),
(6, 46.028, 49.900, 'You know what you should do? You should fly up and surprise him.',12),
(6, 50.100, 50.808, 'You think so?',11),
(6, 51.008, 52.400, 'Yeah, why not?',12),

(7, 0.300, 1.605, 'OK, now what?',13),
(7, 1.805, 3.100, 'OK, now what?',14),
(7, 3.300, 5.917, 'OK, that''s fair. On three?',13),
(7, 6.117, 7.600, 'OK, that''s fair. On three?',14),
(7, 7.800, 10.129, 'One, two, three.',13),
(7, 10.329, 12.100, 'One, two, three.',14),
(7, 12.300, 13.505, 'I threw paper!',13),
(7, 13.705, 15.100, 'I threw paper!',14),
(7, 17.114, 17.700, 'OK, now what?',14),
(7, 17.900, 19.722, 'Rock-paper-scissors for it',13),
(7, 19.922, 21.600, 'OK, that''s fair. On three?',14),
(7, 21.800, 23.031, 'Yeah.',13),
(7, 23.231, 27.510, 'One, two, three.',14),
(7, 27.710, 28.700, 'I threw paper!',14),
(7, 28.900, 29.300, 'I threw a rock!',13),

(8, 0.300, 1.806, 'How was your day?',15),
(8, 2.006, 3.100, 'How was your day?',16),
(8, 3.300, 4.012, 'What about?',15),
(8, 4.212, 5.300, 'What about?',16),
(8, 5.500, 6.920, 'What''s gonna happen to it?',15),
(8, 7.120, 9.000, 'What''s gonna happen to it?',16),
(8, 9.200, 10.831, 'So they''re gonna get rid of it?',15),
(8, 11.031, 13.700, 'So they''re gonna get rid of it?',16),
(8, 14.507, 16.100, 'How was your day?',16),
(8, 16.300, 19.923, 'Good! I went to a protest this afternoon',15),
(8, 20.123, 21.200, 'What about?',16),
(8, 21.400, 26.106, 'It was about protecting national public service radio broadcasting',15),
(8, 26.306, 27.900, 'What''s gonna happen to it?',16),
(8, 28.100, 31.923, 'Well... the government wants to save money...',15),
(8, 32.123, 33.300, 'So they''re gonna get rid of it?',16),
(8, 33.500, 39.800, 'Not quite, but they suggested stuff like introducing advertising, which would really suck.',15),

(9, 0.300, 2.006, 'What are you up to this weekend?',17),
(9, 2.206, 3.600, 'What are you up to this weekend?',18),
(9, 3.800, 4.613, 'Where''s that?',17),
(9, 4.813, 5.800, 'Where''s that?',18),
(9, 6.000, 8.123, 'Oh yeah, I know where the Albert Park is.',17),
(9, 8.323, 10.800, 'Oh yeah, I know where the Albert Park is.',18),
(9, 11.000, 13.906, 'That''s were the lantern festival was last week.',17),
(9, 14.106, 17.400, 'That''s were the lantern festival was last week.',18),
(9, 17.600, 19.120, 'Yeah, did you?',17),
(9, 19.320, 20.800, 'Yeah, did you?',18),
(9, 21.000, 23.700, 'Yeah. What day did you go?',17),
(9, 23.900, 26.500, 'Yeah. What day did you go?',18),
(9, 27.309, 29.100, 'What are you up to this weekend?',18),
(9, 29.300, 34.229, 'Ah, I''m not sure yet. I might go and check out the concert on sunday.',17),
(9, 34.429, 35.500, 'Where''s that?',18),
(9, 35.700, 39.611, 'It''s in Albert Park which is the park near the university.',17),
(9, 39.811, 45.200, 'Oh yeah, I know where the Albert Park is. That''s were the lantern festival was last week.',18),
(9, 45.400, 48.201, 'Yeah that''s the one. Did you go to that festival?',17),
(9, 48.401, 49.600, 'Yeah, did you?',18),
(9, 49.800, 52.012, 'Yeah, it was awesome, wasn''t it?',17),
(9, 52.212, 53.800, 'Yeah. What day did you go?',18),
(9, 54.000, 57.100, 'Am, Sunday I think it was. Yeah, yeah, Sunday night.',17);


--
-- Volcar la base de datos para la tabla `subtitle_score`
--


--
-- Volcar la base de datos para la tabla `users`
--

INSERT INTO `users` (`ID`, `name`, `password`, `email`, `realName`, `realSurname`, `creditCount`, `joiningDate`) VALUES
(1, 'erab1', '4eff1c28f92bb604596e75d2c98bf7085ac685c4', 'erab1@gmail.com', 'erab1', 'erab1', 13, '2009-07-02 12:30:00'),
(2, 'erab2', '4eff1c28f92bb604596e75d2c98bf7085ac685c4', 'erab2@gmail.com', 'erab2', 'erab2', 9, '2009-07-02 12:30:00'),
(3, 'erab3', '4eff1c28f92bb604596e75d2c98bf7085ac685c4', 'erab3@gmail.com', 'erab3', 'erab3', 5, '2009-07-02 12:30:00'),
(5, 'erab4', '4eff1c28f92bb604596e75d2c98bf7085ac685c4', 'erab4@gmail.com', 'erab4', 'erab4', 5, '2009-07-02 12:30:00');

--
-- Volcar la base de datos para la tabla `user_languages`
--

--
-- ============== register_module_schema.sql ==============
--


ALTER TABLE `users` ADD `active` TINYINT( 1 ) NOT NULL DEFAULT '0';
ALTER TABLE `users` ADD `activation_hash` VARCHAR( 20 ) NOT NULL;
INSERT INTO preferences (prefName, prefValue) VALUES ('hashLength', 20), ('hashChars', 'abcdefghijklmnopqrstuvwxyz0123456789-_');


--
-- ============== autoevaluation_db_min_commands.sql ==============
--

--
-- Estructura de tabla para la tabla `transcription`
-- 

CREATE TABLE `transcription` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `adding_date` datetime NOT NULL,
  `status` varchar(45) NOT NULL,
  `transcription` text,
  `transcription_date` datetime DEFAULT NULL,
  `system` varchar(45) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1;


-- 
-- Estructura de tabla para la tabla `spinvox_request`
-- 
CREATE TABLE `spinvox_request` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `x_error` varchar(45) NOT NULL,
  `url` varchar(200) DEFAULT NULL,
  `date` datetime NOT NULL,
  `fk_transcription_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_spinvox_requests_transcription1` (`fk_transcription_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Filtros para la tabla `spinvox_request`
--
ALTER TABLE `spinvox_request`
  ADD CONSTRAINT `fk_spinvox_requests_transcription1` FOREIGN KEY (`fk_transcription_id`) REFERENCES `transcription` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `exercise`
--
ALTER TABLE `exercise` ADD COLUMN `fk_transcription_id` INT(10) UNSIGNED DEFAULT null AFTER `filehash`,
 ADD CONSTRAINT `fk_exercise_transcriptions1` FOREIGN KEY `fk_exercise_transcriptions1` (`fk_transcription_id`)
    REFERENCES `transcription` (`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT;

--
-- Filtros para la tabla `response`
--
ALTER TABLE `response` ADD COLUMN `fk_transcription_id` INTEGER(10) UNSIGNED DEFAULT null AFTER `character_name`,
 ADD CONSTRAINT `fk_response_transcriptions1` FOREIGN KEY `fk_response_transcriptions1` (`fk_transcription_id`)
    REFERENCES `transcription` (`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT;


--
-- ============== autoevaluation_data.sql ==============
--

--
-- Volcar la base de datos para la tabla `transcription`
--

INSERT INTO `transcription` VALUES (1, '2009-10-20 16:24:59', 'pending', NULL, NULL, 'spinvox');
INSERT INTO `transcription` VALUES (2, '2009-10-20 16:24:59', 'pending', NULL, NULL, 'spinvox');


--
-- Volcar la base de datos para la tabla `exercise`
--

INSERT INTO `exercise` VALUES (10, 'english_long', 'english lessons', 'Red5', 'English', 1, 'english', 'English lessons', 'english_long.jpg', '2009-10-22 18:00:00', 59, 'Unavailable', 'e1fdbb47ead995d5973a30d466e7533d', NULL);
INSERT INTO `exercise` VALUES (11, 'english', 'english lessons', 'Red5', 'English', 1, 'english', 'English lessons short', 'english.jpg', '2009-10-22 18:00:00', 12, 'Unavailable', 'fc1b11475ce5233acf10bfb39925cacc', 1);


--
-- Volcar la base de datos para la tabla `response`
--


--
-- Volcar la base de datos para la tabla `evaluation`
--




--
-- ============== autoevaluation_preferences.sql ==============
--
INSERT INTO `preferences` VALUES (null, 'ffmpeg.path', '/usr/bin/ffmpeg');
INSERT INTO `preferences` VALUES (null, 'spinvox.useragent', 'babelia');
INSERT INTO `preferences` VALUES (null, 'spinvox.language', 'English');
INSERT INTO `preferences` VALUES (null, 'spinvox.appname', 'babelia-auto_correction');
INSERT INTO `preferences` VALUES (null, 'spinvox.account_id', '2009-2385-6238-3307');
INSERT INTO `preferences` VALUES (null, 'spinvox.password', 'kviAcV6a');
INSERT INTO `preferences` VALUES (null, 'spinvox.protocol', 'https');
INSERT INTO `preferences` VALUES (null, 'spinvox.username', 'babelia2009');
INSERT INTO `preferences` VALUES (null, 'spinvox.port', '443');
INSERT INTO `preferences` VALUES (null, 'spinvox.dev_url', 'dev.api.spinvox.com');
INSERT INTO `preferences` VALUES (null, 'spinvox.live_url', 'live.api.spinvox.com');
INSERT INTO `preferences` VALUES (null, 'spinvox.max_transcriptions', '10');
INSERT INTO `preferences` VALUES (null, 'spinvox.max_requests', '50');
INSERT INTO `preferences` VALUES (null, 'spinvox.video_path', '/opt/red5/webapps/oflaDemo/streams');
INSERT INTO `preferences` VALUES (null, 'spinvox.temp_folder', '/tmp');
INSERT INTO `preferences` VALUES (null, 'spinvox.max_duration', '30');
INSERT INTO `preferences` VALUES (null, 'spinvox.dev_mode', 'true');
INSERT INTO `preferences` VALUES (null, 'videoCommentPath', '/usr/lib/red5/webapps/oflaDemo/streams/videoComment/');


UPDATE `users` SET `active` = '1' WHERE `users`.`ID` =1 ;
UPDATE `users` SET `active` = '1' WHERE `users`.`ID` =2 ;

SET FOREIGN_KEY_CHECKS = 1;
