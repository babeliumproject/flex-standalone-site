-- phpMyAdmin SQL Dump
-- version 3.1.3
-- http://www.phpmyadmin.net
--
-- Servidor: sids01.si.ehu.es
-- Tiempo de generación: 30-09-2009 a las 16:12:49
-- Versión del servidor: 5.0.67
-- Versión de PHP: 5.2.6-2ubuntu4.3

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

SET FOREIGN_KEY_CHECKS = 0;


--
-- Base de datos: `mydb`
--

--
-- Volcar la base de datos para la tabla `credithistory`
--

INSERT INTO `credithistory` (`id`, `fk_user_id`, `fk_exercise_id`, `fk_response_id`, `fk_eval_id`, `changeDate`, `changeType`, `changeAmount`) VALUES
(1, 2, 2, NULL, 0, '2009-08-07 13:43:48', 'subtitling', 2),
(2, 1, 2, NULL, 0, '2009-08-07 13:54:11', 'subtitling', 2),
(3, 1, 2, 22, 0, '2009-08-07 14:01:35', 'eval_request', -2),
(4, 1, 2, 23, 0, '2009-08-07 14:06:28', 'eval_request', -2),
(5, 1, 2, 24, 0, '2009-08-08 19:10:34', 'eval_request', -2),
(6, 1, 2, 26, 0, '2009-08-15 00:58:09', 'eval_request', -2),
(7, 2, 2, 29, 0, '2009-08-20 01:21:27', 'eval_request', -2),
(8, 5, 2, 30, 0, '2009-08-20 01:53:46', 'eval_request', -2),
(9, 3, 2, 31, 0, '2009-08-20 01:54:49', 'eval_request', -2),
(10, 3, 2, 32, 0, '2009-08-20 01:59:47', 'eval_request', -2),
(11, 3, 2, 42, 0, '2009-08-23 16:57:46', 'eval_request', -2),
(12, 3, 2, 43, 0, '2009-08-21 12:03:31', 'eval_request', -2),
(13, 1, 2, 44, 0, '2009-08-26 18:07:56', 'eval_request', -2),
(14, 2, 2, 45, 0, '2009-08-30 18:32:39', 'eval_request', -2),
(15, 1, 2, 46, 0, '2009-09-01 00:45:34', 'eval_request', -2),
(20, 1, 2, NULL, NULL, '2009-09-04 20:56:31', 'subtitling', -2),
(22, 1, 2, NULL, NULL, '2009-09-04 21:09:51', 'subtitling', -2),
(24, 3, 2, NULL, NULL, '2009-09-04 21:51:36', 'subtitling', -2),
(25, 3, 15, NULL, NULL, '2009-09-04 21:57:18', 'exercise_upload', 2),
(27, 1, 2, NULL, NULL, '2009-09-07 15:14:04', 'subtitling', -2);

--
-- Volcar la base de datos para la tabla `evaluation`
--

INSERT INTO `evaluation` (`id`, `fk_response_id`, `fk_user_id`, `score`, `comment`, `adding_date`) VALUES
(1, 1, 2, 2, 'ddssaa', '2009-09-30'),
(2, 2, 3, 4, 'Oso ondo', '2009-09-29'),
(3, 3, 3, 2, 'Hori da', '2009-09-29'),
(4, 1, 3, 5, 'Perfekto', '2009-09-30'),
(5, 1, 5, 1, 'Nahiko kaxkar', '2009-09-29');

--
-- Volcar la base de datos para la tabla `evaluation_video`
--

INSERT INTO `evaluation_video` (`id`, `fk_evaluation_id`, `video_identifier`, `source`, `thumbnail_uri`, `duration`) VALUES
(1, 5, 'audio-1242656002917', 'Red5', '', 34);

--
-- Volcar la base de datos para la tabla `exercise`
--

INSERT INTO `exercise` (`id`, `name`, `description`, `source`, `language`, `fk_user_id`, `tags`, `title`, `thumbnail_uri`, `adding_date`, `duration`) VALUES
(1, 'kutsi9', 'Kutsidazu bidea ixabel filmeko zatia', 'Red5', 'Basque', 1, 'euskaltegia, berri', 'Kutsidazu bidea ixabel', 'http://sids01.si.ehu.es/thumbs/kutsi9.jpg', '2009-09-01 00:24:04', 21),
(2, 'cue_cuatro', 'Escena de serie', 'Red5', 'Spanish', 1, 'cuatro, serie', 'Extracto serie', '/resources/images/thumbs/cue_cuatro.jpg', '2009-09-01 00:24:04', 34),
(3, 'cue_cuatro2', 'Escena de serie 2', 'Red5', 'Spanish', 1, 'cuatro, serie', 'Extracto serie 2', '/resources/images/thumbs/cue_cuatro2.jpg', '2009-09-01 00:24:04', 55),
(4, 'cue_cuatro3', 'Escena de serie 3', 'Red5', 'Spanish', 1, 'cuatro, serie', 'Extracto serie 3', '/resources/images/thumbs/cue_cuatro3.jpg', '2009-09-01 00:24:04', 33),
(12, '9', 'Tim Burton''s latest animation movie is here. It''s name is nine, and speaks about 9 creations.', 'Red5', 'English', 3, 'tim, burton, movie, trailer', '9 Movie Trailer', 'http://img.youtube.com/vi/OnoJecu9e7c/default.jpg', '2009-09-04 20:12:34', 12),
(15, 'A974tvk13mM', 'Relaxing video with a waterfall', 'Youtube', 'English', 3, 'water, relax', 'Water video', 'http://img.youtube.com/vi/A974tvk13mM/1.jpg', '2009-09-04 21:57:18', 21);

