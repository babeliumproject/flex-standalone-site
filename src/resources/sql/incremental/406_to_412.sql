ALTER TABLE `babeliumproject`.`credithistory` CHARACTER SET utf8;
ALTER TABLE `babeliumproject`.`credithistory` MODIFY COLUMN `changeType` VARCHAR(45)  NOT NULL;

ALTER TABLE `babeliumproject`.`evaluation` CHARACTER SET utf8;
ALTER TABLE `babeliumproject`.`evaluation` MODIFY COLUMN `comment` TEXT ;

ALTER TABLE `babeliumproject`.`evaluation_video` CHARACTER SET utf8;
ALTER TABLE `babeliumproject`.`evaluation_video` 
 MODIFY COLUMN `video_identifier` VARCHAR(100)  NOT NULL,
 MODIFY COLUMN `source` ENUM('Youtube','Red5')  NOT NULL,
 MODIFY COLUMN `thumbnail_uri` VARCHAR(200)  NOT NULL;

ALTER TABLE `babeliumproject`.`exercise` CHARACTER SET utf8;
ALTER TABLE `babeliumproject`.`exercise` 
 MODIFY COLUMN `name` VARCHAR(80)  NOT NULL COMMENT 'In case it\'s Youtube video we\'ll store here it\'s uid',
 MODIFY COLUMN `description` TEXT  NOT NULL COMMENT 'Describe the video\'s content',
 MODIFY COLUMN `source` ENUM('Youtube','Red5')  NOT NULL COMMENT 'Specifies where the video comes from',
 MODIFY COLUMN `language` VARCHAR(45)  NOT NULL COMMENT 'The spoken language of this exercise',
 MODIFY COLUMN `tags` VARCHAR(100)  NOT NULL COMMENT 'Tag list each item separated with a comma',
 MODIFY COLUMN `title` VARCHAR(80)  NOT NULL,
 MODIFY COLUMN `status` ENUM('Unprocessed','Processing','Available','Rejected','Error','Unavailable')  NOT NULL DEFAULT 'Unprocessed';

ALTER TABLE `babeliumproject`.`exercise_comment` CHARACTER SET utf8;
ALTER TABLE `babeliumproject`.`exercise_comment` MODIFY COLUMN `comment` TEXT  NOT NULL;

ALTER TABLE `babeliumproject`.`exercise_level` CHARACTER SET utf8;

ALTER TABLE `babeliumproject`.`exercise_role` CHARACTER SET utf8;
ALTER TABLE `babeliumproject`.`exercise_role` MODIFY COLUMN `character_name` VARCHAR(45)  NOT NULL;

ALTER TABLE `babeliumproject`.`exercise_score` CHARACTER SET utf8;

ALTER TABLE `babeliumproject`.`preferences` CHARACTER SET utf8;
ALTER TABLE `babeliumproject`.`preferences` 
 MODIFY COLUMN `prefName` VARCHAR(45)  NOT NULL,
 MODIFY COLUMN `prefValue` VARCHAR(200)  NOT NULL;

ALTER TABLE `babeliumproject`.`response` CHARACTER SET utf8;
ALTER TABLE `babeliumproject`.`response` 
 MODIFY COLUMN `file_identifier` VARCHAR(100)  NOT NULL,
 MODIFY COLUMN `thumbnail_uri` VARCHAR(200)  NOT NULL,
 MODIFY COLUMN `source` ENUM('Youtube','Red5')  NOT NULL,
 MODIFY COLUMN `character_name` VARCHAR(45)  NOT NULL;

ALTER TABLE `babeliumproject`.`spinvox_request` CHARACTER SET utf8;
ALTER TABLE `babeliumproject`.`spinvox_request` 
 MODIFY COLUMN `x_error` VARCHAR(45)  NOT NULL,
 MODIFY COLUMN `url` VARCHAR(200) ;

ALTER TABLE `babeliumproject`.`subtitle` CHARACTER SET utf8;
ALTER TABLE `babeliumproject`.`subtitle` 
 MODIFY COLUMN `language` VARCHAR(45)  NOT NULL,
 MODIFY COLUMN `translation` TINYINT(1)  NOT NULL DEFAULT 0,
 MODIFY COLUMN `adding_date` TIMESTAMP  NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;


ALTER TABLE `babeliumproject`.`subtitle_line` CHARACTER SET utf8;
ALTER TABLE `babeliumproject`.`subtitle_line` MODIFY COLUMN `text` VARCHAR(80)  NOT NULL;

ALTER TABLE `babeliumproject`.`subtitle_score` CHARACTER SET utf8;

ALTER TABLE `babeliumproject`.`transcription` CHARACTER SET utf8;
ALTER TABLE `babeliumproject`.`transcription` 
 MODIFY COLUMN `status` VARCHAR(45)  NOT NULL,
 MODIFY COLUMN `transcription` TEXT ,
 MODIFY COLUMN `system` VARCHAR(45)  NOT NULL;

ALTER TABLE `babeliumproject`.`user_languages` CHARACTER SET utf8;
ALTER TABLE `babeliumproject`.`user_languages` MODIFY COLUMN `language` VARCHAR(45)  NOT NULL;

ALTER TABLE `babeliumproject`.`users` CHARACTER SET utf8;
ALTER TABLE `babeliumproject`.`users` 
 MODIFY COLUMN `name` VARCHAR(45)  NOT NULL,
 MODIFY COLUMN `password` VARCHAR(45)  NOT NULL,
 MODIFY COLUMN `email` VARCHAR(45)  NOT NULL,
 MODIFY COLUMN `realName` VARCHAR(45)  NOT NULL,
 MODIFY COLUMN `realSurname` VARCHAR(45)  NOT NULL,
 MODIFY COLUMN `activation_hash` VARCHAR(20)  NOT NULL;

INSERT INTO `exercise` (`name`, `description`, `source`, `language`, `fk_user_id`, `tags`, `title`, `thumbnail_uri`, `adding_date`, `duration`, `status`, `filehash`) VALUES
('4BU3y3nkB7c', 'Presentation', 'Red5', 'French', 1, 'french, talk', 'Presentation', '4BU3y3nkB7c.jpg', '2010-04-15 13:17:08', 31, 'Available', 'e52964a1d207b5014b778ceb1016da8b'),
('08s08c4o3El', 'Goenkale telesaileko zati bat', 'Red5', 'Basque', 1, 'euskara, goenkale', 'Goenkale Zatia I', '08s08c4o3El.jpg', '2010-04-15 13:18:14', 38, 'Available', 'f03a80496520e2d275cef027b69aa379'),
('iQ8pI4bFwQh', 'Goenkale telesaileko zatia', 'Red5', 'Basque', 1, 'euskara, goenkale', 'Goenkale Zatia II', 'iQ8pI4bFwQh.jpg', '2010-04-15 13:19:33', 110, 'Available', '632fbbf33993892b9794f1cc324cd8d1'),
('COSYB49sT1G', 'Frases sencillas de la vida cotidiana', 'Red5', 'Spanish', 1, 'frases, cotidianas', 'Español Latino Para Niños', 'COSYB49sT1G.jpg', '2010-04-15 13:21:45', 63, 'Available', '4878a56679f48167686adc80e267506f');




