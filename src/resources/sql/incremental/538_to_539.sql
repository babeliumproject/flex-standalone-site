CREATE OR REPLACE VIEW view_evaluation_pending
AS 
SELECT DISTINCT A.id as response_id, 
		A.file_identifier as response_name, 
                A.rating_amount as response_rating_amount, 
                A.character_name as response_character_name, 
		A.fk_subtitle_id as response_subtitle_id, 
		A.adding_date as response_adding_date, 
		A.source as response_source, 
 		A.thumbnail_uri as response_thumbnail, 
		A.duration as response_duration, 
		F.name as response_user_name,
		F.ID as response_user_id, 
		B.id as exercise_id,
		B.name as exercise_name,
		B.duration as exercise_duration,
		B.language as exercise_language, 
		B.thumbnail_uri as exercise_thumbnail,
		B.title as exercise_title,
		B.source as exercise_source
FROM (response AS A INNER JOIN exercise AS B on A.fk_exercise_id = B.id) 
     INNER JOIN users AS F on A.fk_user_id = F.ID 
     LEFT OUTER JOIN evaluation AS C on C.fk_response_id = A.id
WHERE B.status = 'Available' AND 
      A.is_private = 0 AND 
      A.rating_amount < (SELECT prefValue FROM preferences WHERE (prefName='trial.threshold'));

CREATE OR REPLACE VIEW view_available_exercise
AS
SELECT e.id as exercise_id, 
       e.title as exercise_title, 
       e.description as exercise_description, 
       e.language as exercise_language, 
       e.tags as exercise_tags, 
       e.source as exercise_source,
       e.name as exercise_name,
       e.thumbnail_uri as exercise_thumbnail,
       e.adding_date as exercise_adding_date, 
       e.fk_user_id as exercise_user_id, 
       e.duration as exercise_duration, 
       u.name as exercise_user_name, 
       avg(suggested_score) as exercise_avg_score, 
       avg (suggested_level) as exercise_avg_level, 
       e.status as exercise_status,
       e.license as exercise_license, 
       e.reference as exercise_reference
FROM exercise e INNER JOIN users u ON e.fk_user_id= u.ID
     LEFT OUTER JOIN exercise_score s ON e.id=s.fk_exercise_id
     LEFT OUTER JOIN exercise_level l ON e.id=l.fk_exercise_id
WHERE (e.status = 'Available')
GROUP BY e.id
ORDER BY e.adding_date DESC;

UPDATE `preferences` SET `prefValue` =  '$Revision: 539 $'  WHERE `preferences`.`prefName` = 'dbrevision';