--
-- Volcar la base de datos para la tabla `exercise_comment`
--


--
-- Volcar la base de datos para la tabla `exercise_level`
--


--
-- Volcar la base de datos para la tabla `exercise_role`
--
INSERT INTO `exercise_role` (`fk_exercise_id`, `fk_user_id`, `character_name`) VALUES
(2,1,'Prueba exercise_id 2'),
(2,1,'Pepito'),
(2,1,'Greimito'),
(2,1,'Aitor'),
(2,1,'Xabier'),
(1,1,'Joxetxo'),
(1,1,'Coco1'),
(1,1,'Coco2'),
(1,1,'Coco3'),
(1,1,'Coco4'),
(1,1,'Coco5'),
(1,1,'Coco6');


--
-- Volcar la base de datos para la tabla `exercise_score`
--

INSERT INTO `exercise_score` (`id`, `fk_exercise_id`, `fk_user_id`, `suggested_score`, `suggestion_date`) VALUES
(1, 1, 1, 3, '2009-09-03 02:41:43'),
(2, 1, 1, 2, '2009-09-03 02:41:43'),
(3, 1, 2, 4, '2009-09-03 02:41:43'),
(4, 1, 3, 1, '2009-09-03 02:41:43');

--
-- Volcar la base de datos para la tabla `grabaciones`
--


--
-- Volcar la base de datos para la tabla `preferences`
--

INSERT INTO `preferences` (`prefName`, `prefValue`) VALUES
('initialCredits', 15),
('subtitleAdditionCredits', 2),
('evaluationRequestCredits', 2),
('evaluatedWithVideoCredits', 2),
('videoSuggestCredits', 2),
('dailyLoginCredits', 0.5),
('evaluatedWithCommentCredits', 1.5),
('evaluatedWithScoreCredits', 0.5),
('subtitleTranslationCredits', 1.5),
('uploadExerciseCredits', 2),
('trial.threshold', 10);

--
-- Volcar la base de datos para la tabla `response`
--

INSERT INTO `response` (`id`, `fk_user_id`, `fk_exercise_id`, `file_identifier`, `is_private`, `thumbnail_uri`, `source`, `duration`, `adding_date`, `rating_amount`, `character_name`) VALUES
(1, 1, 2, 'cue_cuatro', 0, '', 'Red5', 23, '2009-09-20 11:01:21', 2, 'tipo_zaharra'),
(2, 1, 1, 'kutsi9', 0, '', 'Red5', 11, '2009-09-20 11:40:03', 2, 'koro'),
(3, 3, 2, 'cue_cuatro', 0, '', 'Red5', 23, '2009-09-22 12:07:34', 3, 'tipo_gaztea');

--
-- Volcar la base de datos para la tabla `subtitle`
--

INSERT INTO `subtitle` (`id`, `fk_exercise_id`, `fk_user_id`, `language`, `translation`, `adding_date`) VALUES
(1, 2, 2, 'Spanish', 0, '2009-09-10 13:52:37'),
(2, 2, 1, 'Basque', 1, '2009-09-10 13:52:37'),
(3, 2, 3, 'English', 1, '2009-09-10 13:52:37');

--
-- Volcar la base de datos para la tabla `subtitle_line`
--

