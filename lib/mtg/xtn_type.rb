require 'rubygems'
require 'dm-core'

class XtnType
  include DataMapper::Resource
  
  property :xtn_type_id, String, :key => true
  property :name, String, :nullable => false
end
