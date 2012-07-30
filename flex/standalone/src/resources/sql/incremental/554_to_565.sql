ALTER TABLE `evaluation` 
CHANGE COLUMN `score` `score_overall` TINYINT NULL DEFAULT 0, 
CHANGE COLUMN `adding_date` `adding_date` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP, 
ADD COLUMN `score_intonation` TINYINT UNSIGNED NULL DEFAULT 0 AFTER `adding_date`, 
ADD COLUMN `score_fluency` TINYINT UNSIGNED NULL DEFAULT 0 AFTER `score_intonation`, 
ADD COLUMN `score_rhythm` TINYINT UNSIGNED NULL DEFAULT 0 AFTER `score_fluency`, 
ADD COLUMN `score_spontaneity` TINYINT UNSIGNED NULL DEFAULT 0 AFTER `score_rhythm`;

UPDATE `preferences` SET `prefValue`='3' WHERE `preferences`.`prefName` ='trial.threshold';


UPDATE `preferences` SET `prefValue` =  '$Revision: 565 $'  WHERE `preferences`.`prefName` = 'dbrevision';
