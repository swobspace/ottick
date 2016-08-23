require 'savon'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/hash'

module Ottick
  class Ticket
    attr_reader :options, :client, :errors, :response

    # Ticket.new(options)
    # for possible options see Savon.client()
    # http://savonrb.com/version2/client.html
    #
    def initialize(options = {})
      sanitize_options!(options)
      @otrs_credentials = otrs_credentials!(options)
      @options          = default_options.merge(options)
      @client           = Savon.client(@options)
      @errors           = []
      @response         = nil
    end

    def get(options = {})
      begin
        response = ticket_get(options)
        if response.success?
          @response = response.body[:ticket_get_response]
          if @response.include?(:ticket)
            @response
          else
            @errors << "#{@response[:error][:error_code]} => #{@response[:error][:error_message]}"
            nil
          end
        elsif response.soap_fault?
          @errors << response.body.to_s
          nil
        else
          @errors << response.http.to_s
          nil
        end
      rescue Exception => e
        @errors << "Exception occurred: " + e.to_s
        nil
      end
    end

    def create(subject, text, options = {})
      begin
        response = ticket_create(subject, text, options)
        if response.success?
          @response = response.body[:ticket_create_response]
          if @response.include?(:ticket_id)
            @response
          else
            @errors << "#{@response[:error][:error_code]} => #{@response[:error][:error_message]}"
            nil
          end
        elsif response.soap_fault?
          @errors << response.body.to_s
          nil
        else
          @errors << response.http.to_s
          nil
        end
      rescue Exception => e
        @errors << "Exception occurred: " + e.to_s
        nil
      end
    end

    # Adds an article to an existing ticket. Either `TicketID` or `TicketNumber`
    # has to be given in the options.
    #
    # For other options visit:
    # http://otrs.github.io/doc/manual/admin/stable/en/html/genericinterface.html#genericinterface-connectors
    #
    # Example:
    # add_article(
    #   'Subject of the Article',
    #   'Content of the Article',
    #   {
    #     'TicketID' => 1, # OR 'TicketNumber' => 2010080210123456
    #     #OPTIONAL START#
    #     'Article' => {
    #       'ArticleType' => 'note-internal',
    #       'OtherArticleOption' => 'value'
    #     }
    #     #OPTIONAL END#
    #   }
    # )
    def add_article( subject, text, options = {} )
      begin
        # Call `ticket_add_article` to check the given parameters and create a
        # SOAP request using savon.
        response = ticket_add_article( subject, text, options )
        # Check if the the response is successful.
        if response.success?
          # Strip from unusefull information
          @response = response.body[:ticket_update_response]
          # Check if the response contains an ticked id.
          if @response.include?( :ticket_id )
            # Return the response
            @response

          # Error handling
          # use `.errors` to see if any errors occurred.
          #
          # example:
          # otrs_ticket = Ottick::Ticket.new()
          # otrs_ticket.add_article( #params# )
          # otrs_ticket.errors
          #
          # This will return an array with errors if there are any.
          # Otherwise it will return an empty array.
          else
            @errors << "#{@response[:error][:error_code]} => #{@response[:error][:error_message]}"
            nil
          end
        elsif response.soap_fault?
          @errors << response.body.to_s
          nil
        else
          @errors << response.http.to_s
          nil
        end
      rescue Exception => e
        @errors << "Exception occurred: " + e.to_s
        nil
      end
    end

    # Search an article based on options given in:
    # http://otrs.github.io/doc/manual/admin/stable/en/html/genericinterface.html#genericinterface-connectors
    #
    # Example:
    def search(options = {})
      begin
        # Call `ticket_search` to check the given parameters and create a
        # SOAP request using savon.
        response = ticket_search(options)
        # Check if the the response is successful.
        if response.success?
          # Strip from unusefull information
          @response = response.body[:ticket_search_response]
          # Check if the response contains an ticked id.
          if @response.include?(:ticket_id)
            # Return the response
            @response

          # Error handling
          # use `.errors` to see if any errors occurred.
          #
          # example:
          # otrs_ticket = Ottick::Ticket.new()
          # otrs_ticket.search( #params# )
          # otrs_ticket.errors
          #
          # This will return an array with errors if there are any.
          # Otherwise it will return an empty array.
          else
            @errors << "#{@response[:error][:error_code]} => #{@response[:error][:error_message]}"
            nil
          end
        elsif response.soap_fault?
          @errors << response.body.to_s
          nil
        else
          @errors << response.http.to_s
          nil
        end
      rescue Exception => e
        @errors << "Exception occurred: " + e.to_s
        nil
      end
    end

    def ticket_get(options = {})
      @client.call(:ticket_get, message: @otrs_credentials.merge(options))
    end

    def ticket_create(subject, text, options = {})
      return if (subject.blank? || text.blank?)
      ticket_opts = create_ticket_opts!(options)
      ticket_opts.merge!("Title" => subject)
      article_opts = create_article_opts!(options)
      article_opts.merge!("Subject" => subject).merge!("Body" => text)

      @client.call(
        :ticket_create,
        message: @otrs_credentials.
          merge("Ticket" => ticket_opts).
          merge("Article" => article_opts).
          merge(options)
      )
    end

    def ticket_add_article( subject, text, options = {} )
      # Returns the function if `subject` or `text` is blank.
      return if ( subject.blank? || text.blank? )
      # Returns the function if `options` has neither `TicketID` or `TicketNumer`
      # as key. Or if `options` has both `TicketID` and `TicketNumer`.
      return unless options.has_key?( 'TicketID' ) != options.has_key?( 'TicketNumber' )
      # Set the default article options and overwrite with given article options.
      # Article options has to be specified as such:
      # options = { 'Article' => { 'ArticleOption1' => 'asdf', 'ArticleOption2' => 1 } }
      article_opts = create_article_opts!( options )
      # Add `Subject` and `Body` to the hash.
      article_opts.merge!( "Subject" => subject ).merge!( "Body" => text )

      # Create a savon SOAP request
      @client.call(
        # Use the otrs function TicketUpdate
        :ticket_update,
        # Create one large hash by merging the login credentials with the
        # article options and other options. Send this hash as message.
        message: @otrs_credentials.
          merge( 'Article' => article_opts ).
          merge( options )
      )
    end

    def ticket_search(options = {})
      @client.call(:ticket_search, message: @otrs_credentials.merge(options))
    end

    private

    def sanitize_options!(options)
      return if options.empty?
      options.symbolize_keys!
      if options.has_key?(:http_auth_user) or options.has_key?(:http_auth_passwd)
        raise RuntimeError,
          "please use basic_auth: ['user', 'passwd'] instead of " +
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
        wsdl:                    Ottick.wsdl,
        endpoint:                Ottick.endpoint,
        env_namespace:           :soapenv,
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

    def create_ticket_opts!(options)
      ticket_opts = options.extract!("Ticket")
      ticket_opts = ticket_opts.nil? ? {} : ticket_opts.fetch("Ticket", {})
      sanitize_ticket_opts!(ticket_opts)
      {
        "Queue"        => Ottick.ticket_queue,
        "State"        => Ottick.ticket_state,
        "Type"         => Ottick.ticket_type,
        "Priority"     => Ottick.ticket_priority,
        "CustomerUser" => Ottick.customer_user
      }.merge(ticket_opts)
    end

    def create_article_opts!(options)
      article_opts = options.extract!("Article")
      article_opts = article_opts.nil? ? {} : article_opts.fetch("Article", {})
      sanitize_article_opts!(article_opts)
      {
        "SenderType" => Ottick.article_sender_type,
        "Charset"    => Ottick.article_charset,
        "MimeType"   => Ottick.article_mime_type
      }.merge(article_opts)
    end

    def sanitize_ticket_opts!(opts)
      if opts.has_key?("QueueID")
        raise RuntimeError, "Please use Queue instead of QueueID"
      end
      if opts.has_key?("StateID")
        raise RuntimeError, "Please use State instead of StateID"
      end
      if opts.has_key?("PriorityID")
        raise RuntimeError, "Please use Priority instead of PriorityID"
      end
      if opts.has_key?("TypeID")
        raise RuntimeError, "Please use Type instead of TypeID"
      end
    end

    def sanitize_article_opts!(opts)
      if opts.has_key?("SenderTypeID")
        raise RuntimeError, "Please use Type instead of TypeID"
      end
    end
  end
end
