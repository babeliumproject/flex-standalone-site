-- phpMyAdmin SQL Dump
-- version 3.1.3
-- http://www.phpmyadmin.net
--
-- Servidor: localhost
-- Tiempo de generación: 30-09-2009 a las 16:11:43
-- Versión del servidor: 5.0.67
-- Versión de PHP: 5.2.6-2ubuntu4.3

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

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
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=28 ;

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
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=10 ;

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
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=3 ;

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
  `thumbnail_uri` varchar(200) NOT NULL,
  `adding_date` datetime NOT NULL,
  `duration` int(10) unsigned NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `FK_exercises_1` (`fk_user_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=16 ;

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
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

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
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

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
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

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
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=5 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `grabaciones`
--

CREATE TABLE IF NOT EXISTS `grabaciones` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `id_user` int(10) unsigned NOT NULL,
  `id_vid` int(10) unsigned NOT NULL,
  `id_grab` varchar(45) NOT NULL,
  PRIMARY KEY  USING BTREE (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `preferences`
--

CREATE TABLE IF NOT EXISTS `preferences` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `prefName` varchar(45) NOT NULL,
  `prefValue` double NOT NULL default '0',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=11 ;

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
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=4 ;

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
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=4 ;

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
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=13 ;

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
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `subtitulos`
--

CREATE TABLE IF NOT EXISTS `subtitulos` (
  `ID_SUB` int(11) NOT NULL auto_increment,
  `ID_VID` int(11) NOT NULL,
  `idioma` varchar(45) default NULL,
  `textos` varchar(200) default NULL,
  `tiempo` int(11) NOT NULL,
  `duracion` int(11) NOT NULL,
  PRIMARY KEY  (`ID_SUB`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=27 ;

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
  PRIMARY KEY  (`ID`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=6 ;

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
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `videos`
--

CREATE TABLE IF NOT EXISTS `videos` (
  `ID` int(10) unsigned NOT NULL auto_increment,
  `nombre` varchar(45) default NULL,
  `desc` varchar(45) default NULL,
  `autor` varchar(45) default NULL,
  `fecha_envio` timestamp NULL default NULL,
  `thumbnail` varchar(45) default NULL,
  `duracion` int(11) default NULL,
  `etiquetas` varchar(45) default NULL,
  `MetaInfBabelia_ID_VIDEO` int(11) NOT NULL,
  `Subtitulos_ID_SUB` int(11) NOT NULL,
  PRIMARY KEY  USING BTREE (`ID`),
  KEY `fk_Videos_MetaInfBabelia` (`MetaInfBabelia_ID_VIDEO`),
  KEY `fk_Videos_Subtitulos` (`Subtitulos_ID_SUB`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=6 ;

--
-- Filtros para las tablas descargadas (dump)
--

--
-- Filtros para la tabla `credithistory`
--
ALTER TABLE `credithistory`
  ADD CONSTRAINT `FK_credithistory_1` FOREIGN KEY (`fk_user_id`) REFERENCES `users` (`ID`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `FK_credithistory_2` FOREIGN KEY (`fk_exercise_id`) REFERENCES `exercise` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `FK_credithistory_3` FOREIGN KEY (`fk_response_id`) REFERENCES `grabaciones` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

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
