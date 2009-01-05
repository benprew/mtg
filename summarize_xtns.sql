DELETE FROM xtns;

INSERT INTO xtns
  SELECT card_no, date(end_time), external_item_id, price, 'AUCTION', cards_in_item
  FROM external_items
  WHERE card_no IS NOT NULL AND price IS NOT NULL
;
