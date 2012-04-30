SET FOREIGN_KEY_CHECKS = 0;

--
-- Dumping data for table `exercise`
--

LOCK TABLES `exercise` WRITE;
/*!40000 ALTER TABLE `exercise` DISABLE KEYS */;
INSERT INTO `exercise` VALUES 
(1,'tdes_1065_qa','Repeat phrases and then talk to Sarah','Red5','en_US',1,'daily, english, show','The Daily English Show #1065 Fragment','tdes_1065_qa.jpg','2010-03-08 12:10:00',43,'Available','161abc5e831c545305f55f4139fd4799',NULL,'cc-by','http://www.thedailyenglishshow.com'),
(2,'tdes_1170_qa','Repeat phrases and then talk to Sarah','Red5','en_US',1,'daily, english, show','The Daily English Show #1170 Fragment','tdes_1170_qa.jpg','2010-03-08 12:10:00',52,'Available','38b99457f8cd8af5b56728c5e2f0485b',NULL,'cc-by','http://www.thedailyenglishshow.com'),
(3,'tdes_1179_qa','Repeat phrases and then talk to Sarah','Red5','en_US',1,'daily, english, show','The Daily English Show #1179 Fragment','tdes_1179_qa.jpg','2010-03-08 12:10:00',30,'Available','4fe59e622c208b53dc4e61cfdcb7b2a8',NULL,'cc-by','http://www.thedailyenglishshow.com'),
(4,'tdes_1183_qa','Repeat phrases and then talk to Sarah','Red5','en_US',1,'daily, english, show','The Daily English Show #1183 Fragment','tdes_1183_qa.jpg','2010-03-08 12:10:00',40,'Available','2f8d1bde45ae7a7d303d663bcdf2ae8c',NULL,'cc-by','http://www.thedailyenglishshow.com'),
(5,'tdes_1187_qa','Repeat phrases and then talk to Sarah','Red5','en_US',1,'daily, english, show','The Daily English Show #1187 Fragment','tdes_1187_qa.jpg','2010-03-08 12:10:00',57,'Available','a0cd07a3ac94d2dbf77ca1c02c6278cc',NULL,'cc-by','http://www.thedailyenglishshow.com');
/*!40000 ALTER TABLE `exercise` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `exercise_level`
--

LOCK TABLES `exercise_level` WRITE;
/*!40000 ALTER TABLE `exercise_level` DISABLE KEYS */;
INSERT INTO `exercise_level` VALUES 
(0,1,1,4,'2010-07-29 17:49:46'),
(0,2,1,4,'2010-07-29 17:49:46'),
(0,3,1,4,'2010-07-29 17:49:46'),
(0,4,1,4,'2010-07-29 17:49:46'),
(0,5,1,4,'2010-07-29 17:49:46');
/*!40000 ALTER TABLE `exercise_level` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `exercise_role`
--

LOCK TABLES `exercise_role` WRITE;
/*!40000 ALTER TABLE `exercise_role` DISABLE KEYS */;
INSERT INTO `exercise_role` VALUES 
(1,6,1,'NPC'),
(2,6,1,'Yourself'),
(3,7,1,'NPC'),
(4,7,1,'Yourself'),
(5,8,1,'NPC'),
(6,8,1,'Yourself'),
(7,9,1,'NPC'),
(8,9,1,'Yourself'),
(9,23,1,'NPC'),
(10,23,1,'Yourself');
/*!40000 ALTER TABLE `exercise_role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `motd`
--

LOCK TABLES `motd` WRITE;
/*!40000 ALTER TABLE `motd` DISABLE KEYS */;
INSERT INTO `motd` VALUES 
(0,'Record a video-exercise  as many times as you want','After recording a video-exercise you can watch or redo it again  before publishing it?\rJust click the Watch Simultaneously or Watch Response button. Whenever you are confident\rwith your work,  click “Save Response” Button in order to be evaluated.','/img/motd1.png','2010-10-01 00:00:00',0,'1','en_US'),
(0,'Did you know that you can dub your favourite actor','or actress? Do you feel lucky, punk?','/img/motd2.png','2010-10-04 00:00:00',0,'2','en_US'),
(0,'Did you know that you can report an inappropiate video?','Users can report inappropiate videos, choosing the reason for banning among a frequently used reasons list.','/img/motd3.png','2010-10-03 00:00:00',0,'3','en_US'),
(0,'Did you know that you can follow us on Twitter?','Just follow the @babelium user','/img/motd6.png','2010-10-05 00:00:00',0,'4','en_US');
/*!40000 ALTER TABLE `motd` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `subtitle`
--

LOCK TABLES `subtitle` WRITE;
/*!40000 ALTER TABLE `subtitle` DISABLE KEYS */;
INSERT INTO `subtitle` VALUES 
(1,1,1,'en_US',0,'2010-06-04 23:23:11',1),
(2,2,1,'en_US',0,'2010-06-04 23:23:11',1),
(3,3,1,'en_US',0,'2010-06-04 23:23:11',1),
(4,4,1,'en_US',0,'2010-06-04 23:23:11',1),
(5,5,1,'en_US',0,'2010-06-04 23:23:11',1);
/*!40000 ALTER TABLE `subtitle` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `subtitle_line`
--

LOCK TABLES `subtitle_line` WRITE;
/*!40000 ALTER TABLE `subtitle_line` DISABLE KEYS */;
INSERT INTO `subtitle_line` VALUES
(0,1,0.3,1.2,'What\'s that?',9),
(0,1,1.4,2.9,'What\'s that?',10),
(0,1,3.1,5.22,'Can\'t you just use your sleeve?',9),
(0,1,5.42,8.2,'Can\'t you just use your sleeve?',10),
(0,1,8.4,9.23,'Who gave it to you?',9),
(0,1,9.43,11.5,'Who gave it to you?',10),
(0,1,11.7,14.31,'Look I got a present',9),
(0,1,14.51,15.6,'What\'s that?',10),
(0,1,15.8,18.52,'It\'s a \"keitai kurina\".',9),
(0,1,18.72,19.6,'What\'s that?',10),
(0,1,19.8,28.51,'Well, \"keitai\" means cellphone and this has material on the back of it and it\'s for cleaning your cellphone screen.',9),
(0,1,28.71,30.9,'Can\'t you just use your sleeve?',10),
(0,1,31.1,32.83,'Well, yeah, but...',9),
(0,1,33.03,34.3,'Who gave it to you?',10),
(0,1,34.5,43,'Ah, NHK... They made a new website, and they used a few seconds of one of my videos so they sent me this.',9),
 
