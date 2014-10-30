ALTER TABLE `media` 
ADD COLUMN `type` VARCHAR(45) NOT NULL DEFAULT 'video' AFTER `component`;
ADD COLUMN `defaultthumbnail` INT NULL DEFAULT '1' AFTER `fk_user_id`;

