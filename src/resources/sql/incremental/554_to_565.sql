ALTER TABLE `evaluation` 
CHANGE COLUMN `score_overall` `score_overall` TINYINT NULL DEFAULT 0  , 
CHANGE COLUMN `adding_date` `adding_date` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP  , 
ADD COLUMN `score_intonation` `score_intonation` TINYINT UNSIGNED NULL DEFAULT 0  , 
ADD COLUMN `score_fluency` `score_fluency` TINYINT UNSIGNED NULL DEFAULT 0  , 
ADD COLUMN `score_rhythm` `score_rhythm` TINYINT UNSIGNED NULL DEFAULT 0  , 
ADD COLUMN `score_spontaneity` `score_spontaneity` TINYINT UNSIGNED NULL DEFAULT 0  ;

UPDATE `preferences` SET `prefValue`='3' WHERE `preferences`.`prefName` ='trial.threshold';


UPDATE `preferences` SET `prefValue` =  '$Revision: 565 $'  WHERE `preferences`.`prefName` = 'dbrevision';
