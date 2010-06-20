UPDATE `preferences` SET `prefValue` =  'en'  WHERE `preferences`.`prefName` = 'spinvox.language';

INSERT INTO `preferences` (`prefName`, `prefValue`) VALUES
('spinvox.language', 'fr'),
('spinvox.language', 'de'),
('spinvox.language', 'it'),
('spinvox.language', 'pt'),
('spinvox.language', 'es');
