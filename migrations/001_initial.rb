class Initial < Sequel::Migration
  def up
    create_table(:card_prices) do
      foreign_key :card_id, :cards
      Float :price
    end
    
    create_table(:cards, :ignore_index_errors=>true) do
      primary_key :id
      String :name, :size=>50
      String :casting_cost, :size=>50
      String :type, :size=>50
      String :rarity, :size=>50
      String :set_name, :size=>50
      String :rules_text, :size=>1024
      String :pow_tgh, :size=>50
      Integer :collector_no
      
      foreign_key :cardset_id, :cardsets
    end
    
    create_table(:cardsets, :ignore_index_errors=>true) do
      primary_key :id
      String :name, :size=>255
      String :cardset_import_id, :size=>255
      Date :release_date
      
      index [:cardset_import_id], :unique=>true, :name=>:cardset_import_id
      index [:name], :unique=>true, :name=>:name
    end
    
    create_table(:external_items, :ignore_index_errors=>true) do
      String :external_item_id, :null=>false, :size=>50
      String :description, :size=>512
      DateTime :end_time
      Float :auction_price
      Float :buy_it_now_price
      foreign_key :card_id, :cards
      DateTime :last_updated, :null=>false
      Integer :cards_in_item, :default=>1, :null=>false
      Float :price
      Integer :has_been_finalized, :default=>0
      Integer :has_match_been_attempted, :default=>0, :null=>false
      
      primary_key [:external_item_id]
      
      index [:external_item_id], :unique=>true, :name=>:unq_external_items__external_items_id
    end
    
    create_table(:possible_matches, :ignore_index_errors=>true) do
      foreign_key :external_item_id, :external_items
      foreign_key :card_id, :cards
      Float :score, :null=>false
      
      primary_key [:external_item_id, :card_id]
      
      index [:external_item_id], :name=>:idx_possible_matches__external_item_id
    end
    
    create_table(:xtn_types) do
      String :xtn_type_id, :null=>false, :size=>50
      String :name, :null=>false, :size=>50
      
      primary_key [:xtn_type_id]
    end
    
    create_table(:xtns) do
      foreign_key :card_id, :cards
      Date :date, :null=>false
      String :external_item_id, :null=>false, :size=>50
      Float :price
      String :xtn_type_id, :size=>50
      Integer :xtns, :default=>1
      
      primary_key [:card_id, :date, :external_item_id]
    end
    
    create_table(:xtns_by_card_day) do
      foreign_key :card_id, :cards
      Date :date, :null=>false
      Float :price
      Integer :xtns
    end
  end
  
  def down
    drop_table(:card_prices, :cards, :cardsets, :external_items, :possible_matches, :xtn_types, :xtns, :xtns_by_card_day)
  end
end
