DELETE UL, U
FROM user_languages UL LEFT OUTER JOIN users U on UL.fk_user_id = U.ID
WHERE U.ID IS NULL;

ALTER TABLE `user_languages` 
  ADD CONSTRAINT `fk_user_languages_1`
  FOREIGN KEY (`fk_user_id` )
  REFERENCES `users` (`ID` )
  ON DELETE CASCADE
  ON UPDATE CASCADE
, ADD INDEX `fk_user_languages_1` (`fk_user_id` ASC) ;

