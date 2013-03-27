

ALTER TABLE `credithistory` DROP FOREIGN KEY `FK_credithistory_3` ;

ALTER TABLE `credithistory` 
  ADD CONSTRAINT `FK_credithistory_3`
  FOREIGN KEY (`fk_response_id` )
  REFERENCES `response` (`id` )
  ON DELETE CASCADE
  ON UPDATE CASCADE;



ALTER TABLE `user_videohistory` DROP FOREIGN KEY `FK_user_videohistory_4` ;
ALTER TABLE `user_videohistory` 
  ADD CONSTRAINT `FK_user_videohistory_4`
  FOREIGN KEY (`fk_response_id` )
  REFERENCES `response` (`id` )
  ON DELETE CASCADE
  ON UPDATE CASCADE;

-- SVN control line. Must be added on each incremental script
UPDATE `preferences` SET `prefValue` =  '$Revision: 605 $'  WHERE `preferences`.`prefName` = 'dbrevision';
