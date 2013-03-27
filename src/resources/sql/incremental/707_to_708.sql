-- Changes for adding video_slice management related changes

ALTER TABLE `exercise` 
CHANGE `status` `status` ENUM( 'Unsliced', 'Unprocessed', 'Processing', 'Available', 'Rejected', 'Error', 'Unavailable' ) NOT NULL DEFAULT 'Unprocessed';

INSERT INTO `preferences` (`prefName` , `prefValue`) VALUES ('uploadSliceCredits', '2');
INSERT INTO `preferences` (`prefName`, `prefValue`) VALUES ('subtitleLineMaxChars', '120');
INSERT INTO `preferences` (`prefName`, `prefValue`) VALUES ('sliceDownCommandPath', 'C:\\\\Python27\\\\python.exe C:\\\\Users\\\\Iker\\\\Commands\\\\youtube-dl.py');

ALTER TABLE `subtitle_line` CHANGE COLUMN `text` `text` VARCHAR(255) NOT NULL  ;

UPDATE `subtitle_line` SET `text`='Not quite, but they suggested stuff like introducing advertising, which would really suck.' WHERE `text` LIKE 'Not quite, but they suggested stuff%';
UPDATE `subtitle_line` SET `text`='No, nothing. Just... he has to go to San Francisco so we\'re gonna talk on the phone.' WHERE `text` LIKE 'No, nothing. Just%';
UPDATE `subtitle_line` SET `text`='Oh yeah, I know where the Albert Park is. That\'s were the lantern festival was last week.' WHERE `text` LIKE 'Oh yeah, I know where the Albert Park is. That\'s were the lantern%';
UPDATE `subtitle_line` SET `text`='Am Anichke. They made a new website, and they used a few seconds of one of my videos, so they sent me... this.' WHERE `text` LIKE 'Am Anichke. They made a new website, and they used a few seconds of on%';

ALTER TABLE `subtitle` ADD COLUMN `complete` TINYINT(1) UNSIGNED NOT NULL DEFAULT '0'  AFTER `adding_date` ;

ALTER TABLE `exercise` CHANGE COLUMN `status` `status` ENUM('Unprocessed','Processing','Available','Rejected','Error','Unavailable','UnprocessedNoPractice') NOT NULL DEFAULT 'Unprocessed'  ;



-- SVN control line. Must be added on each incremental script
UPDATE `preferences` SET `prefValue` =  '$Revision: 708 $'  WHERE `preferences`.`prefName` = 'dbrevision';

INSERT INTO `preferences` (`prefName` , `prefValue`) VALUES
('minExerciseDuration',15),
('maxExerciseDuration',120),
('minVideoEvalDuration',5),
('maxFileSize',188743680);

ALTER TABLE `exercise` CHANGE `name` `name` VARCHAR( 200 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT 'In case it''s Youtube video we''ll store here it''s uid'
