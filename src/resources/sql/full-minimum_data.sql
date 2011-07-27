--
-- Dumping data for table `preferences`
--

LOCK TABLES `preferences` WRITE;
/*!40000 ALTER TABLE `preferences` DISABLE KEYS */;
INSERT INTO `preferences` (`id`,`prefName`,`prefValue`) VALUES 
(1,'initialCredits','40'),
(2,'subtitleAdditionCredits','4'),
(3,'evaluationRequestCredits','10'),
(4,'evaluatedWithVideoCredits','20'),
(5,'videoSuggestCredits','2'),
(6,'dailyLoginCredits','0.5'),
(7,'evaluatedWithCommentCredits','1.5'),
(8,'evaluatedWithScoreCredits','20'),
(9,'subtitleTranslationCredits','1.5'),
(10,'uploadExerciseCredits','16'),
(11,'dbrevision','$Revision: 707 $'),
(12,'appRevision','3'),
(13,'trial.threshold','3'),
(14,'hashLength','20'),
(15,'hashChars','abcdefghijklmnopqrstuvwxyz0123456789-_'),
(18,'spinvox.language','en'),
(22,'spinvox.protocol','https'),
(24,'spinvox.port','443'),
(25,'spinvox.dev_url','dev.api.spinvox.com'),
(26,'spinvox.live_url','live.api.spinvox.com'),
(27,'spinvox.max_transcriptions','10'),
(28,'spinvox.max_requests','50'),
(31,'spinvox.max_duration','30'),
(32,'spinvox.dev_mode','true'),
(34,'positives_to_next_level','15'),
(35,'reports_to_delete','10'),
(38,'bwCheckMin','512'),
(39,'exerciseFolder','exercises'),
(40,'evaluationFolder','evaluations'),
(41,'responseFolder','responses'),
(42,'spinvox.language','fr'),
(43,'spinvox.language','de'),
(44,'spinvox.language','it'),
(45,'spinvox.language','pt'),
(46,'spinvox.language','es'),
(47,'minVideoRatingCount','10'),
(48,'reportCredit','2'),
(49,'web_domain','babelia'),
(50,'minExerciseDuration',15),
(51,'maxExerciseDuration',120),
(52,'minVideoEvalDuration',5),
(53,'maxFileSize',188743680);
/*!40000 ALTER TABLE `preferences` ENABLE KEYS */;
UNLOCK TABLES;
