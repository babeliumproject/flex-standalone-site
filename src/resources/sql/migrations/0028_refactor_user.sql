DELETE FROM `preferences` WHERE prefName='spinvox.language' ;
INSERT INTO `preferences` (prefName, prefValue) VALUES ('spinvox.languages', 'en,fr,de,it,pt,es') ;

ALTER TABLE `preferences`
 ADD UNIQUE INDEX `prefName_UNIQUE` (`prefName` ASC) ;

-- Check for duplicated `name` fields before applying this change.
ALTER TABLE `users` 
 CHANGE COLUMN `ID` `id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT  ,
 CHANGE COLUMN `name` `username` VARCHAR(45) NOT NULL  , 
 CHANGE COLUMN `realName` `firstname` VARCHAR(45) NOT NULL  , 
 CHANGE COLUMN `realSurname` `lastname` VARCHAR(45) NOT NULL  ;

ALTER TABLE `users` 
 ADD UNIQUE INDEX `username_UNIQUE` (`username` ASC) ;

ALTER TABLE `users` RENAME TO  `user` ;
