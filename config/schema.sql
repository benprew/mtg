-- CREATE DATABASE mtg DEFAULT CHARSET utf8;
-- grant all on mtg.* to 'mtg'@'localhost' identified by <password-in-plain-text>

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

DROP TABLE IF EXISTS `possible_matches`;

CREATE TABLE `possible_matches` (
  `external_item_id` varchar(50) NOT NULL,
  `card_no` integer NOT NULL,
  `score` float NOT NULL,
  PRIMARY KEY (`external_item_id`,`card_no`)
);

DROP TABLE IF EXISTS `external_items`;

CREATE TABLE `external_items` (
  `external_item_id` varchar(50) NOT NULL,
  `description` varchar(512) DEFAULT NULL,
  `end_time` datetime DEFAULT NULL,
  `auction_price` float DEFAULT NULL,
  `buy_it_now_price` float DEFAULT NULL,
  `card_no` integer DEFAULT NULL,
  `last_updated` datetime NOT NULL,
  `cards_in_item` integer NOT NULL DEFAULT '1',
  `price` float DEFAULT NULL,
  `has_been_finalized` tinyint(4) DEFAULT '0',
  `has_match_been_attempted` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`external_item_id`)
);



