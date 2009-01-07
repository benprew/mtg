module Keyword

  # only returns keywords that are 3 chars or more

  @@reject_list = %w(dci the mtg promo gathering jss fnm mint rare prerelease prix tcg textless)
  
  def keywords_from_string(string)
    str = string.gsub(/'/, '')
    str = str.gsub(/[^a-zA-Z0-9]/, ' ')
    str.downcase!
    str = str.gsub(/free shipping/, ' ')
    str = str.gsub(/magic the gathering/, ' ')
    str.split(/\s+/).reject { |i| @@reject_list.member?(i) }.grep(/\w{3,}/)
  end
end

