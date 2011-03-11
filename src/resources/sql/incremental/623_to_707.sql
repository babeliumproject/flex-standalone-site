-- Changes for adding an heuristic to sort the assessment pending responses 

ALTER TABLE `response` 
ADD COLUMN `priority_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP AFTER `fk_subtitle_id`;

UPDATE `response` SET `priority_date` = `adding_date` WHERE true;

UPDATE evaluation SET score_overall = 2*score_overall, score_intonation = 2*score_intonation, score_fluency = 2*score_fluency, score_rhythm = 2*score_rhythm, score_spontaneity = 2*score_spontaneity WHERE true;

UPDATE exercise_score SET suggested_score = 2*suggested_score WHERE true;

INSERT INTO preferences (prefName, prefValue) VALUES ('web_domain', 'babelia');

-- SVN control line. Must be added on each incremental script
UPDATE `preferences` SET `prefValue` =  '$Revision: 707 $'  WHERE `preferences`.`prefName` = 'dbrevision';
