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
    expect(response.body).to include(:ticket_get_response)
    expect(response.body[:ticket_get_response]).to include(:ticket)
    ticket = response.body[:ticket_get_response][:ticket]
    expect(ticket).to include(:queue, :queue_id, :create_by)
  end

  it "get returns some content" do
    response = @ticket.get("TicketID" => ticket_get_id)
    expect(response[:ticket]).to include(:queue, :title)
    expect(@ticket.response[:ticket]).to include(:queue, :title)
  end
  
end
