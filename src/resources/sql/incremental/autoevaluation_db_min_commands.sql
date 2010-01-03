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
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=2 ;


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
ALTER TABLE `exercise` ADD COLUMN `fk_transcription_id` INT(10) UNSIGNED DEFAULT null AFTER `duration`,
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
