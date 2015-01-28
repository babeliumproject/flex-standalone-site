ALTER TABLE `exercise`
ADD COLUMN `type` INT unsigned NOT NULL DEFAULT '5' AFTER `reference`,
ADD COLUMN `situation` INT NULL AFTER `type`,
ADD COLUMN `competence` INT NULL AFTER `situation`,
ADD COLUMN `lingaspects` VARCHAR(45) NULL AFTER `competence`;
