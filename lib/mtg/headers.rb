
class Headers

  def self.as_dollar(value)
    value ? sprintf("$%.2f", value) : ''
  end

  def self.as_pass(value)
    value
  end

  def self.find(header)
    if @@headers.has_key?(header)
      return @@headers[header]
    else
      raise "No header named '#{header}' found"
    end
  end

  @@headers = {
    'name' => { :title => 'Name', :format => method(:as_pass) },
    'set_name' => { :title => 'Set', :format => method(:as_pass) },
    'max' => { :title => 'Max Price', :format => method(:as_dollar) },
    'min' => { :title => 'Min Price', :format => method(:as_dollar) },
    'avg' => { :title => 'Ave Price', :format => method(:as_dollar) },
    'volume' => { :title => 'Vol', :format => method(:as_pass) },
  }

end
