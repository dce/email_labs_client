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
    setup do
      @messages = EmailLabsClient::EMAIL_TYPES[:site_message]
    end
    
    context "managing list membership" do
      should "tell if a user is already on mailing list" do
        EmailLabsClient.expects(:send_request).with('record',
          'query-data').returns(true)
        assert EmailLabsClient.user_exists?('user@example.com')
      end

      should "tell if a user is subscribed to an email type" do
        EmailLabsClient.expects(:send_request).with('record',
          'query-data', true).returns("<DATA type=\"demographic\" " +
          "id=\"#{@messages[:demographic]}\">on</DATA>")
        assert EmailLabsClient.site_messages_has_subscriber?('user@example.com')
      end

      should "add a new user" do
        EmailLabsClient.expects(:user_exists?).with('user@example.com').returns false
        EmailLabsClient.expects(:send_request).with('record',
          'add').returns(true)
        assert EmailLabsClient.subscribe_user_to_site_messages('user@example.com')
      end

      should "accept an optional name" do
        EmailLabsClient.expects(:user_exists?).with('user@example.com').returns false
        EmailLabsClient.expects(:send_request).with('record',
          'add').returns(true)
        assert EmailLabsClient.subscribe_user_to_site_messages('user@example.com',
          :first_name => 'Sample', :last_name => 'User')
      end
    
      should "update a user if already exists" do
        EmailLabsClient.expects(:user_exists?).with('user@example.com').returns true
        EmailLabsClient.expects(:send_request).with('record',
          'update').returns(true)
        assert EmailLabsClient.subscribe_user_to_site_messages('user@example.com')
      end

      should "remove a user" do
        EmailLabsClient.expects(:send_request).with('record',
          'update').returns(true)
        assert EmailLabsClient.unsubscribe_user_from_site_messages('user@example.com')
      end
    end
    
    context "sending email" do
      should "send email" do
        EmailLabsClient.expects(:send_request).with('triggers',
          'fire-trigger').returns(true)
        assert EmailLabsClient.send_site_message('user@example.com', 'Why hello there!')
      end

      should "accept sender name and email address" do
        EmailLabsClient.expects(:send_request).with('triggers',
          'fire-trigger').returns(true)
        assert EmailLabsClient.send_site_message('user@example.com', 'Why hello there!',
          :first_name => "John", :last_name => "Smith")
      end
    end
  end
end