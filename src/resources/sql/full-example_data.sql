--
-- EXAMPLE DATA
-- Passwords for example users are the same as username u: guest1/p: guest1
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES 
(1,'guest1','1144e9791066fcc2f911108616deb91e09458c37','guest1@mailinator.com','Guest1','One',200,'2009-07-02 12:30:00',1,'',0),
(2,'guest2','ea4a2ae4287d89d58ca0ff6f475c4dacca456e3b','guest2@mailinator.com','Guest','Two',200,'2009-07-02 12:30:00',0,'',0);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;


LOCK TABLES `user_languages` WRITE;
/*!40000 ALTER TABLE `user_languages` DISABLE KEYS */;
INSERT INTO `user_languages` VALUES
(0,1,'es_ES',7,15,'evaluate'),
(0,1,'en_US',5,15,'practice'),
(0,2,'en_US',7,15,'evaluate'),
(0,2,'es_ES',5,15,'practice');
/*!40000 ALTER TABLE `user_languages` ENABLE KEYS */;
UNLOCK TABLES;

