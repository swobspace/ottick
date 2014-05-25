require 'spec_helper'
require_relative './support/variables.rb'

describe 'TicketGet' do
  include_context "basic variables"

  before(:each) do
    @ticket = Ottick::Ticket.new({ 
                wsdl: wsdl, endpoint: endpoint, otrs_user: otrs_user, 
                otrs_passwd: otrs_passwd }.merge(basic_auth)
              )
  end

  it "ticket_get returns some content" do
    response = @ticket.ticket_get("TicketID" => ticket_get_id)
    response.body.should include(:ticket_get_response)
    response.body[:ticket_get_response].should include(:ticket)
    ticket = response.body[:ticket_get_response][:ticket]
    ticket.should include(:queue, :queue_id, :create_by)
  end
  
end
