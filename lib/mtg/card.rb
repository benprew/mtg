require 'rubygems'
require 'dm-core'
require 'mtg/keyword'
class Card
  include DataMapper::Resource
  include Keyword
  
  property :card_no, Serial, :key => true
  property :name, String, :length => 256
  property :casting_cost, String
  property :type, String
  property :rules_text, String, :length => 1024
  property :pow_tgh, String
  property :rarity, String
  property :set_name, String
  property :collector_no, Integer

  def picture
    '/sets/' + set_name.downcase.gsub(/\s/, '_') + '/' + collector_no.to_s + '.jpeg'
  end

  def all_keywords
    [ name_keywords(), set_keywords() ].flatten
  end

  def name_keywords
    keywords_from_string(self.name)
  end

  def set_keywords
    keywords_from_string(self.set_name)
  end

end
