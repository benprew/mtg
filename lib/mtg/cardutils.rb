module CardUtils
  module_function

  def card_picture(card)
    '/sets/' + card[:set_name].downcase.gsub(/\s/, '_') + '/' + card[:collector_no].to_s + '.jpeg'
  end
end
