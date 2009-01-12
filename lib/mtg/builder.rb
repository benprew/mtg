$:.unshift File.dirname(__FILE__) + '/../../../sqlbuilder/lib'
require 'date'
require 'sqlbuilder'
require 'mtg/external_item'

module Mtg
  class Builder < SqlBuilder::Builder

    def self.cards_resource
      SqlBuilder::Resource.new(:cards,
        {
          :card_no => Integer,
          :card_name => [ String, { :db_name => :name } ],
          :casting_cost => String,
          :type => String,
          :rarity => String,
          :set_name => String
        },
        [:card_no]
        )
    end

    def self.build_resource_from_dm_model(model)
      table_name = model.storage_name
      properties_hash = {}
      key_fields = []
      model.properties.each do |prop|
        properties_hash[prop.name] = prop.type
        key_fields << prop.name if prop.key?
      end

      return SqlBuilder::Resource.new(
        table_name,
        properties_hash,
        key_fields
        )
      
    end

    field SqlBuilder::Field.new( :xtns, 'sum' )
    field SqlBuilder::Field.new( :price, 'avg' )

    resource Builder.build_resource_from_dm_model(Xtn)
    resource Builder.cards_resource
    resource Builder.build_resource_from_dm_model(ExternalItem)

  end
end


