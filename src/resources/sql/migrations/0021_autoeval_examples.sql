--
-- Volcar la base de datos para la tabla `transcription`
--

INSERT INTO `transcription` VALUES (1, '2009-10-20 16:24:59', 'pending', NULL, NULL, 'spinvox');
INSERT INTO `transcription` VALUES (2, '2009-10-20 16:24:59', 'pending', NULL, NULL, 'spinvox');


--
-- Volcar la base de datos para la tabla `exercise`
--

INSERT INTO `exercise` VALUES (16, 'english_long', 'english lessons', 'Red5', 'English', 1, 'english', 'English lessons', 'http://i1.ytimg.com/vi/xoXMSAtJ0og/default.jpg', '2009-10-22 18:00:00', 59, NULL);
INSERT INTO `exercise` VALUES (17, 'english', 'english lessons', 'Red5', 'English', 1, 'english', 'English lessons short', 'http://i1.ytimg.com/vi/xoXMSAtJ0og/default.jpg', '2009-10-22 18:00:00', 12, 1);


--
-- Volcar la base de datos para la tabla `response`
--

INSERT INTO `response` VALUES (4, 1, 17, 'english', 0, 'http://i1.ytimg.com/vi/xoXMSAtJ0og/default.jpg', 'Red5', 12, '2009-10-22 18:00:00', 0, 'neska', 2);


--
-- Volcar la base de datos para la tabla `evaluation`
--

INSERT INTO `evaluation` VALUES (6, 4, 3, 2, NULL, '2009-09-29');
