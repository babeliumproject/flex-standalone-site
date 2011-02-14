ALTER TABLE `exercise_comment` DROP FOREIGN KEY `FK_exercise_comments_1` ;
ALTER TABLE `exercise_comment` 
  ADD CONSTRAINT `FK_exercise_comments_1`
  FOREIGN KEY (`fk_exercise_id` )
  REFERENCES `exercise` (`id` )
  ON DELETE CASCADE
  ON UPDATE CASCADE;


ALTER TABLE `credithistory` DROP FOREIGN KEY `FK_credithistory_2` ;
ALTER TABLE `credithistory` 
  ADD CONSTRAINT `FK_credithistory_2`
  FOREIGN KEY (`fk_exercise_id` )
  REFERENCES `exercise` (`id` )
  ON DELETE CASCADE
  ON UPDATE CASCADE;


ALTER TABLE `exercise_level` DROP FOREIGN KEY `FK_exercise_level_1` ;
ALTER TABLE `exercise_level` 
  ADD CONSTRAINT `FK_exercise_level_1`
  FOREIGN KEY (`fk_exercise_id` )
  REFERENCES `exercise` (`id` )
  ON DELETE CASCADE
  ON UPDATE CASCADE;

UPDATE `preferences` SET `prefValue` =  '$Revision: 570 $'  WHERE `preferences`.`prefName` = 'dbrevision';
