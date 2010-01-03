-- phpMyAdmin SQL Dump
-- version 2.11.8.1deb1ubuntu0.1
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Sep 11, 2009 at 01:31 AM
-- Server version: 5.0.67
-- PHP Version: 5.2.6-2ubuntu4.3

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

--
-- Database: `babelia`
--

-- --------------------------------------------------------

--
-- Table structure for table `Bideoa`
--

CREATE TABLE IF NOT EXISTS `Bideoa` (
  `Kodea` varchar(15) NOT NULL,
  `Iraupena` varchar(10) NOT NULL,
  `ZailtasunMaila` varchar(15) default NULL,
  `HizkuntzaFk` varchar(15) NOT NULL,
  PRIMARY KEY  (`Kodea`),
  KEY `HizkuntzaFk` (`HizkuntzaFk`),
  KEY `HizkuntzaFk_2` (`HizkuntzaFk`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `Bideoa`
--

INSERT INTO `Bideoa` (`Kodea`, `Iraupena`, `ZailtasunMaila`, `HizkuntzaFk`) VALUES
('cue_cuatro', '10', NULL, 'Gaztelera'),
('DarkKnight', '127', NULL, 'Ingelesa'),
('IronMan', '149', NULL, 'Ingelesa'),
('kutsi9', '129', NULL, 'Euskara');

-- --------------------------------------------------------

--
-- Table structure for table `Epaiketa`
--

CREATE TABLE IF NOT EXISTS `Epaiketa` (
  `GrabaketaFk` varchar(15) NOT NULL,
  `ErabiltzaileFk` varchar(15) NOT NULL COMMENT 'Epaitzen hari den erabiltzailea',
  `Balorazioa` varchar(15) NOT NULL,
  `Iruzkinak` text NOT NULL,
  `Data` date default NULL COMMENT 'Epaiketa egin deneko data',
  `BideoIruzkina` varchar(50) default NULL,
  PRIMARY KEY  (`GrabaketaFk`,`ErabiltzaileFk`),
  KEY `ErabiltzaileFk` (`ErabiltzaileFk`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Erabiltzaileak grabaketa bat epaitzeko sorturiko taula';

--
-- Dumping data for table `Epaiketa`
--

INSERT INTO `Epaiketa` (`GrabaketaFk`, `ErabiltzaileFk`, `Balorazioa`, `Iruzkinak`, `Data`, `BideoIruzkina`) VALUES
('cue_cuatro', 'Jokin', 'Erdizka', 'Hortxe hortxe, gehiago saiatu', '2009-08-26', NULL),
('IronMan', 'ane', 'Ondo', 'Oso ondo, jarraitu horrela.', NULL, NULL),
('IronMan', 'esteban', 'Ondo', 'Ondo dago, segi horrela, oso lan ona egiten hari zara.', '2009-07-17', NULL),
('IronMan', 'Jokin', 'Gaizki', 'Oso gaizki, ez duzu ondo ahoskatzen, eta ez da ondo ulertzen esandakoa.', '2009-07-16', NULL),
('IronMan', 'josune', 'Erdizka', 'Ez dago gaizki, baina bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla.\r\n\r\nKontuz guzti horrekin.', '2009-07-17', NULL),
('kutsi9', 'esteban', 'Erdizka', 'Nahiko ondo dago, baina hobetu daiteke.', NULL, 'audio/audio-1242656002917.flv'),
('kutsi9', 'maider', 'Ondo', 'Hori da maixutasuna.', '2009-08-25', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `Erabiltzaile`
--

CREATE TABLE IF NOT EXISTS `Erabiltzaile` (
  `User` varchar(15) NOT NULL COMMENT 'Erabiltzaile izena',
  `Password` varchar(15) NOT NULL COMMENT 'Pasahitza',
  `Izena` varchar(15) default NULL,
  `Abizena` varchar(15) default NULL,
  `Mail` varchar(50) NOT NULL,
  PRIMARY KEY  (`User`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Erabiltzailearen datuak';

--
-- Dumping data for table `Erabiltzaile`
--

INSERT INTO `Erabiltzaile` (`User`, `Password`, `Izena`, `Abizena`, `Mail`) VALUES
('aitor', 'aitor', NULL, NULL, ''),
('andoni', 'andoni', 'Andoni', 'Correas', 'acorreas001@ehu.es'),
('ane', '2222', NULL, NULL, 'ane@ehu.es'),
('esteban', 'esteban', NULL, NULL, ''),
('Jokin', '1111', NULL, NULL, 'jokin@ehu.es'),
('josu', 'josu', '', NULL, ''),
('josune', 'josune', NULL, NULL, ''),
('maider', 'maider', NULL, NULL, '');

-- --------------------------------------------------------

--
-- Table structure for table `Grabaketa`
--

CREATE TABLE IF NOT EXISTS `Grabaketa` (
  `Id` varchar(15) NOT NULL,
  `Baloraturik` int(15) default NULL,
  `AukeratutakoPertsonaia` varchar(50) NOT NULL COMMENT 'Grabaketa egiterakoan, erabiltzaileak aukeratu duen pertsonaia',
  `ErabiltzaileFk` varchar(15) NOT NULL COMMENT 'Grabaketa egin duen erabiltzailea',
  `BideoaFk` varchar(15) NOT NULL COMMENT 'Zein den jatorrizko bideoa',
  PRIMARY KEY  (`Id`),
  KEY `ErabiltzaileFk` (`ErabiltzaileFk`),
  KEY `BideoaFk` (`BideoaFk`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `Grabaketa`
--

INSERT INTO `Grabaketa` (`Id`, `Baloraturik`, `AukeratutakoPertsonaia`, `ErabiltzaileFk`, `BideoaFk`) VALUES
('cue_cuatro', 2, 'tipo_gaztea', 'esteban', 'cue_cuatro'),
('IronMan', 4, 'koro', 'Jokin', 'IronMan'),
('kutsi9', 3, 'koro', 'andoni', 'kutsi9');

-- --------------------------------------------------------

--
-- Table structure for table `Hizkuntza`
--

CREATE TABLE IF NOT EXISTS `Hizkuntza` (
  `Izena` varchar(15) NOT NULL,
  PRIMARY KEY  (`Izena`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `Hizkuntza`
--

INSERT INTO `Hizkuntza` (`Izena`) VALUES
('Euskara'),
('Gaztelera'),
('Ingelesa');

--
-- Constraints for dumped tables
--

--
-- Constraints for table `Bideoa`
--
ALTER TABLE `Bideoa`
  ADD CONSTRAINT `Bideoa_ibfk_1` FOREIGN KEY (`HizkuntzaFk`) REFERENCES `Hizkuntza` (`Izena`);

--
-- Constraints for table `Epaiketa`
--
ALTER TABLE `Epaiketa`
  ADD CONSTRAINT `Epaiketa_ibfk_1` FOREIGN KEY (`GrabaketaFk`) REFERENCES `Grabaketa` (`Id`),
  ADD CONSTRAINT `Epaiketa_ibfk_2` FOREIGN KEY (`ErabiltzaileFk`) REFERENCES `Erabiltzaile` (`User`);

--
-- Constraints for table `Grabaketa`
--
ALTER TABLE `Grabaketa`
  ADD CONSTRAINT `Grabaketa_ibfk_1` FOREIGN KEY (`ErabiltzaileFk`) REFERENCES `Erabiltzaile` (`User`),
  ADD CONSTRAINT `Grabaketa_ibfk_2` FOREIGN KEY (`BideoaFk`) REFERENCES `Bideoa` (`Kodea`);


