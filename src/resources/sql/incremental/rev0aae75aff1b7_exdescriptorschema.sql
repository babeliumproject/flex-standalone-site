CREATE  TABLE `exercise_descriptor` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `level` ENUM('A1','A2','B1','B2','C1','C2') NOT NULL ,
  `type` ENUM('L','R','SI','SP','S','LQ','W') NOT NULL ,
  `number` INT UNSIGNED NOT NULL ,
  PRIMARY KEY (`id`),
  UNIQUE KEY(`level`,`type`,`number`)
) ENGINE = InnoDB;


CREATE  TABLE `exercise_descriptor_i18n` (
  `fk_exercise_descriptor_id` INT UNSIGNED NOT NULL ,
  `locale` VARCHAR(8) NOT NULL ,
  `name` TEXT NOT NULL ,
  INDEX `fk_exercise_descriptor_i18n_1` (`fk_exercise_descriptor_id` ASC) ,
  PRIMARY KEY (`fk_exercise_descriptor_id`,`locale`),
  CONSTRAINT `fk_exercise_descriptor_i18n_1`
    FOREIGN KEY (`fk_exercise_descriptor_id` )
    REFERENCES `exercise_descriptor` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;
