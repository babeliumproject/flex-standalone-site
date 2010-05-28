UPDATE exercise SET language='es_ES' WHERE language='Spanish';
UPDATE exercise SET language='fr_FR' WHERE language='French';
UPDATE exercise SET language='eu_ES' WHERE language='Basque';
UPDATE exercise SET language='en_US' WHERE language='English';

UPDATE subtitle SET language='es_ES' WHERE language='Spanish';
UPDATE subtitle SET language='fr_FR' WHERE language='French';
UPDATE subtitle SET language='eu_ES' WHERE language='Basque';
UPDATE subtitle SET language='en_US' WHERE language='English';

UPDATE response SET thumbnail_uri = 'nothumb.png' WHERE thumbnail_uri = 'noVideo';

UPDATE response SET `thumbnail_uri`=REPLACE(`thumbnail_uri`,'audio/','');
UPDATE response SET `file_identifier`=REPLACE(`file_identifier`,'audio/','');

ALTER TABLE `response` MODIFY COLUMN `thumbnail_uri` VARCHAR(200)  CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'nothumb.png';
ALTER TABLE `evaluation_video` MODIFY COLUMN `thumbnail_uri` VARCHAR(200)  CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'nothumb.png';



--NOTE: Use a script to move Red5's video files to these new folders

DELETE FROM preferences WHERE prefName = 'exerciseFolder' OR prefName='evaluationFolder' OR prefName='responseFolder';

INSERT INTO preferences (prefName, prefValue) VALUES 
('exerciseFolder', 'exercises'),
('evaluationFolder','evaluations'),
('responseFolder','responses');

DELETE FROM preferences WHERE prefName = 'videoCommentPath';
