CREATE  TABLE `rel_exercise_descriptor` (
  `fk_exercise_id` INT UNSIGNED NOT NULL ,
  `fk_exercise_descriptor_id` INT UNSIGNED NOT NULL ,
  PRIMARY KEY (`fk_exercise_id`, `fk_exercise_descriptor_id`) ,
  INDEX `fk_rel_exercise_descriptor_1` (`fk_exercise_id` ASC) ,
  INDEX `fk_rel_exercise_descriptor_2` (`fk_exercise_descriptor_id` ASC) ,
  CONSTRAINT `fk_rel_exercise_descriptor_1`
    FOREIGN KEY (`fk_exercise_id` )
    REFERENCES `exercise` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_rel_exercise_descriptor_2`
    FOREIGN KEY (`fk_exercise_descriptor_id` )
    REFERENCES `exercise_descriptor` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;
