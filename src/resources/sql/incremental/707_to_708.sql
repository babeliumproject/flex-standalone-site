-- Changes for adding video_slice management related changes

ALTER TABLE `exercise` 
CHANGE `status` `status` ENUM( 'Unsliced', 'Unprocessed', 'Processing', 'Available', 'Rejected', 'Error', 'Unavailable' ) NOT NULL DEFAULT 'Unprocessed'

INSERT INTO `babeliumproject`.`preferences` (`id` , `prefName` , `prefValue`)
VALUES (
NULL , 'uploadSliceCredits', '2'
), (
NULL , 'sliceDownCommandPath', 'C:\\\\Python27\\\\python.exe C:\\\\Users\\\\Iker\\\\Commands\\\\youtube-dl.py'
);


-- SVN control line. Must be added on each incremental script
UPDATE `preferences` SET `prefValue` =  '$Revision: 708 $'  WHERE `preferences`.`prefName` = 'dbrevision';