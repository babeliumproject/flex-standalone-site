DELETE FROM `rel_exercise_descriptor` WHERE TRUE;
DELETE FROM `exercise_descriptor_i18n` WHERE TRUE;

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
