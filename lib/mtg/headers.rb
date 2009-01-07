
class Headers

  def self.as_dollar(value)
    value ? sprintf("$%.2f", value) : ''
  end

  def self.as_pass(value)
    value
  end

  def self.find(header)
    @@headers.each do |h|
      return h if header == h[:name]
    end

    raise "No header named '#{header}' found"
  end

  @@headers = [
    { :name => :name,          :title => 'Name',      :format => method(:as_pass) },
    { :name => :set_name,      :title => 'Set',       :format => method(:as_pass) },
    { :name => :max,           :title => 'Max Price', :format => method(:as_dollar) },
    { :name => :min,           :title => 'Min Price', :format => method(:as_dollar) },
    { :name => :avg,           :title => 'Ave Price', :format => method(:as_dollar) },
    { :name => :volume,        :title => 'Vol',       :format => method(:as_pass) },
    { :name => :match,         :title => 'Match',     :format => method(:as_pass) },
    { :name => :score,         :title => 'Score',     :format => method(:as_pass) },
    { :name => :cards_in_item, :title => '# Cards',   :format => method(:as_pass) },
  ]
end
