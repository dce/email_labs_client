class EmailLabsClient
  ENDPOINT    = 'http://www.elabs7.com/API/mailing_list.html'
  SITE_ID     = '1234567890'
  MLID        = '12345'
  PASSWORD    = 'xxxxxxx'
  EMAIL_TYPES = {
    :newsletter   => { :demographic => '12345', :trigger => '1234' },
    :notification => { :demographic => '23456', :trigger => '2345' },
    :invitation   => { :demographic => ['34567', '45678'], :trigger => '3456' }
  }

  def self.method_missing(symbol, *args)
    case symbol.to_s
    when /subscribe_user_to_(\w+)/
      subscribe_user EMAIL_TYPES[$1.singularize.to_sym][:demographic], *args
    when /unsubscribe_user_from_(\w+)/
      unsubscribe_user EMAIL_TYPES[$1.singularize.to_sym][:demographic], *args
    when /(\w+)_has_subscriber\?/
      has_subscriber? EMAIL_TYPES[$1.singularize.to_sym][:demographic], *args
    when /send_(\w+)/
      send_email EMAIL_TYPES[$1.to_sym][:trigger], *args
    else
      super
    end
  end

  def self.user_exists?(email_address)
    send_request('record', 'query-data') do |body|
      body.DATA email_address, :type => 'email'
    end
  end

  protected

  def self.subscribe_user(demographic_ids, email_address, options = {})
    demographic_ids = [demographic_ids] if demographic_ids.is_a?(String)
    action = user_exists?(email_address) ? 'update' : 'add'

    send_request('record', action) do |body|
      body.DATA email_address, :type => 'email'
      demographic_ids.each do |demographic_id|
        body.DATA 'on', :type => 'demographic', :id => demographic_id
      end
      body.DATA options[:first_name], :type => 'demographic', :id => '1' unless options[:first_name].blank?
      body.DATA options[:last_name],  :type => 'demographic', :id => '2' unless options[:last_name].blank?
    end
  end

  def self.unsubscribe_user(demographic_ids, email_address, options = {})
    demographic_ids = [demographic_ids] if demographic_ids.is_a?(String)
    send_request('record', 'update') do |body|
      body.DATA email_address, :type => 'email'
      demographic_ids.each do |demographic_id|
        body.DATA nil, :type => 'demographic', :id => demographic_id
      end
    end
  end

  def self.has_subscriber?(demographic_ids, email_address, options = {})
    demographic_ids = [demographic_ids] if demographic_ids.is_a?(String)
    response = send_request('record', 'query-data', true) do |body|
      body.DATA email_address, :type => 'email'
    end
    demographic_ids.all? do |d|
      response.include? "<DATA type=\"demographic\" id=\"#{d}\">on</DATA>"
    end
  end

  def self.send_email(trigger_id, email_address, message, options = {})
    send_request('triggers', 'fire-trigger') do |body|
      body.DATA trigger_id,    :type => 'extra', :id => 'trigger_id'
      body.DATA email_address, :type => 'extra', :id => 'recipients'
      body.DATA message,       :type => 'extra', :id => 'message'
      options.to_a.sort_by {|o| o.first.to_s }.each do |key, value|
        body.DATA value, :type => 'extra', :id => key.to_s unless value.blank?
      end
    end
  end

  def self.send_request(type, activity, return_body = false)
    xml = Builder::XmlMarkup.new :target => (input = '')
    xml.DATASET do
      xml.SITE_ID SITE_ID
      xml.MLID MLID
      xml.DATA PASSWORD, :type => 'extra', :id => 'password'
      yield xml
    end

    conn = Net::HTTP.new("www.elabs7.com", 443)
    conn.use_ssl = true
    conn.verify_mode = OpenSSL::SSL::VERIFY_NONE

    response = conn.start do |http|
      req = Net::HTTP::Post.new("/API/mailing_list.html")
      req.set_form_data("activity" => activity, "type" => type, "input" => input)
      http.request(req).body
    end
    return_body ? response : response.include?("<TYPE>success</TYPE>")
  end

end