ottick
======

Ruby Interface to OTRS using web services and SOAP to access the generic interface ```nph-genericinterface.pl```

**WORK IN PROGRESS, USE IT AT YOUR OWN RISK.**

Requirements
------------
* savon ~> 2.0

Installation
------------

```ruby
gem 'ottick', git: https://github.com/swobspace/ottick.git, branch: "master"
```

Configuration
-------------
Ottick has to be configured before usage. If you are using Rails, you best create
an initializer file like this:

```ruby
Ottick.setup do |config|
  # must match your configuration
  config.wsdl = "/path/to/GenericTicketGenerator.wsdl"
  config.endpoint = "http(s)://yourhost/otrs/nph-genericinterface.pl/Webservice/GenericTicketConnector"
  config.otrs_user = your_valid_otrs_user
  config.otrs_passwd = your_valid_otrs_password

  # likely to be set to match your configuration
  conf.ticket_queue = your_incoming_queue
 ...
end
```
More configuration options for a default setup can be found at [lib/ottick.rb](lib/ottick.rb).

Usage
-----

```ruby
require 'ottick'

@ticket = Ticket.new()  # Savon.client global parameters are possible here
found = @ticket.get("TicketID" => "1234567")
puts found.inspect

# returns
# {
#   :ticket=>{
#     :age=>"435004", :archive_flag=>"n", :change_by=>"2", 
#     :changed=>"2014-05-20 17:23:48", :create_by=>"2", 
#     :create_time_unix=>"1400599428", :created=>"2014-05-20 17:23:48", 
#     :customer_id=>"1234", :customer_user_id=>"...", 
#     :escalation_response_time=>"0", :escalation_solution_time=>"0",
#     :escalation_time=>"0", :escalation_update_time=>"0",
#     :group_id=>"20", :lock=>"lock", :lock_id=>"2", :owner=>"otrs",
#     :owner_id=>"2", :priority=>"3 normal", :priority_id=>"3",
#     :queue=>"MyQueue", :queue_id=>"13", :real_till_time_not_used=>"0",
#     :responsible=>"nobody", :responsible_id=>"1", :slaid=>nil,
#     :service=>"...", :service_id=>"2", :state=>"open",
#     :state_id=>"4", :state_type=>"open", :ticket_id=>"1234567",
#     :ticket_number=>"4711", :title=>"Just a Test",
#     :type=>"default", :type_id=>"1",
#     :unlock_timeout=>"1400599428", :until_time=>"0"},
#   :@xmlns=>"http://www.otrs.org/TicketConnector/"
# }


created = @ticket.create("Subject and title", "message body")
puts created.inspect
# returns
# { 
#   :ticket_id => 1234567,
#   :article_id => 5678,
#   :ticket_number => 4711,
#   :@xmlns=>"http://www.otrs.org/TicketConnector/"
# }
    
```

Licence
-------

Ottick Copyright (C) 2014  Wolfgang Barth

MIT License, see [LICENSE](LICENSE)

This repository includes the file [GenericTicketConnector.wsdl](https://github.com/OTRS/otrs.git/development/webservices/GenericTicketConnector.wsdl) from OTRS licensed under the AFFERO GNU General Public License [AGPLv3](http://www.gnu.org/licenses/agpl-3.0.html)
