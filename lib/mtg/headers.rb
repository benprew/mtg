
class Headers

  def self.as_dollar(value)
    value ? sprintf("$%.2f", value) : ''
  end

  def self.as_decimal(value)
    value ? sprintf("%.2f", value) : ''
  end

  def self.as_pass(value)
    value
  end

  def self.as_int(value)
    value ? sprintf("%d", value) : ''
  end

  def self.find(header)
    @@headers.each do |h|
      return h if header == h[:name]
    end

    return { :name => header, :title => header.to_s, :format => method(:as_pass), :type => :string }
  end

  @@headers = [
    { :name => :name,          :title => 'Name',       :format => method(:as_pass), :type => :string },
    { :name => :set_name,      :title => 'Set',        :format => method(:as_pass), :type => :string },
    { :name => :casting_cost,  :title => 'Cast. Cost', :format => method(:as_pass), :type => :string },
    { :name => :card_id,       :title => 'card_id',    :format => method(:as_pass), :type => :number },

    { :name => :max,           :title => 'Max Price', :format => method(:as_dollar), :type => :number },
    { :name => :min,           :title => 'Min Price', :format => method(:as_dollar), :type => :number },
    { :name => :avg,           :title => 'Avg Price', :format => method(:as_dollar), :type => :number },
    { :name => :volume,        :title => 'Vol',       :format => method(:as_int),    :type => :number },
    { :name => :price,         :title => 'Price',     :format => method(:as_dollar), :type => :number },
    { :name => :match,         :title => 'Match',     :format => method(:as_pass),   :type => :string },
    { :name => :score,         :title => 'Score',     :format => method(:as_decimal), :type => :number },
    { :name => :cards_in_item, :title => '# Cards',   :format => method(:as_pass),   :type => :number },
    { :name => :avg_rare_price,:title => 'Avg Rare',  :format => method(:as_dollar), :type => :number },
    { :name => :avg_uncommon_price,:title => 'Avg Uncommon',  :format => method(:as_dollar), :type => :number },
    { :name => :rare_volume,   :title => 'Vol',       :format => method(:as_int), :type => :number },
    { :name => :uncommon_volume,:title => 'Vol',       :format => method(:as_int), :type => :number },
  ]
end
