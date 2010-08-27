ALTER TABLE `babeliumproject`.`exercise_comment` DROP FOREIGN KEY `FK_exercise_comments_1` ;
ALTER TABLE `babeliumproject`.`exercise_comment` 
  ADD CONSTRAINT `FK_exercise_comments_1`
  FOREIGN KEY (`fk_exercise_id` )
  REFERENCES `babeliumproject`.`exercise` (`id` )
  ON DELETE CASCADE
  ON UPDATE CASCADE;


ALTER TABLE `babeliumproject`.`credithistory` DROP FOREIGN KEY `FK_credithistory_2` ;
ALTER TABLE `babeliumproject`.`credithistory` 
  ADD CONSTRAINT `FK_credithistory_2`
  FOREIGN KEY (`fk_exercise_id` )
  REFERENCES `babeliumproject`.`exercise` (`id` )
  ON DELETE CASCADE
  ON UPDATE CASCADE;


ALTER TABLE `babeliumproject`.`exercise_level` DROP FOREIGN KEY `FK_exercise_level_1` ;
ALTER TABLE `babeliumproject`.`exercise_level` 
  ADD CONSTRAINT `FK_exercise_level_1`
  FOREIGN KEY (`fk_exercise_id` )
  REFERENCES `babeliumproject`.`exercise` (`id` )
  ON DELETE CASCADE
  ON UPDATE CASCADE;

