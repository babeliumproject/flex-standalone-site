ALTER TABLE `exercise_role` DROP FOREIGN KEY `FK_exercise_characters_1` ;
ALTER TABLE `exercise_role` 
  ADD CONSTRAINT `FK_exercise_characters_1`
  FOREIGN KEY (`fk_exercise_id` )
  REFERENCES `exercise` (`id` )
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE `exercise_score` DROP FOREIGN KEY `FK_exercise_score_1` ;
ALTER TABLE `exercise_score` 
  ADD CONSTRAINT `FK_exercise_score_1`
  FOREIGN KEY (`fk_exercise_id` )
  REFERENCES `exercise` (`id` )
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE `subtitle` DROP FOREIGN KEY `FK_exercise_subtitle_1` ;
ALTER TABLE `subtitle` 
  ADD CONSTRAINT `FK_exercise_subtitle_1`
  FOREIGN KEY (`fk_exercise_id` )
  REFERENCES `exercise` (`id` )
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE `response` DROP FOREIGN KEY `FK_response_2` ;
ALTER TABLE `response` 
  ADD CONSTRAINT `FK_response_2`
  FOREIGN KEY (`fk_exercise_id` )
  REFERENCES `exercise` (`id` )
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE `user_videohistory` DROP FOREIGN KEY `FK_user_videohistory_3` ;
ALTER TABLE `user_videohistory` 
  ADD CONSTRAINT `FK_user_videohistory_3`
  FOREIGN KEY (`fk_exercise_id` )
  REFERENCES `exercise` (`id` )
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE `subtitle_line` DROP FOREIGN KEY `FK_subtitle_line_1` , DROP FOREIGN KEY `FK_subtitle_line_2` ;
ALTER TABLE `subtitle_line` 
  ADD CONSTRAINT `FK_subtitle_line_1`
  FOREIGN KEY (`fk_subtitle_id` )
  REFERENCES `subtitle` (`id` )
  ON DELETE CASCADE
  ON UPDATE CASCADE, 
  ADD CONSTRAINT `FK_subtitle_line_2`
  FOREIGN KEY (`fk_exercise_role_id` )
  REFERENCES `exercise_role` (`id` )
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE `response` DROP FOREIGN KEY `FK_response_3` ;
ALTER TABLE `response` 
  ADD CONSTRAINT `FK_response_3`
  FOREIGN KEY (`fk_subtitle_id` )
  REFERENCES `subtitle` (`id` )
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE `user_videohistory` DROP FOREIGN KEY `FK_user_videohistory_5` , DROP FOREIGN KEY `FK_user_videohistory_6` ;
ALTER TABLE `user_videohistory` 
  ADD CONSTRAINT `FK_user_videohistory_5`
  FOREIGN KEY (`fk_subtitle_id` )
  REFERENCES `subtitle` (`id` )
  ON DELETE CASCADE
  ON UPDATE CASCADE, 
  ADD CONSTRAINT `FK_user_videohistory_6`
  FOREIGN KEY (`fk_exercise_role_id` )
  REFERENCES `exercise_role` (`id` )
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE `evaluation` DROP FOREIGN KEY `FK_evaluation_1` ;
ALTER TABLE `evaluation` 
  ADD CONSTRAINT `FK_evaluation_1`
  FOREIGN KEY (`fk_response_id` )
  REFERENCES `response` (`id` )
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE `evaluation_video` DROP FOREIGN KEY `FK_evaluation_video_1` ;
ALTER TABLE `evaluation_video` 
  ADD CONSTRAINT `FK_evaluation_video_1`
  FOREIGN KEY (`fk_evaluation_id` )
  REFERENCES `evaluation` (`id` )
  ON DELETE CASCADE
  ON UPDATE CASCADE;



