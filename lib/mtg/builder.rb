$:.unshift File.dirname(__FILE__) + '/../../../sqlbuilder/lib'
require 'date'
require 'sqlbuilder'
require 'mtg/db'
require 'mtg/external_item'
require 'mtg/xtn'
require 'mtg/possible_match'

module Mtg
  class Builder < SQLBuilder::Builder

    def initialize
      super
      table Builder.cards_table()
      table Builder.build_resource_from_dm_model(Xtn)
      table Builder.build_resource_from_dm_model(ExternalItem)
      table Builder.build_resource_from_dm_model(PossibleMatch)

      calculation :avg_price, 'sum(?price) / sum(?xtns)', Float
    end

    def self.cards_table
      SQLBuilder::Table.new(:cards) do
        key :card_no, Integer
        add :card_name, String, :db_name => :name
        add :casting_cost, String
        add :type, String
        add :rarity, String
        add :set_name, String
      end
    end

    def self.build_resource_from_dm_model(model)

      table_name = model.storage_name

      return SQLBuilder::Table.new(table_name.to_sym) do
        model.properties.each do |prop|
          prop.key? \
          ? key( prop.name, prop.type, Builder._aggregate_for_type(prop.type) ) \
          : add( prop.name, prop.type, Builder._aggregate_for_type(prop.type) )
        end
      end
    end

    def self._aggregate_for_type(type)
      if type == Integer || type == Float
        return :aggregate => 'SUM'
      else
        return :aggregate => 'MAX'
      end
    end
  end
end


