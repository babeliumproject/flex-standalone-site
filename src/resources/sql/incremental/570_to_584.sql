INSERT INTO `preferences` (`prefName`, `prefValue`) VALUES ('minVideoRatingCount', 10);

ALTER TABLE `user_languages` ADD COLUMN `purpose` ENUM('practice','evaluate') NOT NULL DEFAULT 'practice'  AFTER `positives_to_next_level` ;
UPDATE `user_languages` SET `purpose`='evaluate' WHERE `level`=7;


-- SVN control line. Must be added on each incremental script
UPDATE `preferences` SET `prefValue` =  '$Revision: 571 $'  WHERE `preferences`.`prefName` = 'dbrevision';
