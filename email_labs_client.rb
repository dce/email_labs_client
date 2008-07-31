class EmailLabsClient
  ENDPOINT      = 'http://www.elabs7.com/API/mailing_list.html'
  SITE_ID       = '1234567890'
  MAILING_LISTS = { 
    'site_updates' => { :id => '12345', :trigger => '6789' },
    'newsletter'   => { :id => '24560' }
  }
  
  def self.method_missing(symbol, *args)
    case symbol.to_s
    when /subscribe_user_to_(\w+)/
      subscribe_user MAILING_LISTS[$1][:id], *args
    when /send_(\w+)/
      send_email MAILING_LISTS[$1][:id], MAILING_LISTS[$1][:trigger], *args
    end
  end
  
  protected
  
  def self.subscribe_user(mailing_list, email_address, options = {})
    send_request('record', 'add') do |body|
      body.MLID mailing_list
      body.DATA email_address, :type => 'email'
      body.DATA options[:first_name], :type => 'demographic', :id => '1' unless options[:first_name].blank?
      body.DATA options[:last_name],  :type => 'demographic', :id => '2' unless options[:last_name].blank?
    end
  end
  
  def self.send_email(mailing_list, trigger_id, email_address, message)
    send_request('triggers', 'fire-trigger') do |body|
      body.MLID mailing_list
      body.DATA trigger_id,    :type => 'extra', :id => 'trigger_id'
      body.DATA email_address, :type => 'extra', :id => 'recipients'
      body.DATA message,       :type => 'extra', :id => 'message'
    end    
  end
  
  def self.send_request(request_type, activity)
    xml = Builder::XmlMarkup.new :target => (input = '')
    xml.instruct!
    xml.DATASET do
      xml.SITE_ID SITE_ID
      yield xml
    end
    Net::HTTP.post_form(URI.parse(ENDPOINT), :type => request_type, :activity => activity, :input => input)
  end

end