(0,2,0.3,2.307,'Oh, it\'s going that well, huh?',1),
(0,2,2.507,4.9,'Oh, it\'s going that well, huh?',2),
(0,2,5.1,8.023,'When do I get to meet the phantom physician?',1),
(0,2,8.223,10.7,'When do I get to meet the phantom physician?',2),
(0,2,10.9,12.205,'You guys got plans tonight?',1),
(0,2,12.405,13.9,'You guys got plans tonight?',2),
(0,2,14.1,15.41,'You know what you should do?',1),
(0,2,15.61,17,'You know what you should do?',2),
(0,2,17.2,19.321,'You should fly up and surprise him.',1),
(0,2,19.521,21.9,'You should fly up and surprise him.',2),
(0,2,22.1,23.232,'Yeah, why not?',1),
(0,2,23.432,25,'Yeah, why not?',2),
(0,2,25.2,26.716,'He\'s just the first decent guy I dated in a long time.',1),
(0,2,26.916,31.2,'Oh, it\'s going that well, huh?',2),
(0,2,31.4,34.831,'I\'m so sick of dating. I\'m so jealous of you guys.',1),
(0,2,35.031,37.6,'When do I get to meet the phantom physician?',2),
(0,2,37.8,38.608,'I think soon.',11),
(0,2,38.808,40.7,'You guys got plans tonight?',12),
(0,2,40.9,45.828,'No, nothing. Just... he has to go to San Francisco so we\'re gonna talk on the phone',1),
(0,2,46.028,49.9,'You know what you should do? You should fly up and surprise him.',2),
(0,2,50.1,50.808,'You think so?',1),
(0,2,51.008,52.4,'Yeah, why not?',2),

(0,3,0.3,1.605,'OK, now what?',3),
(0,3,1.805,3.1,'OK, now what?',4),
(0,3,3.3,5.917,'OK, that\'s fair. On three?',3),
(0,3,6.117,7.6,'OK, that\'s fair. On three?',4),
(0,3,7.8,10.129,'One, two, three.',3),
(0,3,10.329,12.1,'One, two, three.',4),
(0,3,12.3,13.505,'I threw paper!',3),
(0,3,13.705,15.1,'I threw paper!',4),
(0,3,17.114,17.7,'OK, now what?',4),
(0,3,17.9,19.722,'Rock-paper-scissors for it',3),
(0,3,19.922,21.6,'OK, that\'s fair. On three?',4),
(0,3,21.8,23.031,'Yeah.',3),
(0,3,23.231,27.51,'One, two, three.',4),
(0,3,27.71,28.7,'I threw paper!',4),
(0,3,28.9,29.3,'I threw a rock!',3),

