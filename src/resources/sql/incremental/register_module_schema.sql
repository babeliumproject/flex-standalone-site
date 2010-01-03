ALTER TABLE `users` ADD `active` TINYINT( 1 ) NOT NULL DEFAULT '0';
ALTER TABLE `users` ADD `activation_hash` VARCHAR( 20 ) NOT NULL;
INSERT INTO preferences (prefName, prefValue) VALUES ('hashLength', 20), ('hashChars', 'abcdefghijklmnopqrstuvwxyz0123456789-_');
