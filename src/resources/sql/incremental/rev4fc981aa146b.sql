CREATE  TABLE `tag` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `name` VARCHAR(45) NOT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


CREATE  TABLE `rel_exercise_tag` (
  `fk_exercise_id` INT UNSIGNED NOT NULL ,
  `fk_tag_id` INT UNSIGNED NOT NULL ,
  PRIMARY KEY (`fk_exercise_id`, `fk_tag_id`) ,
  INDEX `fk_rel_exercise_tag_1` (`fk_exercise_id` ASC) ,
  INDEX `fk_rel_exercise_tag_2` (`fk_tag_id` ASC) ,
  CONSTRAINT `fk_rel_exercise_tag_1`
    FOREIGN KEY (`fk_exercise_id` )
    REFERENCES `exercise` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_rel_exercise_tag_2`
    FOREIGN KEY (`fk_tag_id` )
    REFERENCES `tag` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

