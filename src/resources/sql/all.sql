-- $Revision$

-- phpMyAdmin SQL Dump
-- version 3.2.2.1deb1
-- http://www.phpmyadmin.net
--
-- Servidor: localhost
-- Tiempo de generación: 27-04-2010 a las 13:53:31
-- Versión del servidor: 5.1.37
-- Versión de PHP: 5.2.10-2ubuntu6.4

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

--
-- Base de datos: `babeliumproject`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `credithistory`
--

CREATE TABLE IF NOT EXISTS `credithistory` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `fk_user_id` int(10) unsigned NOT NULL,
  `fk_exercise_id` int(10) unsigned NOT NULL,
  `fk_response_id` int(10) unsigned DEFAULT NULL,
  `fk_eval_id` int(10) unsigned DEFAULT NULL,
  `changeDate` datetime NOT NULL,
  `changeType` varchar(45) NOT NULL,
  `changeAmount` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY USING BTREE (`id`),
  KEY `FK_credithistory_1` (`fk_user_id`),
  KEY `FK_credithistory_3` (`fk_response_id`),
  KEY `FK_credithistory_2` (`fk_exercise_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `evaluation`
--

CREATE TABLE IF NOT EXISTS `evaluation` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `fk_response_id` int(10) unsigned NOT NULL,
  `fk_user_id` int(10) unsigned NOT NULL,
  `score` int(5) DEFAULT NULL,
  `comment` text,
  `adding_date` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_evaluation_1` (`fk_response_id`),
  KEY `FK_evaluation_2` (`fk_user_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `evaluation_video`
--

CREATE TABLE IF NOT EXISTS `evaluation_video` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `fk_evaluation_id` int(10) unsigned NOT NULL,
  `video_identifier` varchar(100) NOT NULL,
  `source` enum('Youtube','Red5') NOT NULL,
  `thumbnail_uri` varchar(200) NOT NULL DEFAULT 'nothumb.png',
  `duration` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_evaluation_video_1` (`fk_evaluation_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `exercise`
--

CREATE TABLE IF NOT EXISTS `exercise` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
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
  `fk_transcription_id` int(10) unsigned DEFAULT NULL,
  `license` VARCHAR(60)  NOT NULL DEFAULT 'cc-by' COMMENT 'The kind of license this exercise is attached to',
  `reference` TEXT  NOT NULL COMMENT 'The url or name of the entity that provided this resource (if any)',
  PRIMARY KEY (`id`),
  KEY `FK_exercises_1` (`fk_user_id`),
  KEY `fk_exercise_transcriptions1` (`fk_transcription_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `exercise_comment`
--

CREATE TABLE IF NOT EXISTS `exercise_comment` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `fk_exercise_id` int(10) unsigned NOT NULL,
  `fk_user_id` int(10) unsigned NOT NULL,
  `comment` text NOT NULL,
  `comment_date` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_exercise_comments_1` (`fk_exercise_id`),
  KEY `FK_exercise_comments_2` (`fk_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `exercise_level`
--

CREATE TABLE IF NOT EXISTS `exercise_level` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `fk_exercise_id` int(10) unsigned NOT NULL,
  `fk_user_id` int(10) unsigned NOT NULL,
  `suggested_level` int(10) unsigned NOT NULL COMMENT 'Level dificulty goes upwards from 1 to 6',
  `suggest_date` datetime NOT NULL,
  PRIMARY KEY USING BTREE (`id`),
  KEY `FK_exercise_level_1` (`fk_exercise_id`),
  KEY `FK_exercise_level_2` (`fk_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `exercise_report`
--

CREATE TABLE IF NOT EXISTS `exercise_report` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `fk_exercise_id` int(10) unsigned NOT NULL,
  `fk_user_id` int(10) unsigned NOT NULL,
  `reason` varchar(100) NOT NULL,
  `report_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `FK_exercise_report_1` (`fk_exercise_id`),
  KEY `FK_exercise_report_2` (`fk_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `exercise_role`
--

CREATE TABLE IF NOT EXISTS `exercise_role` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `fk_exercise_id` int(10) unsigned NOT NULL,
  `fk_user_id` int(10) unsigned NOT NULL,
  `character_name` varchar(45) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_exercise_characters_1` (`fk_exercise_id`),
  KEY `FK_exercise_characters_2` (`fk_user_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `exercise_score`
--

CREATE TABLE IF NOT EXISTS `exercise_score` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `fk_exercise_id` int(10) unsigned NOT NULL,
  `fk_user_id` int(10) unsigned NOT NULL,
  `suggested_score` int(10) unsigned NOT NULL COMMENT 'Score will be a value between 1 and 5',
  `suggestion_date` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_exercise_score_1` (`fk_exercise_id`),
  KEY `FK_exercise_score_2` (`fk_user_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `preferences`
--

CREATE TABLE IF NOT EXISTS `preferences` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `prefName` varchar(45) NOT NULL,
  `prefValue` varchar(200) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `response`
--

CREATE TABLE IF NOT EXISTS `response` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `fk_user_id` int(10) unsigned NOT NULL,
  `fk_exercise_id` int(10) unsigned NOT NULL,
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
  PRIMARY KEY (`id`),
  KEY `FK_response_1` (`fk_user_id`),
  KEY `FK_response_2` (`fk_exercise_id`),
  KEY `fk_response_transcriptions1` (`fk_transcription_id`),
  KEY `FK_response_3` (`fk_subtitle_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `spinvox_request`
--

CREATE TABLE IF NOT EXISTS `spinvox_request` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `x_error` varchar(45) NOT NULL,
  `url` varchar(200) DEFAULT NULL,
  `date` datetime NOT NULL,
  `fk_transcription_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_spinvox_requests_transcription1` (`fk_transcription_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `subtitle`
--

CREATE TABLE IF NOT EXISTS `subtitle` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `fk_exercise_id` int(10) unsigned NOT NULL,
  `fk_user_id` int(10) unsigned NOT NULL,
  `language` varchar(45) NOT NULL,
  `translation` tinyint(1) NOT NULL DEFAULT '0',
  `adding_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `FK_exercise_subtitle_1` (`fk_exercise_id`),
  KEY `FK_exercise_subtitle_2` (`fk_user_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `subtitle_line`
--

CREATE TABLE IF NOT EXISTS `subtitle_line` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `fk_subtitle_id` int(10) unsigned NOT NULL,
  `show_time` float unsigned NOT NULL,
  `hide_time` float unsigned NOT NULL,
  `text` varchar(80) NOT NULL,
  `fk_exercise_role_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_subtitle_line_1` (`fk_subtitle_id`),
  KEY `FK_subtitle_line_2` (`fk_exercise_role_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `subtitle_score`
--

CREATE TABLE IF NOT EXISTS `subtitle_score` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `fk_subtitle_id` int(10) unsigned NOT NULL,
  `fk_user_id` int(10) unsigned NOT NULL,
  `suggested_score` int(10) unsigned NOT NULL,
  `suggestion_date` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_subtitle_score_1` (`fk_subtitle_id`),
  KEY `FK_subtitle_score_2` (`fk_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tagcloud`
--

CREATE TABLE IF NOT EXISTS `tagcloud` (
  `tag` varchar(100) NOT NULL,
  `amount` INT(10) UNSIGNED NOT NULL,
  PRIMARY KEY (`tag`)
  )
ENGINE = InnoDB
DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `transcription`
--

CREATE TABLE IF NOT EXISTS `transcription` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `adding_date` datetime NOT NULL,
  `status` varchar(45) NOT NULL,
  `transcription` text,
  `transcription_date` datetime DEFAULT NULL,
  `system` varchar(45) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `users`
--

CREATE TABLE IF NOT EXISTS `users` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  `password` varchar(45) NOT NULL,
  `email` varchar(45) NOT NULL,
  `realName` varchar(45) NOT NULL,
  `realSurname` varchar(45) NOT NULL,
  `creditCount` int(10) unsigned NOT NULL DEFAULT '0',
  `joiningDate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `active` tinyint(1) NOT NULL DEFAULT '0',
  `activation_hash` varchar(20) NOT NULL,
  `isAdmin` TINYINT NOT NULL DEFAULT 0,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `user_languages`
--

CREATE TABLE IF NOT EXISTS `user_languages` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `fk_user_id` int(10) unsigned NOT NULL,
  `language` varchar(45) NOT NULL,
  `level` int(10) unsigned NOT NULL COMMENT 'Level goes from 1 to 6. 7 used for mother tongue',
  `positives_to_next_level` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_user_languages_1` (`fk_user_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `user_session`
--

CREATE TABLE IF NOT EXISTS `user_session` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `session_id` varchar(100) NOT NULL COMMENT 'Value generated by PHPs built-in function',
  `session_date` datetime NOT NULL,
  `duration` int(10) NOT NULL,
  `keep_alive` tinyint(1) NOT NULL,
  `fk_user_id` int(10) unsigned NOT NULL,
  `closed` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `FK_user_session_1` (`fk_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `user_videohistory`
--

CREATE TABLE IF NOT EXISTS `user_videohistory` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `fk_user_id` int(10) unsigned NOT NULL,
  `fk_user_session_id` int(10) unsigned NOT NULL,
  `fk_exercise_id` int(10) unsigned NOT NULL,
  `response_attempt` tinyint(1) NOT NULL DEFAULT '0',
  `fk_response_id` int(10) unsigned DEFAULT NULL,
  `incidence_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `subtitles_are_used` tinyint(1) NOT NULL DEFAULT '0',
  `fk_subtitle_id` int(10) unsigned DEFAULT NULL,
  `fk_exercise_role_id` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_user_videohistory_1` (`fk_user_id`),
  KEY `FK_user_videohistory_2` (`fk_user_session_id`),
  KEY `FK_user_videohistory_3` (`fk_exercise_id`),
  KEY `FK_user_videohistory_4` (`fk_response_id`),
  KEY `FK_user_videohistory_5` (`fk_subtitle_id`),
  KEY `FK_user_videohistory_6` (`fk_exercise_role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


--
-- Datos para las tablas descargadas (dump)
--

--
-- Volcar la base de datos para la tabla `exercise`
--

INSERT INTO `exercise` (`id`, `name`, `description`, `source`, `language`, `fk_user_id`, `tags`, `title`, `thumbnail_uri`, `adding_date`, `duration`, `status`, `filehash`, `fk_transcription_id`, `reference`) VALUES
(1, 'kutsidazu_zatia', 'Kutsidazu bidea ixabel filmeko zatia', 'Red5', 'eu_ES', 1, 'euskaltegia, berri', 'Kutsidazu bidea ixabel', 'kutsidazu_zatia.jpg', '2009-09-01 00:24:04', 130, 'Unavailable', '6990471c4ac782c4329a662b061e17e2', NULL, ''),
(2, 'serie_cuatro', 'Escena de serie', 'Red5', 'es_ES', 1, 'cuatro, serie', 'Extracto serie', 'serie_cuatro.jpg', '2009-09-01 00:24:04', 10, 'Unavailable', '9d9bd82503637191e53ef955f9ea0ea4', NULL, 'www.cuatro.com'),
(3, 'mafiosos_conv', 'Conversación entre mafiosos', 'Red5', 'es_ES', 1, 'serie, mafiosos', 'Conversación mafiosos', 'mafiosos_conv.jpg', '2010-02-02 00:23:33', 38, 'Unavailable', 'bc1f4ee5459657d761e70582d6c12bfc', NULL, 'www.eitb.com'),
(4, 'pokemon_zatia', 'Pokemon marrazki bizidunen zatia', 'Red5', 'eu_ES', 1, 'pokemon, zatia', 'Pokemon zatia', 'pokemon_zatia.jpg', '2010-02-02 01:23:34', 84, 'Unavailable', '00c843cdaccae236dc4e33f6bf9423c6', NULL, 'www.eitb.com'),
(5, 'tdes_1065_qa', 'Repeat phrases and then talk to Sarah', 'Red5', 'en_US', 1, 'daily, english, show', 'The Daily English Show #1065 Fragment', 'tdes_1065_qa.jpg', '2010-03-08 12:10:00', 43, 'Available', '161abc5e831c545305f55f4139fd4799', NULL, 'www.thedailyenglishshow.com'),
(6, 'tdes_1170_qa', 'Repeat phrases and then talk to Sarah', 'Red5', 'en_US', 1, 'daily, english, show', 'The Daily English Show #1170 Fragment', 'tdes_1170_qa.jpg', '2010-03-08 12:10:00', 52, 'Available', '38b99457f8cd8af5b56728c5e2f0485b', NULL, 'www.thedailyenglishshow.com'),
(7, 'tdes_1179_qa', 'Repeat phrases and then talk to Sarah', 'Red5', 'en_US', 1, 'daily, english, show', 'The Daily English Show #1179 Fragment', 'tdes_1179_qa.jpg', '2010-03-08 12:10:00', 30, 'Available', '4fe59e622c208b53dc4e61cfdcb7b2a8', NULL, 'www.thedailyenglishshow.com'),
(8, 'tdes_1183_qa', 'Repeat phrases and then talk to Sarah', 'Red5', 'en_US', 1, 'daily, english, show', 'The Daily English Show #1183 Fragment', 'tdes_1183_qa.jpg', '2010-03-08 12:10:00', 40, 'Available', '2f8d1bde45ae7a7d303d663bcdf2ae8c', NULL, 'www.thedailyenglishshow.com'),
(9, 'tdes_1187_qa', 'Repeat phrases and then talk to Sarah', 'Red5', 'en_US', 1, 'daily, english, show', 'The Daily English Show #1187 Fragment', 'tdes_1187_qa.jpg', '2010-03-08 12:10:00', 57, 'Available', 'a0cd07a3ac94d2dbf77ca1c02c6278cc', NULL, 'www.thedailyenglishshow.com'),
(10, 'english_long', 'english lessons', 'Red5', 'en_US', 1, 'english', 'English lessons', 'english_long.jpg', '2009-10-22 18:00:00', 59, 'Unavailable', 'e1fdbb47ead995d5973a30d466e7533d', NULL, ''),
(11, 'english', 'english lessons', 'Red5', 'en_US', 1, 'english', 'English lessons short', 'english.jpg', '2009-10-22 18:00:00', 12, 'Unavailable', 'fc1b11475ce5233acf10bfb39925cacc', 1, ''),
(12, '4BU3y3nkB7c', 'Presentation', 'Red5', 'fr_FR', 1, 'french, talk', 'Presentation', '4BU3y3nkB7c.jpg', '2010-04-15 13:17:08', 31, 'Available', 'e52964a1d207b5014b778ceb1016da8b', NULL, ''),
(13, '08s08c4o3El', 'Goenkale telesaileko zati bat', 'Red5', 'eu_ES', 1, 'euskara, goenkale', 'Goenkale Zatia I', '08s08c4o3El.jpg', '2010-04-15 13:18:14', 38, 'Available', 'f03a80496520e2d275cef027b69aa379', NULL, 'www.eitb.com'),
(14, 'iQ8pI4bFwQh', 'Goenkale telesaileko zatia', 'Red5', 'eu_ES', 1, 'euskara, goenkale', 'Goenkale Zatia II', 'iQ8pI4bFwQh.jpg', '2010-04-15 13:19:33', 110, 'Available', '632fbbf33993892b9794f1cc324cd8d1', NULL, 'www.eitb.com'),
(15, 'COSYB49sT1G', 'Frases sencillas de la vida cotidiana', 'Red5', 'es_ES', 1, 'frases, cotidianas', 'Español Latino Para Niños', 'COSYB49sT1G.jpg', '2010-04-15 13:21:45', 63, 'Available', '4878a56679f48167686adc80e267506f', NULL, '');

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
-- Volcar la base de datos para la tabla `preferences`
--

INSERT INTO `preferences` (`prefName`, `prefValue`) VALUES
('initialCredits', '15'),
('subtitleAdditionCredits', '2'),
('evaluationRequestCredits', '2'),
('evaluatedWithVideoCredits', '2'),
('videoSuggestCredits', '2'),
('dailyLoginCredits', '0.5'),
('evaluatedWithCommentCredits', '1.5'),
('evaluatedWithScoreCredits', '0.5'),
('subtitleTranslationCredits', '1.5'),
('uploadExerciseCredits', '2'),
('dbrevision', '$Revision$'),
('appRevision', '0'),
('trial.threshold', '10'),
('hashLength', '20'),
('hashChars', 'abcdefghijklmnopqrstuvwxyz0123456789-_'),
('ffmpeg.path', '/usr/bin/ffmpeg'),
('spinvox.useragent', 'babelia'),
('spinvox.language', 'en'),
('spinvox.language', 'fr'),
('spinvox.language', 'de'),
('spinvox.language', 'it'),
('spinvox.language', 'pt'),
('spinvox.language', 'es'),
('spinvox.appname', 'babelia-auto_correction'),
('spinvox.account_id', '2009-2385-6238-3307'),
('spinvox.password', 'kviAcV6a'),
('spinvox.protocol', 'https'),
('spinvox.username', 'babelia2009'),
('spinvox.port', '443'),
('spinvox.dev_url', 'dev.api.spinvox.com'),
('spinvox.live_url', 'live.api.spinvox.com'),
('spinvox.max_transcriptions', '10'),
('spinvox.max_requests', '50'),
('spinvox.video_path', '/opt/red5/webapps/oflaDemo/streams'),
('spinvox.temp_folder', '/tmp'),
('spinvox.max_duration', '30'),
('spinvox.dev_mode', 'true'),
('positives_to_next_level', '15'),
('reports_to_delete', '10'),
('positives_to_next_level', '15'),
('reports_to_delete', '10'),
('bwCheckMin', '3000'),
('exerciseFolder', 'exercises'),
('evaluationFolder','evaluations'),
('responseFolder','responses');

--
-- Volcar la base de datos para la tabla `subtitle`
--

INSERT INTO `subtitle` (`id`, `fk_exercise_id`, `fk_user_id`, `language`, `translation`, `adding_date`) VALUES
(1, 2, 2, 'es_ES', 0, '2009-09-10 13:52:37'),
(2, 2, 1, 'eu_ES', 1, '2009-09-10 13:52:37'),
(3, 2, 3, 'en_US', 1, '2009-09-10 13:52:37'),
(4, 1, 1, 'eu_ES', 0, '2010-03-01 10:59:20'),
(5, 5, 1, 'en_US', 0, '2010-04-19 14:25:22'),
(6, 6, 1, 'en_US', 0, '2010-04-19 14:25:22'),
(7, 7, 1, 'en_US', 0, '2010-04-19 14:25:22'),
(8, 8, 1, 'en_US', 0, '2010-04-19 14:25:22'),
(9, 9, 1, 'en_US', 0, '2010-04-19 14:25:22');

--
-- Volcar la base de datos para la tabla `subtitle_line`
--

INSERT INTO `subtitle_line` (`id`, `fk_subtitle_id`, `show_time`, `hide_time`, `text`, `fk_exercise_role_id`) VALUES
(1, 1, 1.6, 3.76, '¿Por qué quiere un boxeador trabajar en la construcción?', 1),
(2, 1, 4.96, 6.76, 'Está arruinado, y no tiene trabajo y...', 2),
(3, 1, 6.92, 8, 'y quiere que le contrate...', 1),
(4, 1, 8.1, 9.4, 'Yo podría enseñarle a manejar la excavadora.', 2),

(5, 2, 1.6, 3.76, 'Zergatik nahi du boxeolari batek eraikuntzan lan egin?', 3),
(6, 2, 4.96, 6.76, 'Dirurik ez du, eta ez lanik ere...', 4),
(7, 2, 6.92, 8, 'eta nik kontratatzea nahi duzu...', 3),
(8, 2, 8.1, 9.4, 'Nik erakutsi niezaioke eskabadora erabiltzen.', 4),

(9, 3, 1.6, 3.76, 'Why a boxer wants to work in construction?', 5),
(10, 3, 4.96, 6.76, 'He is ruined, and doesn''t have a job', 6),
(11, 3, 6.92, 8, 'and you want me to hire him...', 5),
(12, 3, 8.1, 9.4, 'I could teach him to handle the excavator.', 6),

(13, 4, 5.8, 7.48, 'Esan zertan ari zareten. Ikasten...', 7),
(14, 4, 7.79, 11.2, 'edo lanean, edo alferkeri goxo-goxoan... e?', 7),
(15, 4, 11.34, 15.04, 'eta zergaitik etorri zareten udako eskola honetara.', 7),
(16, 4, 18.96, 22.32, 'Ni? bueno ni Joxemari naiz. Haragizko... ez, haragijale', 8),

(17, 5, 0.3, 1.204, 'What''s that?', 9),
(18, 5, 1.404, 2.904, 'What''s that?', 10),
(19, 5, 3.104, 5.215, 'Can''t you just use your sleeve?', 9),
(20, 5, 5.415, 8.204, 'Can''t you just use your sleeve?', 10),
(21, 5, 8.404, 9.226, 'Who gave it to you?', 9),
(22, 5, 9.426, 11.504, 'Who gave it to you?', 10),
(23, 5, 11.704, 14.307, 'Look I got a present', 9),
(24, 5, 14.507, 15.604, 'What''s that?', 10),
(25, 5, 15.804, 18.519, 'It''s a "Keitai kurina"', 9),
(26, 5, 18.719, 19.6, 'What''s that?', 10),
(27, 5, 19.8, 28.513, 'Well, "Keitai" means cell-phone and this has material on the back of it and it''s for cleaning...', 9),
(28, 5, 28.713, 30.9, 'Can''t you just use your sleeve?', 10),
(29, 5, 31.1, 32.825, 'Well... yeah, but...', 9),
(30, 5, 33.025, 34.3, 'Who gave it to you?', 10),
(31, 5, 34.5, 43, 'Am NHK. They made a new website, and they used a few seconds of one of...', 9),

(32, 6, 0.3, 2.307, 'Oh, it''s going that well, huh?', 11),
(33, 6, 2.507, 4.9, 'Oh, it''s going that well, huh?', 12),
(34, 6, 5.1, 8.023, 'When do I get to meet the phantom physician?', 11),
(35, 6, 8.223, 10.7, 'When do I get to meet the phantom physician?', 12),
(36, 6, 10.9, 12.205, 'You guys got plans tonight?', 11),
(37, 6, 12.405, 13.9, 'You guys got plans tonight?', 12),
(38, 6, 14.1, 15.41, 'You know what you should do?', 11),
(39, 6, 15.61, 17, 'You know what you should do?', 12),
(40, 6, 17.2, 19.321, 'You should fly up and surprise him.', 11),
(41, 6, 19.521, 21.9, 'You should fly up and surprise him.', 12),
(42, 6, 22.1, 23.232, 'Yeah, why not?', 11),
(43, 6, 23.432, 25, 'Yeah, why not?', 12),
(44, 6, 25.2, 26.716, 'He''s just the first decent guy I dated in a long time.', 11),
(45, 6, 26.916, 31.2, 'Oh, it''s going that well, huh?', 12),
(46, 6, 31.4, 34.831, 'I''m so sick of dating. I''m so jealous of you guys.', 11),
(47, 6, 35.031, 37.6, 'When do I get to meet the phantom physician?', 12),
(48, 6, 37.8, 38.608, 'I think soon.', 11),
(49, 6, 38.808, 40.7, 'You guys got plans tonight?', 12),
(50, 6, 40.9, 45.828, 'No, nothing. Just... he has to go to San Francisco so we''re gonna talk on the...', 11),
(51, 6, 46.028, 49.9, 'You know what you should do? You should fly up and surprise him.', 12),
(52, 6, 50.1, 50.808, 'You think so?', 11),
(53, 6, 51.008, 52.4, 'Yeah, why not?', 12),

(54, 7, 0.3, 1.605, 'OK, now what?', 13),
(55, 7, 1.805, 3.1, 'OK, now what?', 14),
(56, 7, 3.3, 5.917, 'OK, that''s fair. On three?', 13),
(57, 7, 6.117, 7.6, 'OK, that''s fair. On three?', 14),
(58, 7, 7.8, 10.129, 'One, two, three.', 13),
(59, 7, 10.329, 12.1, 'One, two, three.', 14),
(60, 7, 12.3, 13.505, 'I threw paper!', 13),
(61, 7, 13.705, 15.1, 'I threw paper!', 14),
(62, 7, 17.114, 17.7, 'OK, now what?', 14),
(63, 7, 17.9, 19.722, 'Rock-paper-scissors for it', 13),
(64, 7, 19.922, 21.6, 'OK, that''s fair. On three?', 14),
(65, 7, 21.8, 23.031, 'Yeah.', 13),
(66, 7, 23.231, 27.51, 'One, two, three.', 14),
(67, 7, 27.71, 28.7, 'I threw paper!', 14),
(68, 7, 28.9, 29.3, 'I threw a rock!', 13),

(69, 8, 0.3, 1.806, 'How was your day?', 15),
(70, 8, 2.006, 3.1, 'How was your day?', 16),
(71, 8, 3.3, 4.012, 'What about?', 15),
(72, 8, 4.212, 5.3, 'What about?', 16),
(73, 8, 5.5, 6.92, 'What''s gonna happen to it?', 15),
(74, 8, 7.12, 9, 'What''s gonna happen to it?', 16),
(75, 8, 9.2, 10.831, 'So they''re gonna get rid of it?', 15),
(76, 8, 11.031, 13.7, 'So they''re gonna get rid of it?', 16),
(77, 8, 14.507, 16.1, 'How was your day?', 16),
(78, 8, 16.3, 19.923, 'Good! I went to a protest this afternoon', 15),
(79, 8, 20.123, 21.2, 'What about?', 16),
(80, 8, 21.4, 26.106, 'It was about protecting national public service radio broadcasting', 15),
(81, 8, 26.306, 27.9, 'What''s gonna happen to it?', 16),
(82, 8, 28.1, 31.923, 'Well... the government wants to save money...', 15),
(83, 8, 32.123, 33.3, 'So they''re gonna get rid of it?', 16),
(84, 8, 33.5, 39.8, 'Not quite, but they suggested stuff like introducing advertising, which would...', 15),

(85, 9, 0.3, 2.006, 'What are you up to this weekend?', 17),
(86, 9, 2.206, 3.6, 'What are you up to this weekend?', 18),
(87, 9, 3.8, 4.613, 'Where''s that?', 17),
(88, 9, 4.813, 5.8, 'Where''s that?', 18),
(89, 9, 6, 8.123, 'Oh yeah, I know where the Albert Park is.', 17),
(90, 9, 8.323, 10.8, 'Oh yeah, I know where the Albert Park is.', 18),
(91, 9, 11, 13.906, 'That''s were the lantern festival was last week.', 17),
(92, 9, 14.106, 17.4, 'That''s were the lantern festival was last week.', 18),
(93, 9, 17.6, 19.12, 'Yeah, did you?', 17),
(94, 9, 19.32, 20.8, 'Yeah, did you?', 18),
(95, 9, 21, 23.7, 'Yeah. What day did you go?', 17),
(96, 9, 23.9, 26.5, 'Yeah. What day did you go?', 18),
(97, 9, 27.309, 29.1, 'What are you up to this weekend?', 18),
(98, 9, 29.3, 34.229, 'Ah, I''m not sure yet. I might go and check out the concert on sunday.', 17),
(99, 9, 34.429, 35.5, 'Where''s that?', 18),
(100, 9, 35.7, 39.611, 'It''s in Albert Park which is the park near the university.', 17),
(101, 9, 39.811, 45.2, 'Oh yeah, I know where the Albert Park is. That''s were the lantern festival...', 18),
(102, 9, 45.4, 48.201, 'Yeah that''s the one. Did you go to that festival?', 17),
(103, 9, 48.401, 49.6, 'Yeah, did you?', 18),
(104, 9, 49.8, 52.012, 'Yeah, it was awesome, wasn''t it?', 17),
(105, 9, 52.212, 53.8, 'Yeah. What day did you go?', 18),
(106, 9, 54, 57.1, 'Am, Sunday I think it was. Yeah, yeah, Sunday night.', 17);

--
-- Volcar la base de datos para la tabla `tagcloud`
--

INSERT INTO `tagcloud` (`tag`, `amount`) VALUES
('mafiosos', 7),
('english', 7),
('french', 5),
('moto', 5),
('motos', 5),
('oficina', 3),
('carrera', 3),
('perros', 3),
('carreta', 3),
('esparragos', 3),
('friends', 3),
('tomates', 3),
('guisantes', 3),
('zanahorias', 3),
('lechugas', 3),
('puerros', 3),
('ortalizas', 3),
('frescas', 3),
('tostadas', 3),
('torta', 3),
('tortilla', 3),
('huevos', 3),
('fritanga', 3),
('mono', 3),
('toro', 3),
('caballo', 3),
('cerdo', 3),
('serie', 1);

--
-- Volcar la base de datos para la tabla `transcription`
--

INSERT INTO `transcription` (`id`, `adding_date`, `status`, `transcription`, `transcription_date`, `system`) VALUES
(1, '2009-10-20 16:24:59', 'pending', NULL, NULL, 'spinvox'),
(2, '2009-10-20 16:24:59', 'pending', NULL, NULL, 'spinvox');

--
-- Volcar la base de datos para la tabla `users`
--

INSERT INTO `users` (`ID`, `name`, `password`, `email`, `realName`, `realSurname`, `creditCount`, `joiningDate`, `active`, `activation_hash`) VALUES
(1, 'erab1', '4eff1c28f92bb604596e75d2c98bf7085ac685c4', 'erab1@gmail.com', 'erab1', 'erab1', 25, '2009-07-02 12:30:00', 1, ''),
(2, 'erab2', '4eff1c28f92bb604596e75d2c98bf7085ac685c4', 'erab2@gmail.com', 'erab2', 'erab2', 25, '2009-07-02 12:30:00', 1, ''),
(3, 'erab3', '4eff1c28f92bb604596e75d2c98bf7085ac685c4', 'erab3@gmail.com', 'erab3', 'erab3', 25, '2009-07-02 12:30:00', 0, ''),
(5, 'erab4', '4eff1c28f92bb604596e75d2c98bf7085ac685c4', 'erab4@gmail.com', 'erab4', 'erab4', 25, '2009-07-02 12:30:00', 0, '');

INSERT INTO `user_languages` (`fk_user_id`,`language`,`level`,`positives_to_next_level`) VALUES
(1, 'es_ES', 7, 0),
(1, 'en_US', 3, 15),
(2, 'en_US', 7, 0),
(2, 'es_ES', 3, 15);


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
  ADD CONSTRAINT `FK_exercises_1` FOREIGN KEY (`fk_user_id`) REFERENCES `users` (`ID`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_exercise_transcriptions1` FOREIGN KEY (`fk_transcription_id`) REFERENCES `transcription` (`id`) ON DELETE SET NULL;

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
-- Filtros para la tabla `exercise_report`
--
ALTER TABLE `exercise_report`
  ADD CONSTRAINT `FK_exercise_report_1` FOREIGN KEY (`fk_exercise_id`) REFERENCES `exercise` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `FK_exercise_report_2` FOREIGN KEY (`fk_user_id`) REFERENCES `users` (`ID`) ON DELETE NO ACTION ON UPDATE NO ACTION;

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
  ADD CONSTRAINT `FK_response_3` FOREIGN KEY (`fk_subtitle_id`) REFERENCES `subtitle` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `FK_response_1` FOREIGN KEY (`fk_user_id`) REFERENCES `users` (`ID`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `FK_response_2` FOREIGN KEY (`fk_exercise_id`) REFERENCES `exercise` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_response_transcriptions1` FOREIGN KEY (`fk_transcription_id`) REFERENCES `transcription` (`id`) ON DELETE SET NULL;

--
-- Filtros para la tabla `spinvox_request`
--
ALTER TABLE `spinvox_request`
  ADD CONSTRAINT `fk_spinvox_requests_transcription1` FOREIGN KEY (`fk_transcription_id`) REFERENCES `transcription` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

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
-- Filtros para la tabla `user_languages`
--
ALTER TABLE `user_languages`
  ADD CONSTRAINT `FK_user_languages_1` FOREIGN KEY (`fk_user_id`) REFERENCES `users` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `user_session`
--
ALTER TABLE `user_session`
  ADD CONSTRAINT `FK_user_session_1` FOREIGN KEY (`fk_user_id`) REFERENCES `users` (`ID`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `user_videohistory`
--
ALTER TABLE `user_videohistory`
  ADD CONSTRAINT `FK_user_videohistory_1` FOREIGN KEY (`fk_user_id`) REFERENCES `users` (`ID`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `FK_user_videohistory_2` FOREIGN KEY (`fk_user_session_id`) REFERENCES `user_session` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `FK_user_videohistory_3` FOREIGN KEY (`fk_exercise_id`) REFERENCES `exercise` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `FK_user_videohistory_4` FOREIGN KEY (`fk_response_id`) REFERENCES `response` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `FK_user_videohistory_5` FOREIGN KEY (`fk_subtitle_id`) REFERENCES `subtitle` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `FK_user_videohistory_6` FOREIGN KEY (`fk_exercise_role_id`) REFERENCES `exercise_role` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;



