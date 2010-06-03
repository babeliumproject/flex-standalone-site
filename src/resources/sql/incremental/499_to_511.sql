ALTER TABLE `exercise` 
 ADD COLUMN `license` VARCHAR(60)  NOT NULL DEFAULT 'cc-by' COMMENT 'The kind of license this exercise is attached to' AFTER `fk_transcription_id`,
 ADD COLUMN `reference` TEXT  NOT NULL COMMENT 'The url or name of the entity that provided this resource (if any)' AFTER `license`;

UPDATE exercise SET reference = 'www.thedailyenglishshow.com' WHERE title LIKE '%The Daily English%';
UPDATE exercise SET reference = 'www.eitb.com' WHERE title LIKE '%Goenkale%';
UPDATE exercise SET reference = 'www.eitb.com' WHERE title LIKE '%zatia%';

