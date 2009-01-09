module Keyword

  # only returns keywords that are 3 chars or more

  @@reject_list = %w(dci the mtg promo gathering jss fnm mint rare prerelease prix tcg textless excellent)

  @@numbers = {
    '1st' => 'first',
    '2nd' => 'second',
    '3rd' => 'third',
    '4th' => 'fourth',
    '5th' => 'fifth',
    '6th' => 'sixth',
    '7th' => 'seventh',
    '8th' => 'eighth',
    '9th' => 'ninth',
    '10th' => 'tenth',
    '11th' => 'eleventh'
  }
  
  def keywords_from_string(string)
    str = string.gsub(/'/, '')
    str = str.gsub(/[^a-zA-Z0-9]/, ' ')
    str.downcase!
    str = str.gsub(/free shipping/, ' ')
    str = str.gsub(/magic the gathering/, ' ')
    str.split(/\s+/).reject { |i| @@reject_list.member?(i) }.grep(/\w{3,}/).map { |j| @@numbers.has_key?(j) ? @@numbers[j] : j }
  end
end

