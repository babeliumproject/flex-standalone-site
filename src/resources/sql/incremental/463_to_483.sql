CREATE TABLE IF NOT EXISTS `tagcloud` (
  `tag` varchar(100) NOT NULL,
  `amount` INT(10) UNSIGNED NOT NULL,
  PRIMARY KEY (`tag`)
  )
ENGINE = InnoDB
DEFAULT CHARSET=utf8;

INSERT INTO `tagcloud` (`tag`, `amount`) VALUES
('mafiosos', 7),
('english', 7),
('french', 5),
('moto', 5),
('motos', 5),
('oficina', 3),
('carrera', 3),
('perros', 3),
('carreta', 3),
('esparragos', 3),
('friends', 3),
('tomates', 3),
('guisantes', 3),
('zanahorias', 3),
('lechugas', 3),
('puerros', 3),
('hortalizas', 3),
('frescas', 3),
('tostadas', 3),
('torta', 3),
('tortilla', 3),
('huevos', 3),
('fritanga', 3),
('mono', 3),
('toro', 3),
('caballo', 3),
('cerdo', 3),
('serie', 1);