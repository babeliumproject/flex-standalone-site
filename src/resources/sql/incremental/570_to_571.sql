INSERT INTO `preferences` (`prefName`, `prefValue`) VALUES ('minVideoRatingCount', 10);


-- SVN control line. Must be added on each incremental script
UPDATE `preferences` SET `prefValue` =  '$Revision: 571 $'  WHERE `preferences`.`prefName` = 'dbrevision';
