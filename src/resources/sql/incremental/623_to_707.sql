-- Changes for adding an heuristic to sort the assessment pending responses 

ALTER TABLE `response` 
ADD COLUMN `priority_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP AFTER `fk_subtitle_id`;

UPDATE `response` SET `priority_date` = `adding_date` WHERE true;

-- SVN control line. Must be added on each incremental script
UPDATE `preferences` SET `prefValue` =  '$Revision: 707 $'  WHERE `preferences`.`prefName` = 'dbrevision';
