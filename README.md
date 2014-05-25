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

created = @ticket.create("Subject and title", "message body")
puts created.inspect
```

Licence
-------

Ottick Copyright (C) 2014  Wolfgang Barth

MIT License, see [LICENSE](LICENSE)

This repository includes the file [GenericTicketConnector.wsdl](https://github.com/OTRS/otrs.git/development/webservices/GenericTicketConnector.wsdl) from OTRS licensed under the AFFERO GNU General Public License [AGPLv3](http://www.gnu.org/licenses/agpl-3.0.html)
