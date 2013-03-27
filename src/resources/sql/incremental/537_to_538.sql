UPDATE exercise SET reference = 'http://www.thedailyenglishshow.com' WHERE title LIKE '%The Daily English%';
UPDATE exercise SET reference = 'http://www.eitb.com' WHERE title LIKE '%Goenkale%';
UPDATE exercise SET reference = 'http://www.eitb.com' WHERE title LIKE '%zatia%';

UPDATE `preferences` SET `prefValue` =  '$Revision: 538 $'  WHERE `preferences`.`prefName` = 'dbrevision';
