EmailLabsClient
===============

This program is a simple Ruby client for the [EmailLabs API][eml]. We're releasing it initially as an example of a working API client. It will probably require some modification on your part, as it's highly specialized for our particular purposes. If you find it useful, please send us patches so that we can make it more full-featured.

  [eml]: http://www.emaillabs.com/email-marketing/api-faq.html

Features
--------

We need to be able to add users to lists, and send email to individual users on our lists. We've defined a `method_missing` which handles methods of the formats `subscribe_user_to_[mailing]` and `send_[mailing]`. These methods reference the `MAILING_LISTS` class variable. Since it's so highly specialized, `method_missing` is deceptively unimportant; the protected methods are more universal, and more interesting.

The main method is `send_request`, which takes a type and an activity (see the API documentation for more information), as well as a block where the request body is defined. Built on top of that are `subscribe_user` and `send_email`, which behave as expected. By looking through these three methods, you should be able to get a good idea of how to interact with the EmailLabs API.

Dependencies
------------

EmailLabsClient uses [Builder][bld] to create XML for requests. We also require [ActiveSupport][acs] for the `.blank?` method, but that can be removed if you don't need that functionality. The tests use [Test/Unit][tst], [Mocha][mch], and [Shoulda][shd].

  [bld]: http://builder.rubyforge.org/
  [acs]: http://as.rubyonrails.com/
  [tst]: http://www.ruby-doc.org/stdlib/libdoc/test/unit/rdoc/classes/Test/Unit.html
  [mch]: http://mocha.rubyforge.org/
  [shd]: http://www.thoughtbot.com/projects/shoulda
  
***
Copyright (c) 2008 Viget Labs, released under the MIT license
