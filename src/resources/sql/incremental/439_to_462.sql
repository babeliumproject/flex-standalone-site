ALTER TABLE `users` ADD COLUMN `isAdmin` TINYINT NOT NULL DEFAULT 0 AFTER `activation_hash`;

UPDATE `preferences` SET `prefValue` =  '$Revision: 462 $'  WHERE `preferences`.`prefName` = 'dbrevision';
