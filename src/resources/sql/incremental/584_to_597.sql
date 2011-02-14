CREATE  TABLE `motd` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `title` VARCHAR(250) NOT NULL ,
  `message` TEXT NOT NULL ,
  `resource` VARCHAR(250) NOT NULL,
  `displaydate` DATETIME NOT NULL ,
  `displaywhenloggedin` TINYINT(1) NOT NULL DEFAULT 0,
  `code` VARCHAR(45) NULL COMMENT 'A numeric code to identify this particular message in different languages',
  `language` VARCHAR(5) NOT NULL,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_general_ci;


-- SVN control line. Must be added on each incremental script
UPDATE `preferences` SET `prefValue` =  '$Revision: 597 $'  WHERE `preferences`.`prefName` = 'dbrevision';
