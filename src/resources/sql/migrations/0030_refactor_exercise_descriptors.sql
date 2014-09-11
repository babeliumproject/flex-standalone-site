DROP TABLE IF EXISTS `rel_exercise_descriptor`;
DROP TABLE IF EXISTS `exercise_descriptor_i18n`;
DROP TABLE IF EXISTS `exercise_descriptor`;

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

CREATE TABLE `exercise_descriptor_i18n` (
  `fk_exercise_descriptor_id` int(10) unsigned NOT NULL,
  `locale` varchar(8) NOT NULL,
  `name` text NOT NULL,
  PRIMARY KEY (`fk_exercise_descriptor_id`,`locale`),
  KEY `fk_exercise_descriptor_i18n_1` (`fk_exercise_descriptor_id`),
  CONSTRAINT `fk_exercise_descriptor_i18n_1` FOREIGN KEY (`fk_exercise_descriptor_id`) REFERENCES `exercise_descriptor` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `rel_exercise_descriptor` (
  `fk_exercise_id` int(10) unsigned NOT NULL,
  `fk_exercise_descriptor_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`fk_exercise_id`,`fk_exercise_descriptor_id`),
  KEY `fk_rel_exercise_descriptor_1` (`fk_exercise_id`),
  KEY `fk_rel_exercise_descriptor_2` (`fk_exercise_descriptor_id`),
  CONSTRAINT `fk_rel_exercise_descriptor_1` FOREIGN KEY (`fk_exercise_id`) REFERENCES `exercise` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_rel_exercise_descriptor_2` FOREIGN KEY (`fk_exercise_descriptor_id`) REFERENCES `exercise_descriptor` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
