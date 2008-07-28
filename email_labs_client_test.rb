require 'rubygems'
require 'test/unit'
require 'mocha'
require 'shoulda'

$:.reject! { |e| e.include? 'TextMate' }

require 'builder'
require 'active_support'

require File.dirname(__FILE__) + '/email_labs_client'

class EmailLabsClientTest < Test::Unit::TestCase
  
  context "The EmailLabsClient class" do
  
    should "should add a new user" do
      Net::HTTP.expects(:post_form).with(URI.parse(EmailLabsClient::ENDPOINT),
        :type => 'record', :activity => 'add',
        :input => "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
                  "<DATASET>" +
                    "<SITE_ID>#{EmailLabsClient::SITE_ID}</SITE_ID>" +
                    "<MLID>#{EmailLabsClient::MAILING_LISTS['site_updates'][:id]}</MLID>" +
                    "<DATA type=\"email\">user@example.com</DATA>" +
                  "</DATASET>")
      EmailLabsClient.subscribe_user_to_site_updates('user@example.com')
    end
    
    should "should accept an optional name" do
      Net::HTTP.expects(:post_form).with(URI.parse(EmailLabsClient::ENDPOINT),
        :type => 'record', :activity => 'add',
        :input => "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
                  "<DATASET>" +
                    "<SITE_ID>#{EmailLabsClient::SITE_ID}</SITE_ID>" +
                    "<MLID>#{EmailLabsClient::MAILING_LISTS['site_updates'][:id]}</MLID>" +
                    "<DATA type=\"email\">user@example.com</DATA>" +
                    "<DATA type=\"demographic\" id=\"1\">Sample</DATA>" + 
                    "<DATA type=\"demographic\" id=\"2\">User</DATA>" +
                  "</DATASET>")
      EmailLabsClient.subscribe_user_to_site_updates('user@example.com',
        :first_name => 'Sample', :last_name => 'User')
    end
    
    should "should send email" do
      Net::HTTP.expects(:post_form).with(URI.parse(EmailLabsClient::ENDPOINT),
        :type => 'triggers', :activity => 'fire-trigger',
        :input => "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
                  "<DATASET>" +
                    "<SITE_ID>#{EmailLabsClient::SITE_ID}</SITE_ID>" +
                    "<MLID>#{EmailLabsClient::MAILING_LISTS['site_updates'][:id]}</MLID>" +
                    "<DATA type=\"extra\" id=\"trigger_id\">" + 
                      "#{EmailLabsClient::MAILING_LISTS['site_updates'][:trigger]}</DATA>" +
                    "<DATA type=\"extra\" id=\"recipients\">user@example.com</DATA>" +
                    "<DATA type=\"extra\" id=\"message\">Why hello there!</DATA>" +
                  "</DATASET>")
      EmailLabsClient.send_site_updates('user@example.com', 'Why hello there!')
    end
    
  end
  
end