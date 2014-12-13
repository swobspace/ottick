require 'spec_helper'
require_relative './support/variables.rb'

# Check the ottick/support/.env and ottick/lib/ottick.rb
# and set valid default variables for your OTRS installation.

describe 'Ottick::Ticket#add_article' do

  # Run this example with 'bundle exec rspec -t modify'
  describe 'with valid settings', modify: true do
    include_context 'basic variables'

    before(:each) do
      @ticket = Ottick::Ticket.new(
        {
          wsdl: wsdl,
          endpoint: endpoint,
          otrs_user: otrs_user,
          otrs_passwd: otrs_passwd
        }.
        merge(basic_auth)
      )
    end

    it 'returns some content' do
      subject = 'RSpec Test Article'
      text    = 'Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.'
      options = { 'TicketID' => ticket_get_id }

      response = @ticket.ticket_add_article( subject, text, options )
      expect( response.body ).to include( :ticket_update_response )
      ts = response.body[:ticket_update_response]
      expect( ts ).to include( :ticket_id )
      expect( ts ).to include( :article_id )
      expect( ts ).to include( :ticket_number )

      # This only works when ther is no article created on the ticket between
      # the above #add_article method and the #ticket_get method below.
      response = @ticket.ticket_get(
          'TicketID'     => ts[:ticket_id],
          'AllArticles'  => 1,
          'ArticleOrder' => 'DESC',
          'ArticleLimit' => 1
      )
      expect( response.body[:ticket_get_response] ).to include( :ticket )
      expect( response.body[:ticket_get_response][:ticket] ).to include( :ticket_id )
      expect( response.body[:ticket_get_response][:ticket][:ticket_id] ).to eq( ticket_get_id )
      expect( response.body[:ticket_get_response][:ticket] ).to include( :article )
      expect( response.body[:ticket_get_response][:ticket][:article] ).to include( :subject )
      expect( response.body[:ticket_get_response][:ticket][:article][:subject] ).to eq( subject )
      expect( response.body[:ticket_get_response][:ticket][:article] ).to include( :body )
      expect( response.body[:ticket_get_response][:ticket][:article][:body] ).to eq( text )
    end

  end

  describe 'with invalid settings' do
    before( :each ) do
      @ticket = Ottick::Ticket.new()
    end

    it 'should not raise errors' do
      expect{ @ticket.add_article( 'subject', 'body' ) }.not_to raise_error
      expect( @ticket.add_article( 'subject', 'body' ) ).to be_nil
    end

    it 'should contain errors' do
      @ticket.add_article( 'subject', 'body' )
      expect( @ticket.errors.any? ).to be_truthy
      expect( @ticket.errors.join( ',' ) ).to match(/Exception occurred:/)
    end
  end
end