require 'savon'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/hash'

module Ottick
  class Ticket
    attr_reader :options, :client

    # Ticket.new(options)
    # for possible options see Savon.client()
    # http://savonrb.com/version2/client.html
    #
    def initialize(options = {})
      sanitize_options!(options)
      @otrs_credentials = otrs_credentials!(options)
      @options          = default_options.merge(options)
      @client           = Savon.client(@options)
    end

    def ticket_get(options = {})
      @client.call(:ticket_get, message: @otrs_credentials.merge(options))
    end

    private
 
    def sanitize_options!(options)
      return if options.empty?
      options.symbolize_keys!
      if options.has_key?(:http_auth_user) or options.has_key?(:http_auth_passwd)
        raise RuntimeError, 
              "please use basic_auth: ['user', 'passwd'] instead of" +
              ":http_auth_user and http_auth_passwd"
      end
    end

    def otrs_credentials!(options)
      otrs_cred = options.extract!(:otrs_user, :otrs_passwd)
      {
        "UserLogin" => otrs_cred.fetch(:otrs_user, Ottick.otrs_user),
        "Password"  => otrs_cred.fetch(:otrs_passwd, Ottick.otrs_passwd)
      }
    end
 
    def default_options
      default_basic_options.merge(default_http_authentication)
    end

    def default_basic_options
      {
        wsdl: 	     Ottick.wsdl,
        endpoint:    Ottick.endpoint,
        env_namespace: :soapenv,
        convert_request_keys_to: :camelcase
      }
    end

    def default_http_authentication
      if Ottick.http_auth_user.blank?
        {}
      else
        { basic_auth: [Ottick.http_auth_user, Ottick.http_auth_passwd] }
      end
    end
  end
end