(0,4,0.3,1.806,'How was your day?',5),
(0,4,2.006,3.1,'How was your day?',6),
(0,4,3.3,4.012,'What about?',5),
(0,4,4.212,5.3,'What about?',6),
(0,4,5.5,6.92,'What\'s gonna happen to it?',5),
(0,4,7.12,9,'What\'s gonna happen to it?',6),
(0,4,9.2,10.831,'So they\'re gonna get rid of it?',5),
(0,4,11.031,13.7,'So they\'re gonna get rid of it?',6),
(0,4,14.507,16.1,'How was your day?',6),
(0,4,16.3,19.923,'Good! I went to a protest this afternoon',5),
(0,4,20.123,21.2,'What about?',16),
(0,4,21.4,26.106,'It was about protecting national public service radio broadcasting',5),
(0,4,26.306,27.9,'What\'s gonna happen to it?',6),
(0,4,28.1,31.923,'Well... the government wants to save money...',5),
(0,4,32.123,33.3,'So they\'re gonna get rid of it?',6),
(0,4,33.5,39.8,'Not quite, but they suggested stuff like introducing advertising, which would really suck',5),

(0,5,0.3,2.006,'What are you up to this weekend?',7),
(0,5,2.206,3.6,'What are you up to this weekend?',8),
(0,5,3.8,4.613,'Where\'s that?',17),(88,9,4.813,5.8,'Where\'s that?',8),
(0,5,6,8.123,'Oh yeah, I know where the Albert Park is.',7),
(0,5,8.323,10.8,'Oh yeah, I know where the Albert Park is.',8),
(0,5,11,13.906,'That\'s were the lantern festival was last week.',7),
(0,5,14.106,17.4,'That\'s were the lantern festival was last week.',8),
(0,5,17.6,19.12,'Yeah, did you?',7),
(0,5,19.32,20.8,'Yeah, did you?',8),
(0,5,21,23.7,'Yeah. What day did you go?',7),
(0,5,23.9,26.5,'Yeah. What day did you go?',8),
(0,5,27.309,29.1,'What are you up to this weekend?',8),
(0,5,29.3,34.229,'Ah, I\'m not sure yet. I might go and check out the concert on sunday.',7),
(0,5,34.429,35.5,'Where\'s that?',8),
(0,5,35.7,39.611,'It\'s in Albert Park which is the park near the university.',7),
(0,5,39.811,45.2,'Oh yeah, I know where the Albert Park is. That\'s were the lantern festival was l',8),
(0,5,45.4,48.201,'Yeah that\'s the one. Did you go to that festival?',7),
(0,5,48.401,49.6,'Yeah, did you?',8),
(0,5,49.8,52.012,'Yeah, it was awesome, wasn\'t it?',7),
(0,5,52.212,53.8,'Yeah. What day did you go?',8),
(0,5,54,57.1,'Am, Sunday I think it was. Yeah, yeah, Sunday night.',7);
/*!40000 ALTER TABLE `subtitle_line` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `user_languages`
--

LOCK TABLES `user_languages` WRITE;
/*!40000 ALTER TABLE `user_languages` DISABLE KEYS */;
INSERT INTO `user_languages` VALUES
(0,1,'es_ES',7,15,'evaluate'),
(0,1,'en_US',5,15,'practice'),
(0,2,'en_US',7,15,'evaluate'),
(0,2,'es_ES',5,15,'practice');
/*!40000 ALTER TABLE `user_languages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `users`
--
-- Password for example users are the same as username u: guest1/p: guest1
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES 
(1,'guest1','1144e9791066fcc2f911108616deb91e09458c37','guest1@mailinator.com','Guest1','',200,'2009-07-02 12:30:00',1,'',0),
(2,'guest2','ea4a2ae4287d89d58ca0ff6f475c4dacca456e3b','guest2@mailinator.com','Guest2','',200,'2009-07-02 12:30:00',0,'',0);

SET FOREIGN_KEY_CHECKS = 1;
