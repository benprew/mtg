module Keyword

  # only returns keywords that are 3 chars or more
  def keywords_from_string(string)
    str = string.gsub(/[^a-zA-Z0-9]/, ' ')
    str.downcase!
    str.split(/\s+/).reject { |i| i == 'the' }.grep(/\w{3,}/)
  end
end

