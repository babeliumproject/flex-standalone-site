CREATE TABLE `exercise_report` (
  `id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `fk_exercise_id` INT(10) UNSIGNED NOT NULL,
  `fk_user_id` INT(10) UNSIGNED NOT NULL,
  `reason` VARCHAR(100)  NOT NULL,
  `report_date` TIMESTAMP  NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT `FK_exercise_report_1` FOREIGN KEY `FK_exercise_report_1` (`fk_exercise_id`)
    REFERENCES `exercise` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `FK_exercise_report_2` FOREIGN KEY `FK_exercise_report_2` (`fk_user_id`)
    REFERENCES `users` (`ID`) ON DELETE NO ACTION ON UPDATE NO ACTION
)
ENGINE = InnoDB
DEFAULT CHARSET=utf8;

ALTER TABLE `response` ADD COLUMN `fk_subtitle_id` INT UNSIGNED AFTER `fk_transcription_id`,
 ADD CONSTRAINT `FK_response_3` FOREIGN KEY `FK_response_3` (`fk_subtitle_id`)
    REFERENCES `subtitle` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


INSERT INTO `preferences` (`prefName`, `prefValue`) VALUES ('positives_to_next_level', 15);
INSERT INTO `preferences` (`prefName`, `prefValue`) VALUES ('reports_to_delete',10);

INSERT INTO `preferences` (`prefName`, `prefValue`) VALUES ('bwCheckMin', 3000);
