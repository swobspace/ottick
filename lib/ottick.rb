require "ottick/version"
require 'active_support/core_ext/module'

module Ottick

  autoload :Ticket, 'ottick/ticket'

  def self.setup
    yield self
  end

  # endpoint for soap
  # Example: 
  # endpoint = https://localhost/otrs/nph-genericinterface.pl/Webservice/GenericTicketConnector"
  # Default: nil
  #
  mattr_accessor :endpoint
  @@endpoint = nil

  # wsdl: local file or url
  # you can download the wsdl file from https://raw.githubusercontent.com/OTRS/otrs/rel-3_3/development/webservices/GenericTicketConnector.wsdl
  # 
  # Example:
  # wsdl = "GenericTicketConnector.wsdl"
  #
  mattr_accessor :wsdl
  @@wsdl = nil

  # basic auth
  # only neccessary if you use OTRS with http_authenication
  # must be a valid OTRS user with http_authentication
  #
  mattr_accessor :http_auth_user, :http_auth_password
  @@http_auth_user = nil
  @@http_auth_passwd = nil

  # UserLogin and Password for web service operations
  # if you use http_authentication, use a dummy string here (can't be left blank)
  # otherwise set credential for a valid OTRS user.
  mattr_accessor :otrs_user, :otrs_password
  @@otrs_user = nil
  @@otrs_passwd = nil
  
  # Ticket default settings
  #
  mattr_accessor :ticket_type, :ticket_priority, :ticket_state
  @@ticket_priority = "normal"
  @@ticket_state    = "new"
  @@ticket_type     = "default"

  # Article default settings
  #
  mattr_accessor :article_sender_type, :article_charset, :article_mime_type
  @@article_sender_type = "customer"
  @@article_charset     = "utf8"
  @@article_mime_type   = "text/plain"
  
end
