module ImporterUtils
  def url_ify(gateway, params)
    url = gateway + params.inject('?') { |r, e| r + "#{e[0]}=#{URI.escape e[1].to_s}&" }
    url.chop
  end

  def app_id
    'BenPrew2f-def9-421f-87b8-55dc6a53837'
  end

  def cert
    'efd1bf35-147f-4584-8922-b89a3e3c3673'
  end

  def gateway
    'http://open.api.ebay.com/shopping'
  end

end
