CREATE TABLE xtns_by_card_day (
  card_no int NOT NULL,
  date date NOT NULL,
  price double,
  xtns decimal(32,0),
  PRIMARY KEY (card_no, date)
)
;