INSERT INTO `subtitle_line` (`id`, `fk_subtitle_id`, `show_time`, `hide_time`, `text`, `fk_exercise_role_id`) VALUES
(1, 1, 1.6, 3.76, '?Por qu? quiere un boxeador trabajar en la construcci?n?', 1),
(2, 1, 4.96, 6.76, 'Est? arruinado, y no tiene trabajo y...', 2),
(3, 1, 6.92, 8, 'y quiere que le contrate...', 1),
(4, 1, 8.1, 9.4, 'Yo podr?a ense?arle a manejar la excavadora.', 2),
(5, 2, 1.6, 3.76, 'Zergatik nahi du boxeolari batek eraikuntzan lan egin?', 1),
(6, 2,  4.96, 6.76, 'Dirurik ez du, eta ez lanik ere...', 2),
(7, 2, 6.92, 8, 'eta nik kontratatzea nahi duzu...', 1),
(8, 2, 8.1, 9.4, 'Nik erakutsi niezaioke eskabadora erabiltzen.', 2),
(9, 3, 1.6, 3.76, 'Why a boxer wants to work in construction?', 1),
(10, 3,  4.96, 6.76, 'He is ruined, and doesn''t have a job', 2),
(11, 3, 6.92, 8, 'and you want me to hire him...', 1),
(12, 3, 8.1, 9.4, 'I could teach him to handle the excavator.', 2);

--
-- Volcar la base de datos para la tabla `subtitle_score`
--


--
-- Volcar la base de datos para la tabla `subtitulos`
--

INSERT INTO `subtitulos` (`ID_SUB`, `ID_VID`, `idioma`, `textos`, `tiempo`, `duracion`) VALUES
(10, 1, 'euskara', 'sasdasdasdasdasd', 2500, 1000),
(11, 1, 'euskara', 'dffdfdfdasdasas', 4200, 1000),
(15, 2, 'euskara', 'Zergatik boxeolari batek eraikuntzan lan egin nahi du?', 1700, 0),
(16, 2, 'euskara', 'Dirurik ez du, eta ezta lanik ere..', 3800, 0),
(17, 2, 'euskara', 'eta nik kontratatzea nahi duzu..', 6700, 0),
(18, 2, 'euskara', 'Nik erakutsi niezaioke "eskabadora" erabiltzen!', 7800, 0),
(19, 2, 'espa?ol', 'Porque quiere un boxeador trabajar en la construccion?', 1700, 0),
(20, 2, 'espa?ol', 'Esta arruinado, y no tiene trabajo y...', 3800, 0),
(21, 2, 'espa?ol', 'y quieres que le contrate..', 6700, 0),
(22, 2, 'espa?ol', 'Yo podria ense?arle a manejar la escavadora!', 7800, 0),
(23, 2, 'english', 'Why a boxer wants to work in construction?', 1700, 0),
(24, 2, 'english', 'He is ruined, and don?t have a job ...', 3800, 0),
(25, 2, 'english', 'and want to hire ..', 6700, 0),
(26, 2, 'english', 'I could teach him to handle the excavator!', 7800, 0);

--
-- Volcar la base de datos para la tabla `users`
--

INSERT INTO `users` (`ID`, `name`, `password`, `email`, `realName`, `realSurname`, `creditCount`) VALUES
(1, 'erab1', '4eff1c28f92bb604596e75d2c98bf7085ac685c4', 'erab1@gmail.com', 'erab1', 'erab1', 13),
(2, 'erab2', '4eff1c28f92bb604596e75d2c98bf7085ac685c4', 'erab2@gmail.com', 'erab2', 'erab2', 9),
(3, 'erab3', '4eff1c28f92bb604596e75d2c98bf7085ac685c4', 'erab3@gmail.com', 'erab3', 'erab3', 5),
(5, 'erab4', '4eff1c28f92bb604596e75d2c98bf7085ac685c4', 'erab4@gmail.com', 'erab4', 'erab4', 5);

--
-- Volcar la base de datos para la tabla `user_languages`
--


--
-- Volcar la base de datos para la tabla `videos`
--

INSERT INTO `videos` (`ID`, `nombre`, `desc`, `autor`, `fecha_envio`, `thumbnail`, `duracion`, `etiquetas`, `MetaInfBabelia_ID_VIDEO`, `Subtitulos_ID_SUB`) VALUES
(1, 'kutsi9', NULL, 'AEK', '2009-05-03 10:38:57', 'http://sids01.si.ehu.es:5080/thumbs/kutsi9.jpg', 123, 'asdasdsdas', 1, 10),
(2, 'cue_cuatro', NULL, 'CUATRO', '2009-05-03 10:38:49', 'http://sids01.si.ehu.es:5080/thumbs/cue_cuatro.jpg', 12322, 'sdfsdfsdf', 2, 11),
(3, 'cue_cuatro2', NULL, 'autorea2', '2009-05-03 11:24:07', 'ewrwrewer', 2345, 'asdasd', 1, 10),
(4, 'cue_cuatro3', NULL, 'autorea3', '2009-05-03 11:24:47', 'ewrwrewersadasd', 100034, 'asdasdsdas', 1, 11),
(5, 'cue_cuatro4', 'qweqwe', 'wwwqewe', '2009-05-03 11:25:18', 'ewrwrewersadasd', 12356, 'asdasdsdas', 2, 11);

SET FOREIGN_KEY_CHECKS = 1;
