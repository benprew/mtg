DROP TABLE IF EXISTS `xtns_by_card_day`;

CREATE TABLE xtns_by_card_day (
  card_no int NOT NULL,
  date date NOT NULL,
  price double,
  xtns integer,
  PRIMARY KEY (card_no, date)
);

DROP TABLE IF EXISTS `cards`;

CREATE TABLE `cards` (
  `card_no` integer not null,
  `name` varchar(50) default NULL,
  `casting_cost` varchar(50) default NULL,
  `type` varchar(50) default NULL,
  `rarity` varchar(50) default NULL,
  `set_name` varchar(50) default NULL,
  `rules_text` varchar(1024) default NULL,
  `pow_tgh` varchar(50) default NULL,
  `collector_no` int(11) default NULL,
  PRIMARY KEY  (`card_no`)
);

