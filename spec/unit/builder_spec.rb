require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))
require 'mtg/builder'

describe Mtg::Builder do
  describe '#sql' do
    it 'should sum xtns' do
      query = Mtg::Builder.new.query do
        select :card_no, :xtns
        group_by :card_no
      end

      query.to_sql.should == <<-SQL.gsub('        ', '')
        SELECT
          xtns.card_no AS card_no,
          SUM(xtns.xtns) AS xtns
        FROM
          xtns
        GROUP BY
          xtns.card_no
      SQL
    end

    it 'should calc avg_price correctly' do
      query = Mtg::Builder.new.query do
        select :avg_price
      end

      query.to_sql.should == <<-SQL.gsub('        ', '')
        SELECT
          sum(xtns.price) / sum(xtns.xtns) AS avg_price
        FROM
          xtns
      SQL

    end
  end

  
end
