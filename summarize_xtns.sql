DELETE FROM xtns;

INSERT INTO xtns
  SELECT card_no, date(end_time), external_item_id, auction_price, 'AUCTION'
  FROM external_items
  WHERE card_no IS NOT NULL
;